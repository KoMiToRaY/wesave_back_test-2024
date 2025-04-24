class Investment < ApplicationRecord
  has_many :portfolio_investments
  has_many :portfolios, through: :portfolio_investments

  validates :label, presence: true
  validates :investment_type, presence: true
  validates :isin, presence: true, uniqueness: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :sri, presence: true
end
