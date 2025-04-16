class PortfolioInvestment < ApplicationRecord
  belongs_to :portfolio
  belongs_to :investment
end
