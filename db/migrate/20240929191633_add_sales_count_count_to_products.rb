class AddSalesCountCountToProducts < ActiveRecord::Migration[7.2]
  def change
    add_column :products, :sales_count, :integer, null: false, default: 0
  end
end
