# frozen_string_literal: true

class Portfolio < ApplicationRecord
  belongs_to :customer
  has_many :portfolio_investments, dependent: :destroy
  has_many :investments, through: :portfolio_investments
  has_many :historical_values, dependent: :destroy

  validates :label, presence: true
  validates :portfolio_type, presence: true
  validates :total_amount, presence: true, numericality: true

  def yield_global
    first = historical_values.order(:date).first
    last  = historical_values.order(:date).last

    return 0 if first.nil? || last.nil? || first.amount.zero?

    # réutilisation de la formule ($$Y = (\dfrac{Vc}{Vi} - 1) \times 100$$)
    # exprimée en LaTeX et trouvé dans le fichier LEVELS.md
    (((last.amount / first.amount) - 1) * 100).round(2)
  end
end
