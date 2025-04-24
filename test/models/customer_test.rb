require "test_helper"

class CustomerTest < ActiveSupport::TestCase
  test "is valid with valid attributes" do
    customer = Customer.new(name: "Jean Dupont")
    assert customer.valid?
  end

  test "is invalid without name" do
    customer = Customer.new
    assert_not customer.valid?
  end

  test "has many portfolios" do
    customer = Customer.create!(name: "Investor")
    customer.portfolios.create!(label: "PEA", portfolio_type: "PEA", total_amount: 1000)

    assert_equal 1, customer.portfolios.count
  end
end
