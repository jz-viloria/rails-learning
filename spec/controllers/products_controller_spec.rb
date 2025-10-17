require 'rails_helper'

RSpec.describe ProductsController, type: :controller do
  describe 'GET #index' do
    let!(:featured_products) { create_list(:product, 3, :featured) }
    let!(:regular_products) { create_list(:product, 5, featured: false) }

    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end

    it 'assigns all products to @products' do
      get :index
      expect(assigns(:products)).to match_array(Product.all)
    end

    it 'assigns featured products to @featured_products' do
      get :index
      expect(assigns(:featured_products)).to match_array(featured_products)
    end

    it 'renders the index template' do
      get :index
      expect(response).to render_template(:index)
    end
  end

  describe 'GET #show' do
    let(:product) { create(:product) }

    context 'with valid product id' do
      it 'returns http success' do
        get :show, params: { id: product.id }
        expect(response).to have_http_status(:success)
      end

      it 'assigns the requested product to @product' do
        get :show, params: { id: product.id }
        expect(assigns(:product)).to eq(product)
      end

      it 'renders the show template' do
        get :show, params: { id: product.id }
        expect(response).to render_template(:show)
      end
    end

    context 'with invalid product id' do
      it 'redirects to products index' do
        get :show, params: { id: 99999 }
        expect(response).to redirect_to(products_path)
      end

      it 'sets flash alert message' do
        get :show, params: { id: 99999 }
        expect(flash[:alert]).to eq('Product not found')
      end
    end
  end
end
