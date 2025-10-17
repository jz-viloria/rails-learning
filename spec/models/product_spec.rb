require 'rails_helper'

RSpec.describe Product, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      product = build(:product)
      expect(product).to be_valid
    end

    it 'is invalid without a name' do
      product = build(:product, name: nil)
      expect(product).not_to be_valid
      expect(product.errors[:name]).to include("can't be blank")
    end

    it 'is invalid without a description' do
      product = build(:product, description: nil)
      expect(product).not_to be_valid
      expect(product.errors[:description]).to include("can't be blank")
    end

    it 'is invalid without a price' do
      product = build(:product, price: nil)
      expect(product).not_to be_valid
      expect(product.errors[:price]).to include("can't be blank")
    end

    it 'is invalid with a negative price' do
      product = build(:product, price: -10.0)
      expect(product).not_to be_valid
      expect(product.errors[:price]).to include('must be greater than 0')
    end

    it 'is invalid without an image_url' do
      product = build(:product, image_url: nil)
      expect(product).not_to be_valid
      expect(product.errors[:image_url]).to include("can't be blank")
    end

    it 'is invalid with a name shorter than 2 characters' do
      product = build(:product, name: 'A')
      expect(product).not_to be_valid
      expect(product.errors[:name]).to include('is too short (minimum is 2 characters)')
    end
  end

  describe 'associations' do
    it 'has many order_items' do
      expect(Product.reflect_on_association(:order_items).macro).to eq(:has_many)
    end

    it 'has many orders through order_items' do
      expect(Product.reflect_on_association(:orders).macro).to eq(:has_many)
    end
  end

  describe 'scopes' do
    let!(:featured_product) { create(:product, featured: true) }
    let!(:regular_product) { create(:product, featured: false) }
    let!(:out_of_stock_product) { create(:product, stock_quantity: 0) }
    let!(:in_stock_product) { create(:product, stock_quantity: 10) }

    describe '.featured' do
      it 'returns only featured products' do
        expect(Product.featured).to include(featured_product)
        expect(Product.featured).not_to include(regular_product)
      end
    end

    describe '.in_stock' do
      it 'returns only products with stock' do
        expect(Product.in_stock).to include(in_stock_product)
        expect(Product.in_stock).not_to include(out_of_stock_product)
      end
    end
  end

  describe 'instance methods' do
    let(:product) { build(:product, stock_quantity: 5, price: 29.99) }

    describe '#in_stock?' do
      it 'returns true when stock_quantity is greater than 0' do
        expect(product.in_stock?).to be true
      end

      it 'returns false when stock_quantity is 0' do
        product.stock_quantity = 0
        expect(product.in_stock?).to be false
      end
    end

    describe '#formatted_price' do
      it 'returns formatted price with dollar sign' do
        expect(product.formatted_price).to eq('$29.99')
      end
    end

    describe '#low_stock?' do
      it 'returns true when stock_quantity is less than 10' do
        expect(product.low_stock?).to be true
      end

      it 'returns false when stock_quantity is 10 or more' do
        product.stock_quantity = 10
        expect(product.low_stock?).to be false
      end
    end
  end
end
