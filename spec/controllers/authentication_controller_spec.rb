require 'rails_helper'

RSpec.describe AuthenticationController, type: :controller do
  describe 'GET #new' do
    it 'returns http success' do
      get :new
      expect(response).to have_http_status(:success)
    end

    it 'assigns a new user' do
      get :new
      expect(assigns(:user)).to be_a_new(User)
    end

    it 'renders the new template' do
      get :new
      expect(response).to render_template(:new)
    end
  end

  describe 'POST #create' do
    context 'with valid attributes' do
      let(:valid_attributes) do
        {
          user: {
            first_name: 'John',
            last_name: 'Doe',
            email: 'john@example.com',
            password: 'password123',
            password_confirmation: 'password123'
          }
        }
      end

      it 'creates a new user' do
        expect {
          post :create, params: valid_attributes
        }.to change(User, :count).by(1)
      end

      it 'sets the user in session' do
        post :create, params: valid_attributes
        expect(session[:user_id]).to eq(User.last.id)
      end

      it 'redirects to dashboard' do
        post :create, params: valid_attributes
        expect(response).to redirect_to(dashboard_path)
      end

      it 'sets a success notice' do
        post :create, params: valid_attributes
        expect(flash[:notice]).to eq('Account created successfully! Welcome to our store!')
      end
    end

    context 'with invalid attributes' do
      let(:invalid_attributes) do
        {
          user: {
            first_name: '',
            last_name: '',
            email: 'invalid-email',
            password: '123',
            password_confirmation: '456'
          }
        }
      end

      it 'does not create a new user' do
        expect {
          post :create, params: invalid_attributes
        }.not_to change(User, :count)
      end

      it 'renders the new template' do
        post :create, params: invalid_attributes
        expect(response).to render_template(:new)
      end

      it 'assigns the user with errors' do
        post :create, params: invalid_attributes
        expect(assigns(:user)).to be_a(User)
        expect(assigns(:user).errors).not_to be_empty
      end
    end
  end

  describe 'GET #login' do
    it 'returns http success' do
      get :login
      expect(response).to have_http_status(:success)
    end

    it 'assigns a new user' do
      get :login
      expect(assigns(:user)).to be_a_new(User)
    end

    it 'renders the login template' do
      get :login
      expect(response).to render_template(:login)
    end
  end

  describe 'POST #authenticate' do
    let(:user) { create(:user, email: 'test@example.com', password: 'password123') }

    context 'with valid credentials' do
      it 'sets the user in session' do
        post :authenticate, params: { email: 'test@example.com', password: 'password123' }
        expect(session[:user_id]).to eq(user.id)
      end

      it 'redirects to dashboard' do
        post :authenticate, params: { email: 'test@example.com', password: 'password123' }
        expect(response).to redirect_to(dashboard_path)
      end

      it 'sets a success notice' do
        post :authenticate, params: { email: 'test@example.com', password: 'password123' }
        expect(flash[:notice]).to eq('Welcome back!')
      end

      it 'updates last login time' do
        expect {
          post :authenticate, params: { email: 'test@example.com', password: 'password123' }
        }.to change { user.reload.last_login_at }
      end
    end

    context 'with invalid credentials' do
      it 'does not set the user in session' do
        post :authenticate, params: { email: 'test@example.com', password: 'wrongpassword' }
        expect(session[:user_id]).to be_nil
      end

      it 'renders the login template' do
        post :authenticate, params: { email: 'test@example.com', password: 'wrongpassword' }
        expect(response).to render_template(:login)
      end

      it 'sets an alert message' do
        post :authenticate, params: { email: 'test@example.com', password: 'wrongpassword' }
        expect(flash[:alert]).to eq('Invalid email or password')
      end
    end
  end

  describe 'DELETE #logout' do
    let(:user) { create(:user) }

    before do
      session[:user_id] = user.id
    end

    it 'clears the user from session' do
      delete :logout
      expect(session[:user_id]).to be_nil
    end

    it 'redirects to root path' do
      delete :logout
      expect(response).to redirect_to(root_path)
    end

    it 'sets a success notice' do
      delete :logout
      expect(flash[:notice]).to eq('You have been logged out successfully')
    end
  end

  describe 'GET #dashboard' do
    let(:user) { create(:user) }

    before do
      session[:user_id] = user.id
    end

    it 'returns http success' do
      get :dashboard
      expect(response).to have_http_status(:success)
    end

    it 'assigns the current user' do
      get :dashboard
      expect(assigns(:user)).to eq(user)
    end

    it 'assigns recent orders' do
      get :dashboard
      expect(assigns(:recent_orders)).to eq(user.recent_orders(5))
    end

    it 'renders the dashboard template' do
      get :dashboard
      expect(response).to render_template(:dashboard)
    end
  end
end
