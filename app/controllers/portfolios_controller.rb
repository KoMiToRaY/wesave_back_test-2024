# frozen_string_literal: true

class PortfoliosController < ApplicationController
  helper RiskLabelHelper

  before_action :set_portfolio, only: [:arbitrage, :deposit, :withdraw, :move]
  before_action :ensure_arbitrable_portfolio, only: [:arbitrage, :deposit, :withdraw, :move]

  def index
    ap Customer.all
    @customer = Customer.find(params[:customer_id])

    ap @customer.portfolios
    @portfolios = @customer.portfolios.includes(portfolio_investments: :investment)

    @indicators = InvestmentAnalysis.call(@customer)
    @indicators_by_portfolio = @indicators[:portfolios].index_by { |p| p[:id] }
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

  def withdraw
    investment_line = @portfolio.portfolio_investments.find_by(investment_id: params[:investment_id])

    if investment_line.nil?
      @error_message = "Investissement introuvable dans ce portefeuille."
    elsif investment_line.amount < params[:amount].to_f
      @error_message = "Fonds insuffisants pour ce retrait."
    else
      investment_line.decrement!(:amount, params[:amount].to_f)
      @portfolio.update!(total_amount: @portfolio.portfolio_investments.sum(:amount))
      @success_message = "Le retrait a été effectué avec succès !"
    end

    @investments = @portfolio.portfolio_investments.includes(:investment)
    render :arbitrage
  end

  def move
    from = @portfolio.portfolio_investments.find_by(investment_id: params[:from_id])
    to   = @portfolio.portfolio_investments.find_by(investment_id: params[:to_id])
    amount = params[:amount].to_f

    if from.nil? || to.nil?
      @error_message = "Un ou les deux investissements sont introuvables dans ce portefeuille."
    elsif from.amount < amount
      @error_message = "Fonds insuffisants pour effectuer le transfert."
    else
      from.decrement!(:amount, amount)
      to.increment!(:amount, amount)
      @portfolio.update!(total_amount: @portfolio.portfolio_investments.sum(:amount))
      @success_message = "Le transfert effectué avec succès."
    end

    @investments = @portfolio.portfolio_investments.includes(:investment)
    render :arbitrage
  end

  def historical_values
    @portfolio = Portfolio.find(params[:id])
    @historical_values = @portfolio.historical_values.order(:date)
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
