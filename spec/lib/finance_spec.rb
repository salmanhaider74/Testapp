require 'rails_helper'

RSpec.describe Finance, type: :lib do
  context 'helper methods' do
    it 'returns payment, interest and schedule with subsidy = 0%  with no proration' do
      finance = Finance.new(amount: Money.new(1_000_000), start_date: Date.parse('2021-05-01'), end_date: Date.parse('2024-04-30'), rate: 0.1, rate_subsidy: 1)
      finance.calculate

      expect(finance.term).to eq(36)
      expect(finance.loan_value).to eq(Money.new(860_875))
      expect(finance.payment).to eq(Money.new(27_778))
      expect(finance.interest).to eq(Money.new(0))
      expect(finance.fees).to eq(Money.new(139_134))

      schedule = finance.schedule

      expect(schedule[0].period).to eq(1)
      expect(schedule[0].start_balance).to eq(Money.new(860_875))
      expect(schedule[0].payment).to eq(Money.new(27_778))
      expect(schedule[0].principal).to eq(Money.new(20_604))
      expect(schedule[0].interest).to eq(Money.new(0))
      expect(schedule[0].fees).to eq(Money.new(7174))
      expect(schedule[0].end_balance).to eq(Money.new(840_271))

      expect(schedule[-1].start_balance).to eq(Money.new(27_549))
      expect(schedule[-1].principal).to eq(Money.new(27_549))
      expect(schedule[-1].interest).to eq(Money.new(0))
      expect(schedule[-1].fees).to eq(Money.new(230))
      expect(schedule[-1].end_balance).to eq(Money.new(0))
    end

    it 'returns payment, interest and schedule with subsidy = 0%  with proration' do
      finance = Finance.new(amount: Money.new(500_000), start_date: Date.parse('2021-05-19'), end_date: Date.parse('2024-04-30'), rate: 0.1, rate_subsidy: 1, bill_day: 1)
      finance.calculate

      expect(finance.term.to_f.round(2)).to eq(35.42)
      expect(finance.loan_value).to eq(Money.new(431_434))
      expect(finance.payment).to eq(Money.new(14_117))
      expect(finance.interest).to eq(Money.new(0))
      expect(finance.fees).to eq(Money.new(68_570))

      schedule = finance.schedule
      expect(schedule[0].period).to eq(1)
      expect(schedule[0].start_balance).to eq(Money.new(431_434))
      expect(schedule[0].payment).to eq(Money.new(5920))
      expect(schedule[0].principal).to eq(Money.new(4412))
      expect(schedule[0].interest).to eq(Money.new(0))
      expect(schedule[0].fees).to eq(Money.new(1508))
      expect(schedule[0].end_balance).to eq(Money.new(427_022))

      expect(schedule[-1].start_balance).to eq(Money.new(13_989))
      expect(schedule[-1].principal).to eq(Money.new(13_989))
      expect(schedule[-1].interest).to eq(Money.new(0))
      expect(schedule[-1].fees).to eq(Money.new(117))
      expect(schedule[-1].end_balance).to eq(Money.new(0))
    end

    it 'returns payment, interest and schedule with subsidy = 50%  with no proration' do
      finance = Finance.new(amount: Money.new(1_000_000), start_date: Date.parse('2021-05-01'), end_date: Date.parse('2024-04-30'), rate: 0.1, rate_subsidy: 0.5)
      finance.calculate

      expect(finance.term).to eq(36)
      expect(finance.loan_value).to eq(Money.new(926_832))
      expect(finance.payment).to eq(Money.new(29_906))
      expect(finance.interest).to eq(Money.new(74_900))
      expect(finance.fees).to eq(Money.new(74_896))

      schedule = finance.schedule

      expect(schedule[0].period).to eq(1)
      expect(schedule[0].start_balance).to eq(Money.new(926_832))
      expect(schedule[0].payment).to eq(Money.new(29_906))
      expect(schedule[0].principal).to eq(Money.new(22_182))
      expect(schedule[0].interest).to eq(Money.new(3862))
      expect(schedule[0].fees).to eq(Money.new(3862))
      expect(schedule[0].end_balance).to eq(Money.new(904_650))

      expect(schedule[-1].start_balance).to eq(Money.new(29_671))
      expect(schedule[-1].principal).to eq(Money.new(29_671))
      expect(schedule[-1].interest).to eq(Money.new(123))
      expect(schedule[-1].fees).to eq(Money.new(124))
      expect(schedule[-1].end_balance).to eq(Money.new(0))
    end

    it 'returns payment, interest and schedule with subsidy = 50%  with proration' do
      finance = Finance.new(amount: Money.new(500_000), start_date: Date.parse('2021-05-19'), end_date: Date.parse('2024-04-30'), rate: 0.1, rate_subsidy: 0.5, bill_day: 1)
      finance.calculate

      expect(finance.term.to_f.round(2)).to eq(35.42)
      expect(finance.loan_value).to eq(Money.new(463_972))
      expect(finance.payment).to eq(Money.new(15_182))
      expect(finance.interest).to eq(Money.new(36_867))
      expect(finance.fees).to eq(Money.new(36_868))

      schedule = finance.schedule

      expect(schedule[0].period).to eq(1)
      expect(schedule[0].start_balance).to eq(Money.new(463_972))
      expect(schedule[0].payment).to eq(Money.new(6367))
      expect(schedule[0].principal).to eq(Money.new(4746))
      expect(schedule[0].interest).to eq(Money.new(810))
      expect(schedule[0].fees).to eq(Money.new(811))
      expect(schedule[0].end_balance).to eq(Money.new(459_226))

      expect(schedule[-1].start_balance).to eq(Money.new(15_027))
      expect(schedule[-1].principal).to eq(Money.new(15_027))
      expect(schedule[-1].interest).to eq(Money.new(62))
      expect(schedule[-1].fees).to eq(Money.new(63))
      expect(schedule[-1].end_balance).to eq(Money.new(0))
    end

    it 'returns payment, interest and schedule with subsidy = 0%  with no proration' do
      finance = Finance.new(amount: Money.new(1_000_000), start_date: Date.parse('2021-05-01'), end_date: Date.parse('2024-04-30'), rate: 0.1, rate_subsidy: 0)
      finance.calculate

      expect(finance.term).to eq(36)
      expect(finance.loan_value).to eq(Money.new(1_000_000))
      expect(finance.payment).to eq(Money.new(32_267))
      expect(finance.interest).to eq(Money.new(161_620))
      expect(finance.fees).to eq(Money.new(0))

      schedule = finance.schedule
      expect(schedule[0].period).to eq(1)
      expect(schedule[0].start_balance).to eq(Money.new(1_000_000))
      expect(schedule[0].payment).to eq(Money.new(32_267))
      expect(schedule[0].principal).to eq(Money.new(23_934))
      expect(schedule[0].interest).to eq(Money.new(8333))
      expect(schedule[0].fees).to eq(Money.new(0))
      expect(schedule[0].end_balance).to eq(Money.new(976_066))

      expect(schedule[-1].start_balance).to eq(Money.new(32_008))
      expect(schedule[-1].principal).to eq(Money.new(32_008))
      expect(schedule[-1].interest).to eq(Money.new(267))
      expect(schedule[-1].fees).to eq(Money.new(0))
      expect(schedule[-1].end_balance).to eq(Money.new(0))
    end

    it 'returns payment, interest and schedule with subsidy = 0%  with proration' do
      finance = Finance.new(amount: Money.new(500_000), start_date: Date.parse('2021-05-19'), end_date: Date.parse('2024-04-30'), rate: 0.1, rate_subsidy: 0, bill_day: 1)
      finance.calculate

      expect(finance.term.to_f.round(2)).to eq(35.42)
      expect(finance.loan_value).to eq(Money.new(500_000))
      expect(finance.payment).to eq(Money.new(16_361))
      expect(finance.interest).to eq(Money.new(79_461))
      expect(finance.fees).to eq(Money.new(0))

      schedule = finance.schedule
      expect(schedule[0].period).to eq(1)
      expect(schedule[0].start_balance).to eq(Money.new(500_000))
      expect(schedule[0].payment).to eq(Money.new(6861))
      expect(schedule[0].principal).to eq(Money.new(5114))
      expect(schedule[0].interest).to eq(Money.new(1747))
      expect(schedule[0].fees).to eq(Money.new(0))
      expect(schedule[0].end_balance).to eq(Money.new(494_886))

      expect(schedule[-1].start_balance).to eq(Money.new(16_191))
      expect(schedule[-1].principal).to eq(Money.new(16_191))
      expect(schedule[-1].interest).to eq(Money.new(135))
      expect(schedule[-1].fees).to eq(Money.new(0))
      expect(schedule[-1].end_balance).to eq(Money.new(0))
    end
  end
end
