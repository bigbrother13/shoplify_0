class AddStripePriceIdToProducts < ActiveRecord::Migration[7.2]
  def change
    add_column :products, :stripe_price_id, :string
  end
end
