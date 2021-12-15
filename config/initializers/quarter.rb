class Integer
  # Add a quarter method to handle adding and subtracting quarters easily, just like we already can with months.
  # Each quarter is equivalent to 3.months.
  #
  # Use in singular form, like Date.today + 1.quarter, or in plural form, like Date.today + 3.quarters.
  #
  def quarter
    (self * 3).months
  end
  alias quarters quarter
end
