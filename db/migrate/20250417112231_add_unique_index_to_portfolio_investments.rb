class AddUniqueIndexToPortfolioInvestments < ActiveRecord::Migration[7.1]
  def change
    add_index :portfolio_investments, [:portfolio_id, :investment_id], unique: true
  end
end
