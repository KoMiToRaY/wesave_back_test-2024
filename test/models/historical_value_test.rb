require "test_helper"

class HistoricalValueTest < ActiveSupport::TestCase
  def setup
    @customer = Customer.create!(name: "Test User")
    @portfolio = @customer.portfolios.create!(
      label: "Test Portfolio",
      portfolio_type: "CTO",
      total_amount: 1000
    )
  end

  test "is valid with valid attributes" do
    hv = @portfolio.historical_values.new(date: Date.today, amount: 1000)
    assert hv.valid?
  end

  test "is invalid without date" do
    hv = @portfolio.historical_values.new(amount: 1000)
    assert_not hv.valid?
  end

  test "is invalid without amount" do
    hv = @portfolio.historical_values.new(date: Date.today)
    assert_not hv.valid?
  end

  test "is invalid with negative amount" do
    hv = @portfolio.historical_values.new(date: Date.today, amount: -500)
    assert_not hv.valid?
  end

  test "belongs to a portfolio" do
    hv = HistoricalValue.new(date: Date.today, amount: 1000, portfolio: @portfolio)
    assert_equal @portfolio, hv.portfolio
  end
end
