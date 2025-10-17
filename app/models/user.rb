class User < ApplicationRecord
  # Authentication
  has_secure_password
  
  # Associations
  has_many :orders, dependent: :destroy
  
  # Validations
  validates :first_name, presence: true, length: { minimum: 2 }
  validates :last_name, presence: true, length: { minimum: 2 }
  validates :email, presence: true, 
            format: { with: URI::MailTo::EMAIL_REGEXP },
            uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }
  
  # Address validations (optional)
  validates :city, presence: true, if: -> { address_line1.present? }
  validates :state, presence: true, if: -> { address_line1.present? }
  validates :zip_code, presence: true, if: -> { address_line1.present? }
  
  # Scopes
  scope :active, -> { where(active: true) }
  scope :recent_login, -> { where('last_login_at > ?', 30.days.ago) }
  
  # Callbacks
  before_save :normalize_email
  before_save :normalize_phone
  
  # Instance methods
  def full_name
    "#{first_name} #{last_name}"
  end
  
  def full_address
    return nil unless address_line1.present?
    
    address_parts = [
      address_line1,
      address_line2,
      "#{city}, #{state} #{zip_code}",
      country
    ].compact
    
    address_parts.join("\n")
  end
  
  def recent_orders(limit = 5)
    orders.order(created_at: :desc).limit(limit)
  end
  
  def total_spent
    orders.sum(:total_amount)
  end
  
  def order_count
    orders.count
  end
  
  def update_last_login!
    update!(last_login_at: Time.current)
  end
  
  private
  
  def normalize_email
    self.email = email.downcase.strip if email.present?
  end
  
  def normalize_phone
    self.phone = phone.gsub(/\D/, '') if phone.present?
  end
end
