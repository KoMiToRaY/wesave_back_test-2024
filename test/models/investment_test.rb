require "test_helper"

class InvestmentTest < ActiveSupport::TestCase
  def setup
    @investment = Investment.new(
      label: "Apple Inc.",
      investment_type: "stock",
      isin: "FR0000120172",
      price: 150.0,
      sri: 5
    )
  end

  test "is valid with valid attributes" do
    assert @investment.valid?
  end

  test "is invalid without label" do
    @investment.label = nil
    assert_not @investment.valid?
  end

  test "is invalid without investment_type" do
    @investment.investment_type = nil
    assert_not @investment.valid?
  end

  test "is invalid without isin" do
    @investment.isin = nil
    assert_not @investment.valid?
  end

  test "is invalid without price" do
    @investment.price = nil
    assert_not @investment.valid?
  end

  test "is invalid with negative price" do
    @investment.price = -50
    assert_not @investment.valid?
  end

  test "is invalid without sri" do
    @investment.sri = nil
    assert_not @investment.valid?
  end

  test "isin must be unique" do
    @investment.save!
    duplicate = @investment.dup
    assert_not duplicate.valid?
  end
end
