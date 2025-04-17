# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

require 'faker'

# Clean up
PortfolioInvestment.destroy_all
Portfolio.destroy_all
Investment.destroy_all
Customer.destroy_all

# create customer
customer = Customer.create!(id: 1, name: Faker::Name.name)

# generate investments
investments = 10.times.map do
  Investment.create!(
    label: Faker::Company.name,
    investment_type: %w[stock bond euro_fund].sample,
    isin: "FR#{Faker::Number.number(digits: 10)}",
    price: rand(50.0..300.0).round(2),
    sri: rand(1..7)
  )
end

# generate multiple portfolio for the customer
3.times do
  total = rand(10_000..50_000).round(2)
  portfolio = customer.portfolios.create!(
    label: "#{Faker::Bank.name} Portfolio",
    portfolio_type: %w[CTO PEA Assurance_Vie].sample,
    total_amount: total
  )

  # add 2 at 4 investments for the portfolio
  investments.sample(rand(2..4)).each do |investment|
    amount = rand(1000..total / 2)
    portfolio.portfolio_investments.create!(
      investment: investment,
      amount: amount
    )
  end
end
