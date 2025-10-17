class CreateOrders < ActiveRecord::Migration[6.0]
  def change
    create_table :orders do |t|
      # Customer information
      t.string :customer_name, null: false
      t.string :customer_email, null: false
      t.string :customer_phone
      
      # Shipping address
      t.string :shipping_address_line1, null: false
      t.string :shipping_address_line2
      t.string :shipping_city, null: false
      t.string :shipping_state, null: false
      t.string :shipping_zip_code, null: false
      t.string :shipping_country, default: 'US'
      
      # Order details
      t.decimal :total_amount, precision: 10, scale: 2, null: false
      t.string :status, default: 'pending'
      t.text :notes
      
      # Timestamps
      t.timestamps
    end
    
    # Add indexes
    add_index :orders, :customer_email
    add_index :orders, :status
    add_index :orders, :created_at
  end
end
