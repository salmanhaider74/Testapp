module Underwriting::Processors::Experian
  class Scores
    def initialize(order)
      @experian_data = order.documents.where(type: :experian).first.try(:json_data)
      @customer = order.customer
    end

    def days_beyond_term
      # results.paymentTotals.currentDbt
      @experian_data.dig('results', 'paymentTotals', 'currentDbt')
    end

    def failure_score
      # results.scoreInformation.fsrScore.score
      @experian_data.dig('results', 'scoreInformation', 'fsrScore', 'score')
    end

    def deliquency_score
      # results.scoreInformation.commercialScore.score
      @experian_data.dig('results', 'scoreInformation', 'commercialScore', 'score')
    end

    def years_in_business
      # results.businessFacts.yearsInBusiness
      @experian_data.dig('results', 'businessFacts', 'yearsInBusiness')
    end
  end
end
