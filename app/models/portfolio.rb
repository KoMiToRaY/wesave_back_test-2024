# frozen_string_literal: true

class Portfolio < ApplicationRecord
  belongs_to :customer
  has_many :portfolio_investments
  has_many :investments, through: :portfolio_investments
end
