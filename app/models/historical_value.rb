class HistoricalValue < ApplicationRecord
  belongs_to :portfolio

  validates :date, presence: true
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
