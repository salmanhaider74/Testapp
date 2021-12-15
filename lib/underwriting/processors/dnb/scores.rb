module Underwriting::Processors::Dnb
  class Scores
    def initialize(order)
      @dnb_data = order.documents.where(type: :duns).first.try(:json_data)
      @customer = order.customer
    end

    def paydex_score
      @dnb_data.dig('organization', 'businessTrading', 0, 'summary', 0, 'paydexScore')
    end

    def failure_score
      @dnb_data.dig('organization', 'dnbAssessment', 'failureScore', 'nationalPercentile')
    end

    def deliquency_score
      @dnb_data.dig('organization', 'dnbAssessment', 'delinquencyScore', 'nationalPercentile')
    end

    def years_in_business
      date_incorporated = @dnb_data.dig('organization', 'startDate')
      return date_incorporated if date_incorporated.nil?

      Date.today.year - date_incorporated.to_i
    end

    def employees
      @dnb_data.dig('organization', 'numberOfEmployees', 0, 'value')
    end

    def bankruptcy_filing
      @dnb_data.dig('organization', 'legalEvents', 'bankruptcy', 'periodSummary', '12Months', 'totalCount')
    end

    def judgements
      @dnb_data.dig('organization', 'legalEvents', 'judgments', 'periodSummary', '12Months', 'totalCount')
    end

    def liens
      @dnb_data.dig('organization', 'legalEvents', 'liens', 'periodSummary', '12Months', 'totalCount')
    end

    def suits
      @dnb_data.dig('organization', 'legalEvents', 'suits', 'periodSummary', '12Months', 'totalCount')
    end

    def entity_type
      return 'sole_prop' if @dnb_data.dig('organization', 'legalForm', 'description').present? && @dnb_data.dig('organization', 'legalForm', 'description') == 'Sole Proprietorship'

      @dnb_data.dig('organization', 'legalForm', 'description')
    end

    def annual_revenue
      @dnb_data['organization']['latestFinancials']['overview']['salesRevenue']
    rescue StandardError
      0.0
    end

    def net_worth
      @dnb_data['organization']['latestFinancials']['overview']['totalAssets'] - @dnb_data['organization']['latestFinancials']['overview']['totalLiabilities']
    rescue StandardError
      1
    end

    def dscr
      @dnb_data['organization']['latestFinancials']['overview']['netIncome'] / @dnb_data['organization']['latestFinancials']['overview']['longTermDebt']
    rescue StandardError
      1
    end

    def quick_ratio
      @dnb_data['organization']['latestFinancials']['overview']['accountsReceivable'] + @dnb_data['organization']['latestFinancials']['overview']['cashAndLiquidAssets'] / @dnb_data['organization']['latestFinancials']['overview']['totalLiabilities']
    rescue StandardError
      1
    end
  end
end
