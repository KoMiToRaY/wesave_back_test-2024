class PortfolioInvestment < ApplicationRecord
  belongs_to :portfolio
  belongs_to :investment

  validates :investment_id, uniqueness: { scope: :portfolio_id, message: "the investment has already been added to this portfolio" }
end
