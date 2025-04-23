class HistoricalValue < ApplicationRecord
  belongs_to :portfolio

  validates :date, presence: true
  validates :amount, presence: true, numericality: true
end
