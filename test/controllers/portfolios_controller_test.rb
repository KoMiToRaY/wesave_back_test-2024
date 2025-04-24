require "test_helper"

class PortfoliosControllerTest < ActionDispatch::IntegrationTest
  def setup
    @customer = Customer.create!(name: "Test User")

    @investment = Investment.create!(
      label: "Test Investment",
      investment_type: "stock",
      isin: "FR0000000001",
      price: 100.0,
      sri: 3
    )

    @portfolio = @customer.portfolios.create!(
      label: "CTO Test",
      portfolio_type: "CTO",
      total_amount: 1000
    )

    @portfolio_investment = @portfolio.portfolio_investments.create!(
      investment: @investment,
      amount: 1000
    )
  end

  test "should get title for customer" do
    get customer_portfolios_path(@customer)

    assert_response :success
    assert_select "div.c-portfolio h2", text: "CTO Test"
  end

  test "should deposit amount to an investment" do
    post deposit_portfolio_path(@portfolio), params: {
      investment_id: @investment.id,
      amount: 500
    }

    @portfolio.reload
    updated_line = @portfolio.portfolio_investments.find_by(investment_id: @investment.id)

    assert_equal 1500, updated_line.amount
    assert_equal 1500, @portfolio.total_amount
  end

  test "should withdraw amount from an investment" do
    post withdraw_portfolio_path(@portfolio), params: {
      investment_id: @investment.id,
      amount: 400
    }

    @portfolio.reload
    updated_line = @portfolio.portfolio_investments.find_by(investment_id: @investment.id)

    assert_equal 600, updated_line.amount
    assert_equal 600, @portfolio.total_amount
  end

  test "should move amount from one investment to another" do
    to_investment = Investment.create!(
      label: "Second Investment",
      investment_type: "bond",
      isin: "FR0000000002",
      price: 200.0,
      sri: 2
    )

    to_line = @portfolio.portfolio_investments.create!(
      investment: to_investment,
      amount: 500
    )

    post move_portfolio_path(@portfolio), params: {
      from_id: @investment.id,
      to_id: to_investment.id,
      amount: 300
    }

    @portfolio.reload
    from_line = @portfolio.portfolio_investments.find_by(investment_id: @investment.id)
    to_line = @portfolio.portfolio_investments.find_by(investment_id: to_investment.id)

    assert_equal 700, from_line.amount
    assert_equal 800, to_line.amount
    assert_equal 1500, @portfolio.total_amount
  end
end
