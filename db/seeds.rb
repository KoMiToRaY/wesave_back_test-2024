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
require 'json'

# Clean up
PortfolioInvestment.destroy_all
Portfolio.destroy_all
Investment.destroy_all
Customer.destroy_all

# create customer
# customer = Customer.create!(id: 1, name: Faker::Name.name)

# generate investments
# investments = 10.times.map do
#   Investment.create!(
#     label: Faker::Company.name,
#     investment_type: %w[stock bond euro_fund].sample,
#     isin: "FR#{Faker::Number.number(digits: 10)}",
#     price: rand(50.0..300.0).round(2),
#     sri: rand(1..7)
#   )
# end

# # generate multiple portfolio for the customer
# 3.times do
#   total = rand(10_000..50_000).round(2)
#   portfolio = customer.portfolios.create!(
#     label: "#{Faker::Bank.name} Portfolio",
#     portfolio_type: %w[CTO PEA Assurance_Vie].sample,
#     total_amount: total
#   )

#   # add 2 at 4 investments for the portfolio
#   investments.sample(rand(2..4)).each do |investment|
#     amount = rand(1000..total / 2)
#     portfolio.portfolio_investments.create!(
#       investment: investment,
#       amount: amount
#     )
#   end
# end

file = Rails.root.join("data/level_1/portfolios.json")
data = JSON.parse(File.read(file))

customer = Customer.create!(id: 1, name: Faker::Name.name)

data["contracts"].each do |contract|
  portfolio = customer.portfolios.create!(
    label: contract["label"],
    portfolio_type: contract["type"],
    total_amount: contract["amount"]
  )

  next unless contract["lines"]

  contract["lines"].each do |line|
    investment = Investment.find_or_create_by!(
      isin: line["isin"]
    ) do |inv|
      inv.label = line["label"]
      inv.investment_type = line["type"]
      inv.price = line["price"]
      inv.sri = line["srri"]
    end

    portfolio.portfolio_investments.create!(
      investment: investment,
      amount: line["amount"]
    )
  end
end

puts "Données du niveau 1 importées avec succès"

# import des valeurs du fichier historical_values (level 4)
file = Rails.root.join("data/level_4/historical_values.json")
data = JSON.parse(File.read(file))

data.each do |portfolio_label, entries|
  portfolio = Portfolio.find_by(label: portfolio_label)

  next unless portfolio

  entries.each do |entry|
    date = Date.strptime(entry["date"], "%d-%m-%y")
    amount = entry["amount"].to_f

    portfolio.historical_values.find_or_create_by!(date: date) do |hv|
      hv.amount = amount
    end
  end
end

puts "Données du niveau 4 importées avec succès"