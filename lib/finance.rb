class Finance
  attr_accessor :amount, :start_date, :end_date, :rate, :rate_subsidy, :bill_day
  attr_reader :term, :loan_value, :payment, :interest, :fees, :schedule, :num_pmts

  def initialize(amount:, start_date:, end_date:, rate:, rate_subsidy:, bill_day: nil)
    @amount       = amount
    @start_date   = start_date
    @end_date     = end_date
    @bill_day     = bill_day
    @rate         = rate
    @rate_subsidy = rate_subsidy
    @schedule     = []
    @term         = 0
    @bill_day   ||= start_date.day
  end

  def calculate
    delta     = bill_day - start_date.day
    s_date    = start_date
    e_date    = start_date + delta + (delta.positive? ? 0 : 1.month) - 1
    @num_pmts = 0

    while s_date < @end_date
      factor     = (e_date - s_date + 1) / ((s_date + 1.month) - s_date)
      @term     += factor
      @num_pmts += 1

      @schedule << OpenStruct.new({
        period: @num_pmts,
        start_date: s_date,
        end_date: e_date,
        factor: factor,
      })

      s_date = e_date + 1
      e_date = s_date + 1.month - 1
      e_date = @end_date if e_date > @end_date
    end

    vendor_rate = @rate_subsidy * @rate
    @loan_value = vendor_rate.zero? ? @amount : pv(vendor_rate / 12, @term, @amount / @term)
    @payment    = pmt(@rate / 12, @term, @loan_value)

    s_balance = @loan_value
    @fees     = 0
    @interest = 0
    @schedule.each do |s|
      s.start_balance = s_balance
      s.payment       = @payment * s.factor
      int_fees        = s.start_balance * (@rate / 12 * s.factor)
      s.fees          = s.start_balance * (vendor_rate / 12 * s.factor)
      s.interest      = int_fees - s.fees
      s.principal     = s.payment - int_fees
      s.end_balance   = s_balance - s.principal
      s_balance       = s.end_balance

      if s.period == @num_pmts
        s.principal   = s.start_balance
        s.end_balance = 0
      end

      @fees     += s.fees
      @interest += s.interest
    end

    true
  end

  def print
    puts "Period\tStart Date\tEnd Date\tStart Balance\tFactor\t\tPayment\t\tPrincipal\tInterest\tFees\tEnd Balance"
    @schedule.each do |s|
      puts "#{s.period}\t#{s.start_date}\t#{s.end_date}\t#{s.start_balance}\t\t#{s.factor}\t\t#{s.payment}\t\t#{s.principal}\t\t#{s.interest}\t\t#{s.fees}\t#{s.end_balance}"
    end

    true
  end

  private

  def pv(rate, num_periods, pmt)
    factor = (1 - (1 / (1 + rate)**num_periods)) / rate
    factor * pmt
  end

  def pmt(rate, num_periods, pv)
    if rate.zero?
      pv / num_periods
    else
      factor = (rate * (1 + rate)**num_periods) / ((1 + rate)**num_periods - 1)
      pv * factor
    end
  end
end
