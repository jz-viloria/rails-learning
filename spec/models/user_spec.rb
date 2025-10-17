require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      user = build(:user)
      expect(user).to be_valid
    end

    it 'is invalid without a first name' do
      user = build(:user, first_name: nil)
      expect(user).not_to be_valid
      expect(user.errors[:first_name]).to include("can't be blank")
    end

    it 'is invalid without a last name' do
      user = build(:user, last_name: nil)
      expect(user).not_to be_valid
      expect(user.errors[:last_name]).to include("can't be blank")
    end

    it 'is invalid without an email' do
      user = build(:user, email: nil)
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("can't be blank")
    end

    it 'is invalid with an invalid email format' do
      user = build(:user, email: 'invalid-email')
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include('is invalid')
    end

    it 'is invalid with a duplicate email' do
      create(:user, email: 'test@example.com')
      user = build(:user, email: 'test@example.com')
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include('has already been taken')
    end

    it 'is invalid with a short password' do
      user = build(:user, password: '12345')
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include('is too short (minimum is 6 characters)')
    end

    it 'is invalid with a first name shorter than 2 characters' do
      user = build(:user, first_name: 'A')
      expect(user).not_to be_valid
      expect(user.errors[:first_name]).to include('is too short (minimum is 2 characters)')
    end
  end

  describe 'associations' do
    it 'has many orders' do
      expect(User.reflect_on_association(:orders).macro).to eq(:has_many)
    end
  end

  describe 'scopes' do
    let!(:active_user) { create(:user, active: true) }
    let!(:inactive_user) { create(:user, active: false) }
    let!(:recent_user) { create(:user, last_login_at: 1.day.ago) }
    let!(:old_user) { create(:user, last_login_at: 2.months.ago) }

    describe '.active' do
      it 'returns only active users' do
        expect(User.active).to include(active_user)
        expect(User.active).not_to include(inactive_user)
      end
    end

    describe '.recent_login' do
      it 'returns only users who logged in recently' do
        expect(User.recent_login).to include(recent_user)
        expect(User.recent_login).not_to include(old_user)
      end
    end
  end

  describe 'instance methods' do
    let(:user) { build(:user, first_name: 'John', last_name: 'Doe') }

    describe '#full_name' do
      it 'returns the full name' do
        expect(user.full_name).to eq('John Doe')
      end
    end

    describe '#full_address' do
      it 'returns nil when no address is provided' do
        expect(user.full_address).to be_nil
      end

      it 'returns formatted address when address is provided' do
        user.address_line1 = '123 Main St'
        user.city = 'Anytown'
        user.state = 'CA'
        user.zip_code = '12345'
        user.country = 'US'

        expected_address = "123 Main St\nAnytown, CA 12345\nUS"
        expect(user.full_address).to eq(expected_address)
      end
    end

    describe '#recent_orders' do
      let(:user) { create(:user) }
      let!(:old_order) { create(:order, user: user, created_at: 1.month.ago) }
      let!(:recent_order1) { create(:order, user: user, created_at: 1.day.ago) }
      let!(:recent_order2) { create(:order, user: user, created_at: 2.days.ago) }

      it 'returns recent orders in descending order' do
        recent_orders = user.recent_orders(2)
        expect(recent_orders).to eq([recent_order1, recent_order2])
        expect(recent_orders).not_to include(old_order)
      end
    end

    describe '#total_spent' do
      let(:user) { create(:user) }
      let!(:order1) { create(:order, user: user, total_amount: 100.0) }
      let!(:order2) { create(:order, user: user, total_amount: 50.0) }

      it 'returns the total amount spent' do
        expect(user.total_spent).to eq(150.0)
      end
    end

    describe '#order_count' do
      let(:user) { create(:user) }
      let!(:order1) { create(:order, user: user) }
      let!(:order2) { create(:order, user: user) }

      it 'returns the number of orders' do
        expect(user.order_count).to eq(2)
      end
    end
  end

  describe 'callbacks' do
    it 'normalizes email to lowercase' do
      user = create(:user, email: 'TEST@EXAMPLE.COM')
      expect(user.email).to eq('test@example.com')
    end

    it 'normalizes phone number by removing non-digits' do
      user = create(:user, phone: '(555) 123-4567')
      expect(user.phone).to eq('5551234567')
    end
  end
end
