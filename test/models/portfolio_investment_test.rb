require "test_helper"

class PortfolioInvestmentTest < ActiveSupport::TestCase
  def setup
    @customer = Customer.create!(name: "Test User")
    @portfolio = @customer.portfolios.create!(
      label: "PEA Test",
      portfolio_type: "PEA",
      total_amount: 10000
    )
    @investment = Investment.create!(
      label: "Apple",
      investment_type: "stock",
      isin: "FR0000123456",
      price: 150.0,
      sri: 5
    )
  end

  test "is valid with valid attributes" do
    pi = PortfolioInvestment.new(portfolio: @portfolio, investment: @investment, amount: 2000)
    assert pi.valid?
  end

  test "is invalid without portfolio" do
    pi = PortfolioInvestment.new(investment: @investment, amount: 2000)
    assert_not pi.valid?
  end

  test "is invalid without investment" do
    pi = PortfolioInvestment.new(portfolio: @portfolio, amount: 2000)
    assert_not pi.valid?
  end

  test "is invalid without amount" do
    pi = PortfolioInvestment.new(portfolio: @portfolio, investment: @investment)
    assert_not pi.valid?
  end

  test "is invalid with negative amount" do
    pi = PortfolioInvestment.new(portfolio: @portfolio, investment: @investment, amount: -500)
    assert_not pi.valid?
  end

  test "prevents duplicate investments in same portfolio" do
    PortfolioInvestment.create!(portfolio: @portfolio, investment: @investment, amount: 1000)
    duplicate = PortfolioInvestment.new(portfolio: @portfolio, investment: @investment, amount: 1000)
    assert_not duplicate.valid?
  end
end
