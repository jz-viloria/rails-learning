class Product < ApplicationRecord
  # This is our Product model - it represents a product in our dropshipping store
  
  # Associations - relationships with other models
  has_many :order_items, dependent: :destroy
  has_many :orders, through: :order_items
  
  # Validations - these ensure data quality
  validates :name, presence: true, length: { minimum: 2 }
  validates :description, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :image_url, presence: true
  
  # Scopes - these are like saved database queries
  scope :featured, -> { where(featured: true) }
  scope :in_stock, -> { where('stock_quantity > 0') }
  
  # Instance methods - these are actions we can call on a product
  def in_stock?
    stock_quantity > 0
  end
  
  def formatted_price
    "$#{'%.2f' % price}"
  end
  
  def low_stock?
    stock_quantity < 10
  end
end
