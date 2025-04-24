require "test_helper"

class PortfolioTest < ActiveSupport::TestCase
  def setup
    @customer = Customer.create!(name: "Jean Dupont")
  end

  test "is valid with label, portfolio_type and total_amount" do
    portfolio = @customer.portfolios.new(
      label: "Portefeuille Avenir",
      portfolio_type: "CTO",
      total_amount: 15000
    )

    assert portfolio.valid?
  end

  test "is invalid without label" do
    portfolio = @customer.portfolios.new(
      label: nil,
      portfolio_type: "CTO",
      total_amount: 15000
    )

    assert_not portfolio.valid?
    assert_includes portfolio.errors[:label], "can't be blank"
  end

  test "belongs to a customer" do
    portfolio = Portfolio.reflect_on_association(:customer)
    assert_equal :belongs_to, portfolio.macro
  end

  # test de relation / association
  test "can have many investments through portfolio_investments" do
    investment1 = Investment.create!(
      label: "Apple Inc.",
      investment_type: "stock",
      isin: "FR0000123456",
      price: 150.0,
      sri: 5
    )

    investment2 = Investment.create!(
      label: "Obligation d'État",
      investment_type: "bond",
      isin: "FR0000654321",
      price: 100.0,
      sri: 2
    )

    portfolio = @customer.portfolios.create!(
      label: "Test Portfolio",
      portfolio_type: "CTO",
      total_amount: 10000.0
    )

    portfolio.portfolio_investments.create!(investment: investment1, amount: 3000)
    portfolio.portfolio_investments.create!(investment: investment2, amount: 2000)

    assert_equal 2, portfolio.investments.count
    assert_includes portfolio.investments, investment1
    assert_includes portfolio.investments, investment2
  end
end