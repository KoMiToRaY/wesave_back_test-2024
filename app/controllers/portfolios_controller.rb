# frozen_string_literal: true

class PortfoliosController < ApplicationController
  before_action :set_portfolio, only: [:arbitrage, :deposit]
  before_action :ensure_arbitrable_portfolio, only: [:arbitrage, :deposit]

  def index
    ap Customer.all
    @customer = Customer.find(params[:customer_id])

    ap @customer.portfolios
    @portfolios = @customer.portfolios.includes(portfolio_investments: :investment)
  end

  def deposit
    investment_line = @portfolio.portfolio_investments.find_by(investment_id: params[:investment_id])

    if investment_line
      investment_line.increment!(:amount, params[:amount].to_f)
      @portfolio.update!(total_amount: @portfolio.portfolio_investments.sum(:amount))
      @success_message = "Le dépôt a été effectué avec succès !"
    else
      @error_message = "Votre investissement est introuvable dans ce portefeuille."
    end

    @investments = @portfolio.portfolio_investments.includes(:investment)

    render :arbitrage
  end

  private

  def set_portfolio
    @portfolio = Portfolio.find(params[:id])
  end

  # TODO: factoriser avec l'API (Api::V1::PortfoliosController)
  # On pourrait extraire cette vérification dans un concern ou un service métier partagé
  def ensure_arbitrable_portfolio
    unless %w[CTO PEA].include?(@portfolio.portfolio_type)
      redirect_to root_path, alert: "Ce portefeuille ne permet pas l’arbitrage."
    end
  end
end
