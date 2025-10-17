class CreateOrderItems < ActiveRecord::Migration[6.0]
  def change
    create_table :order_items do |t|
      # References to order and product
      t.references :order, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      
      # Item details
      t.integer :quantity, null: false, default: 1
      t.decimal :unit_price, precision: 10, scale: 2, null: false
      t.decimal :total_price, precision: 10, scale: 2, null: false
      
      # Timestamps
      t.timestamps
    end
    
    # Add indexes
    add_index :order_items, [:order_id, :product_id], unique: true
  end
end
