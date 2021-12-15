require 'open-uri'

module Underwriting
  class Engine::V1
    include Processors::Dnb

    STEPS = %w[personal_details business_details financial_documents send_application personal_guarantee billing_information verification agreement].freeze
    MANDATORY_APPROVAL_STEPS = %w[personal_details business_details].freeze
    CHECKOUT_STEPS = %w[billing_information verification agreement].freeze
    CHECKOUT_STEPS_NON_OWNER = %w[billing_information send_application].freeze
    APPROVAL_STEPS = (STEPS - CHECKOUT_STEPS).freeze

    AMOUNT_THRSHOLD = Money.new(50_000_000)

    attr_accessor :order, :contact, :missing_info

    def initialize(contact, order)
      @order = order
      @contact = contact
      @missing_info = []
      @completed_info = []
      @point_system_config = YAML.load_file(Rails.root.join('lib', 'underwriting', 'vps_v1.yml'))
    end

    def execute
      dnb_scorecard if step1?
      experian_scorecard if step2?
      financial_analysis_score if step3?

      populate_steps
      update_steps
      @order.manual_review = true if enable_manual_review?
      @order.save if @order.changed? && @order.id?
    end

    private

    def step1?
      @order.pending? && @order.precheck? && !@order.manual_review
    end

    def step2?
      @order.pending? && @order.fullcheck? && @order.fullcheck_consent && !@order.manual_review
    end

    def step3?
      @order.pending? && @order.application? && @missing_info.empty? && !@order.manual_review && @order.financial_details != {}
    end

    def enable_manual_review?
      @order.pending? && @order.application? && @missing_info.empty? && !@order.manual_review
    end

    def update_steps
      case @order.status
      when 'precheck', 'fullcheck', 'application'
        @order.workflow_steps['steps'].each do |s|
          s['status'] = @missing_info.include?(s['name']) ? 'pending' : 'complete'
        end

        new_steps = MANDATORY_APPROVAL_STEPS - @order.workflow_steps['steps'].map { |s| s['name'] }
        new_steps.each do |s|
          step = { 'name' => s, 'status' => @missing_info.include?(s) ? 'pending' : 'complete' }
          @order.workflow_steps['steps'] << step
        end

        new_steps = @missing_info - @order.workflow_steps['steps'].map { |s| s['name'] }
        new_steps = new_steps.sort_by(&STEPS.method(:index))
        new_steps.each do |s|
          step = { 'name' => s, 'status' => 'pending' }
          @order.workflow_steps['steps'] << step
        end
      when 'checkout'
        @order.signature_request_id = Signature.create_signature_request(@order.generate_agreement, @order.customer.primary_contact) if @completed_info.include?('billing_information') && !@order.signature_request_id.present?

        @order.workflow_steps['steps'].each do |s|
          s['status'] = 'complete' if @completed_info.include?(s['name'])
        end

        stps = @contact.present? && @contact.owner_role? ? CHECKOUT_STEPS : CHECKOUT_STEPS_NON_OWNER
        new_steps = stps - @order.workflow_steps['steps'].map { |s| s['name'] }
        new_steps.each do |s|
          step = { 'name' => s, 'status' => @completed_info.include?(s) ? 'complete' : 'pending' }
          @order.workflow_steps['steps'] << step
        end
      when 'financed'
        @order.workflow_steps['steps'].each do |s|
          s['status'] = 'locked'
        end
      when 'agreement'
        @order.workflow_steps['steps'].each do |s|
          s['status'] = 'complete' if s['name'] == 'agreement'
        end
      end
    end

    def populate_steps
      @missing_info << 'personal_details' unless @contact.present? && @contact.complete?
      @missing_info << 'business_details' unless @order.customer.complete?
      @missing_info << 'financial_documents' if @order.application? && (%w[sub_prime declined missing].include?(@order.vartana_rating) || order.amount >= AMOUNT_THRSHOLD) && !@order.documents_complete?

      return unless @order.checkout?

      @completed_info << 'personal_details' if @contact.present? && @contact.complete?
      @completed_info << 'business_details' if @order.customer.complete?
      @completed_info << 'billing_information' if @order.customer.payment_methods.where(is_default: true).count.positive?
      @completed_info << 'send_application' if (@contact.present? && @contact.owner_role?) || (@contact.present? && !@contact.owner_role? && @order.application_sent)
      @completed_info << 'verification' if @contact.inquiry_completed?
    end

    # Step 1: D&B scores Calculations

    def vartana_score_dnb
      dnb = Underwriting::Processors::Dnb::Scores.new(@order)
      vs = 0.0

      employee_score = get_points('employee_score', dnb.employees)
      return if employee_score.nil?

      vs += employee_score

      business_score = get_points('business_score', dnb.years_in_business)
      return if business_score.nil?

      vs += business_score

      delinquency_score = get_points('delinquency_score', dnb.deliquency_score)
      return if delinquency_score.nil?

      vs += delinquency_score

      failure_score = get_points('failure_score', dnb.failure_score)
      return if failure_score.nil?

      vs += failure_score

      paydex_score = get_points('paydex_score', dnb.paydex_score)
      return if paydex_score.nil?

      vs += paydex_score

      vs *= get_cuttoffs('entity_type', dnb.entity_type)
      vs
    end

    def vartana_rating(score)
      rating = :missing
      @point_system_config['configs']['ratings'].each do |fs|
        rating = fs['rating'] if fs['range'].include?(score)
      end

      rating
    end

    def dnb_scorecard
      return unless @order.documents.where(type: :duns).count.positive?

      if vartana_score_dnb.nil?
        @order.vartana_rating = :missing
        @order.manual_review = true
        return
      end

      @order.vartana_score = vartana_score_dnb
      @order.vartana_rating = vartana_rating(vartana_score_dnb)
      @order.manual_review = true
    end

    # Step 2: Experian scores Calculations

    def vartana_score_experian
      dnb = Underwriting::Processors::Dnb::Scores.new(@order)
      experian = Underwriting::Processors::Experian::Scores.new(@order)
      vs = 0.0

      employee_score = get_points('employee_score', dnb.employees)
      return if employee_score.nil?

      vs += employee_score

      business_score = get_points('business_score', dnb.years_in_business)
      return if business_score.nil?

      vs += business_score

      delinquency_score = get_points('delinquency_score', experian.deliquency_score)
      return if delinquency_score.nil?

      vs += delinquency_score

      failure_score = get_points('failure_score', experian.failure_score)
      return if failure_score.nil?

      vs += failure_score

      paydex_score = get_points('days_beyond_term', experian.days_beyond_term)
      return if paydex_score.nil?

      vs += paydex_score
      vs
    end

    def experian_scorecard
      unless @order.documents.where(type: :experian).count.positive?
        @order.manual_review = true
        return
      end

      if vartana_score_experian.nil?
        @order.vartana_rating = :missing
        @order.manual_review = true
        return
      end

      @order.vartana_score = vartana_score_experian
      @order.vartana_rating = vartana_rating(@order.vartana_score)
      @order.manual_review = true
    end

    # Step 2: Financial Analysis Calculations

    def financial_analysis_score
      vs = @order.vartana_score
      vs *= get_cuttoffs('annual_revenue', @order.financial_details['annual_revenue'].to_f)
      vs *= get_cuttoffs('dscr', @order.dscr)

      first_month_cash_less_pmt = (Money.new(@order.financial_details.dig('month1', 'cash_balance')) * 100) - @order.payment
      second_month_cash_less_pmt = (Money.new(@order.financial_details.dig('month2', 'cash_balance')) * 100) - @order.payment
      third_month_cash_less_pmt = (Money.new(@order.financial_details.dig('month3', 'cash_balance')) * 100) - @order.payment

      vs *= 0 if first_month_cash_less_pmt < second_month_cash_less_pmt
      vs *= 0 if second_month_cash_less_pmt < third_month_cash_less_pmt

      @order.vartana_score = vs
      @order.vartana_rating = vs.positive? ? 'sub_prime' : 'declined'
      @order.manual_review = true
    end

    # Underwriting Engine Helpers

    def get_points(key, score)
      pts = 0.0
      @point_system_config['configs']['scores'][key]['points'].each do |fs|
        pts = fs['points'] if fs['range'].include?(score)
      end
      pts * @point_system_config['configs']['scores'][key]['weightage']
    end

    def get_cuttoffs(key, val)
      cuttoff = 1

      case @point_system_config['configs']['cutoffs'][key]['operator']
      when 'gt'
        cuttoff = val > @point_system_config['configs']['cutoffs'][key]['value'] ? 0 : 1
      when 'lt'
        cuttoff = val < @point_system_config['configs']['cutoffs'][key]['value'] ? 0 : 1
      when 'lte'
        cuttoff = val <= @point_system_config['configs']['cutoffs'][key]['value'] ? 0 : 1
      when 'gte'
        cuttoff = val >= @point_system_config['configs']['cutoffs'][key]['value'] ? 0 : 1
      when 'eq'
        cuttoff = val == @point_system_config['configs']['cutoffs'][key]['value'] ? 0 : 1
      when 'neq'
        cuttoff = val == @point_system_config['configs']['cutoffs'][key]['value'] ? 1 : 0
      end

      cuttoff
    end
  end
end
