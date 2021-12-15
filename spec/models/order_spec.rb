# == Schema Information
#
# Table name: orders
#
#  id                         :bigint           not null, primary key
#  status                     :string
#  billing_frequency          :string
#  start_date                 :date
#  end_date                   :date
#  approved_at                :datetime
#  declined_at                :datetime
#  customer_id                :bigint
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  number                     :string
#  workflow_steps             :jsonb
#  undewriting_engine_version :string           default("V1")
#  amount_cents               :integer          default(0), not null
#  amount_currency            :string           default("USD"), not null
#  term                       :decimal(, )
#  interest_rate              :decimal(5, 4)
#  interest_rate_subsidy      :decimal(5, 4)
#  signature_request_id       :string
#  has_form                   :boolean          default(FALSE), not null
#  product_id                 :bigint
#  application_sent           :boolean          default(FALSE), not null
#  loan_decision              :string
#  vartana_rating             :string
#  vartana_score              :decimal(4, 2)
#  manual_review              :boolean          default(FALSE), not null
#  fullcheck_consent          :boolean          default(FALSE), not null
#  financial_details          :jsonb            not null
#
require 'rails_helper'

RSpec.describe Order, type: :model do
  context 'finance!' do
    before do
      @vendor = create(:vendor)
      @product = create(:product, vendor: @vendor)
      @customer = create(:customer, vendor: @vendor)
      @contact = create(:contact, customer: @customer, primary: true)
      @order = create(:order, customer: @contact.customer)
      @cust_order = create(:custom_order, customer: @contact.customer)
      Timecop.freeze
    end

    it 'should not finance if already financed' do
      @order.update(status: :financed)
      expect { @order.finance! }.to raise_error(StandardError)
    end

    it 'should finance if in agreement' do
      expect { @order.finance! }
        .to change { Account.count }.by(1)
                                    .and change { PaymentSchedule.count }.by(1)
                                                                         .and change { Transaction.count }.by(2)
    end

    it 'should update customer and vendor account with debit and credit Transaction respectivly ' do
      @order.finance!
      expect(@order.account.balance).to eq((-1 * @order.amount))
      expect(@order.vendor.account.balance).to eq(@order.advance)
    end

    it 'should have two transactions debit and credit with difference equal to zero' do
      @order.finance!
      expect(@order.account.transactions.debit.first.principal).to eq(@order.amount)
      expect(@order.vendor.account.transactions.credit.first.principal).to eq(@order.advance)
    end

    it 'should have payment schedule and payment schedule items' do
      @order.finance!
      payment_schedule = @order.account.payment_schedules.where(status: :active).first
      expect(payment_schedule)
        .to have_attributes(term: @order.term,
                            start_date: @order.start_date,
                            end_date: @order.end_date,
                            billing_frequency: @order.billing_frequency,
                            interest_rate: @order.customer_interest_rate)

      expect(payment_schedule.payment_schedule_items.count)
        .to eq(@order.num_pmts)
    end

    it 'should have check the balance of customer account after multiple credit transactions' do
      @cust_order.finance!
      cust_account = @cust_order.account
      expect(cust_account.balance).to eq(Money.new(-345_000_00))
      cust_account.credit!(Money.new(15_964_094))
      cust_account.credit!(Money.new(16_009_705))
      cust_account.credit!(Money.new(16_055_447))
      expect(cust_account.balance).to eq(Money.new(13_529_246))
    end
  end

  context 'send_application!' do
    before do
      @vendor = create(:vendor)
      @product = create(:product, vendor: @vendor)
      @customer = create(:customer, vendor: @vendor)
      @contact = create(:contact, customer: @customer, primary: true)
      @order = create(:order, customer: @contact.customer)
      Timecop.freeze
    end

    it 'should send application if persisted and not frozen' do
      expect { @order.send_application! }.to change { Session.count }.by(1).and change { ActiveJob::Base.queue_adapter.enqueued_jobs.count }.by(1)

      expect { @order.send_application! }.to change { Session.count }.by(0).and change { ActiveJob::Base.queue_adapter.enqueued_jobs.count }.by(1)

      Timecop.travel(10.days.from_now)
      expect { @order.send_application! }.to change { Session.count }.by(1).and change { ActiveJob::Base.queue_adapter.enqueued_jobs.count }.by(1)
    end

    it 'should send not application if not persisted or frozen' do
      order = build(:order)
      expect { order.send_application! }.to raise_error(StandardError)
    end
  end

  context 'notification_emails' do
    before do
      @vendor = create(:vendor)
      @product = create(:product, vendor: @vendor)
      @customer = create(:customer, vendor: @vendor)
      @contact = create(:contact, customer: @customer, primary: true)
      @order = create(:order, customer: @contact.customer)
      Timecop.freeze
    end

    it 'should send all emails according to status if preference for the email is true' do
      expect { @order.update!(vartana_score: 89, status: 'fullcheck', fullcheck_consent: false) }.to change { ActiveJob::Base.queue_adapter.enqueued_jobs.count }.by(1)

      @order.update!(status: 'precheck')

      expect { @order.update!(vartana_rating: 'declined', status: 'fullcheck', fullcheck_consent: false) }.to change { ActiveJob::Base.queue_adapter.enqueued_jobs.count }.by(1)

      expect { @order.update!(status: 'application') }.to change { ActiveJob::Base.queue_adapter.enqueued_jobs.count }.by(1)

      expect { @order.update(status: 'checkout') }.to change { ActiveJob::Base.queue_adapter.enqueued_jobs.count }.by(1)

      expect { @order.update(status: 'financed') }.to change { ActiveJob::Base.queue_adapter.enqueued_jobs.count }.by(1)

      expect { @order.update(loan_decision: 'approved') }.to change { ActiveJob::Base.queue_adapter.enqueued_jobs.count }.by(1)

      expect { @order.update(loan_decision: 'declined') }.to change { ActiveJob::Base.queue_adapter.enqueued_jobs.count }.by(1)
    end
  end

  context 'notification_emails_not_Send' do
    before do
      @vendor = create(:vendor)
      @vendor.email_preferences.each do |pref, _val|
        @vendor.email_preferences[pref] = false
      end
      @vendor.save!
      @product = create(:product, vendor: @vendor)
      @customer = create(:customer, vendor: @vendor)
      @contact = create(:contact, customer: @customer, primary: true)
      @order = create(:order, customer: @contact.customer)
      @order.agreement.attach(io: File.open('./spec/fixtures/test.pdf'), filename: 'agreement.pdf')
      Timecop.freeze
    end

    it 'should not send the email if preference for that email is false' do
      expect { @order.update!(vartana_score: 89, status: 'fullcheck', fullcheck_consent: false) }.to_not(change { ActiveJob::Base.queue_adapter.enqueued_jobs.count })

      @order.update!(status: 'precheck')

      expect { @order.update!(vartana_rating: 'declined', status: 'fullcheck', fullcheck_consent: false) }.to_not(change { ActiveJob::Base.queue_adapter.enqueued_jobs.count })

      expect { @order.update!(status: 'application') }.to_not(change { ActiveJob::Base.queue_adapter.enqueued_jobs.count })

      expect { @order.update(status: 'checkout') }.to_not(change { ActiveJob::Base.queue_adapter.enqueued_jobs.count })

      expect { @order.update(status: 'financed') }.to_not(change { ActiveJob::Base.queue_adapter.enqueued_jobs.count })

      expect { @order.update(loan_decision: 'approved') }.to_not(change { ActiveJob::Base.queue_adapter.enqueued_jobs.count })

      expect { @order.update(loan_decision: 'declined') }.to_not(change { ActiveJob::Base.queue_adapter.enqueued_jobs.count })
    end
  end

  context 'formatted_payment' do
    it 'should send not application if not persisted or frozen' do
      order = build(:order)
      expect(order.formatted_payment).to eq('$0.00')
    end
  end

  context 'callbacks' do
    before do
      @vendor = create(:vendor)
      @product = create(:product, vendor: @vendor)
      @customer = create(:customer, vendor: @vendor)
      @order = create(:order, customer: @customer, amount: 600_000, status: :application)
    end

    it 'should return frozen? true if approved or declined' do
      expect(@order.frozen?).to be false

      @order.finance!
      expect(@order.frozen?).to be true
    end

    it 'should set approved timestamp' do
      Timecop.freeze
      @order.update(loan_decision: :approved)
      expect(@order.reload.approved_at.to_i).to eq(Time.now.to_i)
      expect(@order.reload.declined_at).to be_nil
    end

    it 'should set declined timestamp' do
      Timecop.freeze
      @order.update(loan_decision: :pending)
      expect(@order.reload.approved_at).to be_nil
      expect(@order.reload.declined_at).to be_nil
      @order.update(loan_decision: :declined)
      expect(@order.reload.approved_at).to be_nil
      expect(@order.reload.declined_at.to_i).to eq(Time.now.to_i)
    end

    it 'should set workflow steps' do
      expect(@order.workflow_steps['steps']).to eq([
        { 'name' => 'personal_details', 'status' => 'pending' },
        { 'name' => 'business_details', 'status' => 'complete' },
        { 'name' => 'financial_documents', 'status' => 'pending' }
      ])
    end
  end

  context 'finance helpers' do
    before do
      @vendor = create(:vendor)
      pricing_schema = JSON.parse(File.read(Rails.root.join('spec', 'fixtures', 'pricing_schema.json')))
      @product = create(:product, vendor: @vendor, pricing_schema: { "interest_rates": pricing_schema['interest_rates'] })
      @customer = create(:customer, vendor: @vendor)
      @order = create(:order, customer: @customer, interest_rate: 0.12, amount: 1440, start_date: Date.parse('2020-12-12'), end_date: Date.parse('2023-12-12'))
    end

    it 'should return correct values with full subsidy' do
      @order.interest_rate_subsidy = 1
      expect(@order.discount).to eq(Money.new(23_571))
      expect(@order.interest).to eq(Money.new(0))
      expect(@order.advance).to eq(Money.new(120_429))
      expect(@order.payment).to eq(Money.new(4000))
    end

    it 'should return correct values with zero subsidy' do
      @order.interest_rate_subsidy = 0
      expect(@order.discount).to eq(Money.new(0))
      expect(@order.interest).to eq(Money.new(28_181))
      expect(@order.advance).to eq(Money.new(144_000))
      expect(@order.payment).to eq(Money.new(4783))
    end

    it 'should return correct value with partial subsidy' do
      @order.interest_rate_subsidy = 0.5
      expect(@order.discount).to eq(Money.new(12_867))
      expect(@order.interest).to eq(Money.new(12_869))
      expect(@order.advance).to eq(Money.new(131_133))
      expect(@order.payment).to eq(Money.new(4367))
    end
  end

  context 'order items validations' do
    before do
      @vendor = create(:vendor)
      @product = create(:product, vendor: @vendor)
      @customer = create(:customer, vendor: @vendor)
    end
    it 'should validate order amount by checking order items amount' do
      @order = create(:order, customer: @customer, interest_rate: 0.12, interest_rate_subsidy: 1, amount: 1200)
      expect(@order.valid?).to be true
      @order.order_items.first.update!(quantity: 2)
      expect(@order.valid?).to be false
      @order.order_items.first.destroy!
      create(:order_item, order: @order, quantity: 1, unit_price: 600)
      create(:order_item, order: @order, quantity: 1, unit_price: 600)
      expect(@order.reload.valid?).to be true
    end

    it 'should validate order amount by checking order items amount' do
      @order = create(:order, customer: @customer, interest_rate: 0.12, interest_rate_subsidy: 1, amount: 1440)
      expect(@order.valid?).to be true
      create(:order_item, order: @order, quantity: 1, unit_price: 440)
      create(:order_item, order: @order, quantity: 2, unit_price: 500)
      expect(@order.reload.valid?).to be false
    end
  end

  context 'Pull Middesk', type: :request do
    before do
      @vendor = create(:vendor)
      @product = create(:product, vendor: @vendor)
      @customer = create(:customer, vendor: @vendor)
      @contact = create(:contact, customer: @customer)
      @order = create(:order, customer: @contact.customer)
    end

    it 'should create middesk id for customer' do
      @order.pull_middesk
      expect(@customer.middesk_id).to eq(JSON.parse(File.read(Rails.root.join('spec', 'fixtures', 'middesk_vartana.json')))['id'])
    end
  end
end
