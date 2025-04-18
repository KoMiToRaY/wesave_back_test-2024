# frozen_string_literal: true

module Api
  module V1
    class PortfoliosController < ApplicationController
      before_action :set_portfolio, only: [:deposit]
      before_action :ensure_arbitrable_portfolio, only: [:deposit]

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
