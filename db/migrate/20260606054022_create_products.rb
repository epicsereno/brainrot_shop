class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.string :title, null: false
      t.string :slug, null: false
      t.text :description
      t.integer :base_price_cents, null: false, default: 0
      t.string :category
      t.boolean :active, null: false, default: true

      t.timestamps
    end
    add_index :products, :slug, unique: true
  end
end
