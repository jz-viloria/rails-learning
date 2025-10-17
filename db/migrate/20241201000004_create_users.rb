class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      # Basic user information
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email, null: false
      t.string :phone
      
      # Authentication
      t.string :password_digest, null: false
      
      # Address information
      t.string :address_line1
      t.string :address_line2
      t.string :city
      t.string :state
      t.string :zip_code
      t.string :country, default: 'US'
      
      # User preferences
      t.boolean :email_notifications, default: true
      t.boolean :sms_notifications, default: false
      
      # Account status
      t.boolean :active, default: true
      t.datetime :last_login_at
      
      # Timestamps
      t.timestamps
    end
    
    # Add indexes for better performance
    add_index :users, :email, unique: true
    add_index :users, :phone
    add_index :users, :active
    add_index :users, :last_login_at
  end
end
