class PortfoliosController < ApplicationController
  def index
    ap Customer.all
    @customer = Customer.find(params[:customer_id])

    ap @customer.portfolios
    @portfolios = @customer.portfolios.includes(portfolio_investments: :investment)
  end
end
