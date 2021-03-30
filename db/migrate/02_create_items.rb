class CreateItems < ActiveRecord::Migration[6.0]
  def change
    create_table :items do |t|
      t.string :name
      t.decimal :price, :precision =>8, :scale =>2
      t.integer :user_id
    end
  end
end
