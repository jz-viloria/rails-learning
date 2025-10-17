class OrderItem < ApplicationRecord
  # Associations
  belongs_to :order
  belongs_to :product
  
  # Validations
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :unit_price, presence: true, numericality: { greater_than: 0 }
  validates :total_price, presence: true, numericality: { greater_than: 0 }
  
  # Callbacks - these run automatically when certain events happen
  before_validation :set_unit_price
  before_validation :calculate_total_price
  
  # Instance methods
  def formatted_unit_price
    "$#{'%.2f' % unit_price}"
  end
  
  def formatted_total_price
    "$#{'%.2f' % total_price}"
  end
  
  private
  
  def set_unit_price
    self.unit_price = product.price if product
  end
  
  def calculate_total_price
    self.total_price = quantity * unit_price if quantity && unit_price
  end
end
