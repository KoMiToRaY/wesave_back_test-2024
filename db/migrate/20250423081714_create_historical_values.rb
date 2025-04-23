class CreateHistoricalValues < ActiveRecord::Migration[7.1]
  def change
    create_table :historical_values do |t|
      t.references :portfolio, null: false, foreign_key: true
      t.date :date
      t.decimal :amount

      t.timestamps
    end
  end
end
