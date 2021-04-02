class AddItemsToCarts < ActiveRecord::Migration[6.0]
    def change
      add_column :carts, :items, :string
    end
  end