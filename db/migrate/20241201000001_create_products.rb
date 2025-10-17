class CreateProducts < ActiveRecord::Migration[6.0]
  def change
    create_table :products do |t|
      # Basic product information
      t.string :name, null: false
      t.text :description, null: false
      t.decimal :price, precision: 10, scale: 2, null: false
      t.string :image_url, null: false
      
      # Inventory management
      t.integer :stock_quantity, default: 0
      t.boolean :featured, default: false
      
      # Metadata
      t.string :category
      t.string :brand
      t.string :sku, unique: true
      
      # Timestamps (created_at, updated_at)
      t.timestamps
    end
    
    # Add indexes for better performance
    add_index :products, :name
    add_index :products, :category
    add_index :products, :featured
    add_index :products, :sku, unique: true
  end
end
