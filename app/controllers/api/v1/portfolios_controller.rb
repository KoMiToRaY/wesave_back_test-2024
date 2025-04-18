# frozen_string_literal: true

module Api
  module V1
    class PortfoliosController < ApplicationController
      before_action :set_portfolio, only: [:deposit, :withdraw, :move]
      before_action :ensure_arbitrable_portfolio, only: [:deposit, :withdraw, :move]

      def index
        file = Rails.root.join("data/level_1/portfolios.json")
        data = JSON.parse(File.read(file))
        render json: data
      end

      def deposit
        investment_line = @portfolio.portfolio_investments.find_by(investment_id: params[:investment_id])

        unless investment_line
          return render json: { error: "Investment not found in this portfolio" }, status: :not_found
        end

        amount = params[:amount].to_f
        investment_line.increment!(:amount, amount)

        @portfolio.update!(total_amount: @portfolio.portfolio_investments.sum(:amount))

        render json: {
          message: "Deposit successful",
          portfolio: PortfolioFormatter.call([@portfolio]).first
        }
      end

      def withdraw
        investment_line = @portfolio.portfolio_investments.find_by(investment_id: params[:investment_id])

        if investment_line.nil?
          return render json: { error: "Investment not found in this portfolio" }, status: :not_found
        end

        amount = params[:amount].to_f

        if investment_line.amount < amount
          return render json: { error: "Insufficient funds for withdrawal" }, status: :unprocessable_entity
        end

        investment_line.decrement!(:amount, amount)
        @portfolio.update!(total_amount: @portfolio.portfolio_investments.sum(:amount))

        render json: {
          message: "Withdrawal successful",
          portfolio: PortfolioFormatter.call([@portfolio]).first
        }
      end

      def move
        from = @portfolio.portfolio_investments.find_by(investment_id: params[:from_id])
        to   = @portfolio.portfolio_investments.find_by(investment_id: params[:to_id])
        amount = params[:amount].to_f

        if from.nil? || to.nil?
          return render json: { error: "One or both investments not found in this portfolio" }, status: :not_found
        end

        if from.amount < amount
          return render json: { error: "Insufficient funds in the source investment" }, status: :unprocessable_entity
        end

        from.decrement!(:amount, amount)
        to.increment!(:amount, amount)

        @portfolio.update!(total_amount: @portfolio.portfolio_investments.sum(:amount))

        render json: {
          message: "Funds moved successfully",
          portfolio: PortfolioFormatter.call([@portfolio]).first
        }
      end

      private

      def set_portfolio
        @portfolio = Portfolio.find(params[:id])
      end

      def ensure_arbitrable_portfolio
        unless %w[CTO PEA].include?(@portfolio.portfolio_type)
          render json: { error: "Arbitrage not allowed for this portfolio type" }, status: :forbidden
        end
      end
    end
  end
end
