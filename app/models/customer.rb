# frozen_string_literal: true

class Customer < ApplicationRecord
  has_many :portfolios

  validates :name, presence: true
end
