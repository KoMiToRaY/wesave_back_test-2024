# frozen_string_literal: true

class PortfolioFeeCalculator
  # The `attr_reader :portfolio` line creates a public getter method for the instance variable `@portfolio`,
  # allowing us to access it using `portfolio` instead of `@portfolio` within the class.
  attr_reader :portfolio

  def initialize(portfolio)
    @portfolio = portfolio
  end

  def current_rate
    case portfolio.total_amount
    when 0..5_000
      0.05
    when 5_000.01..7_500
      0.03
    when 7_500.01..10_000
      0.02
    else
      0.008
    end
  end

  def current_month_fee
    (portfolio.total_amount * current_rate).round(2)
  end

  def total_fees_paid
    # Sum of the fees for each past month
    portfolio.historical_values.sum do |hv|
      PortfolioFeeCalculator.new(OpenStruct.new(total_amount: hv.amount)).current_month_fee
    end.round(2)
  end
end
