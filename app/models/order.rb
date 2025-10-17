class Order < ApplicationRecord
  # Associations - this defines relationships between models
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items
  
  # Validations
  validates :customer_name, presence: true, length: { minimum: 2 }
  validates :customer_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :customer_phone, presence: true
  validates :total_amount, presence: true, numericality: { greater_than: 0 }
  validates :status, inclusion: { in: %w[pending processing shipped delivered cancelled] }
  
  # Address validations
  validates :shipping_address_line1, presence: true
  validates :shipping_city, presence: true
  validates :shipping_state, presence: true
  validates :shipping_zip_code, presence: true
  
  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :by_status, ->(status) { where(status: status) }
  
  # Instance methods
  def formatted_total
    "$#{'%.2f' % total_amount}"
  end
  
  def full_shipping_address
    address_parts = [
      shipping_address_line1,
      shipping_address_line2,
      "#{shipping_city}, #{shipping_state} #{shipping_zip_code}",
      shipping_country
    ].compact
    
    address_parts.join("\n")
  end
  
  def can_be_cancelled?
    %w[pending processing].include?(status)
  end
  
  def calculate_total!
    self.total_amount = order_items.sum(&:total_price)
    save!
  end
end
