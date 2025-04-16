class Investment < ApplicationRecord
  has_many :portfolio_investments
  has_many :portfolios, through: :portfolio_investments
end
