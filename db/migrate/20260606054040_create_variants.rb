class CreateVariants < ActiveRecord::Migration[8.1]
  def change
    create_table :variants do |t|
      t.references :product, null: false, foreign_key: true
      t.string :label, null: false
      t.integer :price_cents
      t.string :sku

      t.timestamps
    end
    add_index :variants, :sku, unique: true
  end
end
