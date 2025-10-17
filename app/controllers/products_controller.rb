class ProductsController < ApplicationController
  # This controller handles all requests related to products
  
  def index
    # This action shows all products (our homepage)
    @products = Product.all
    @featured_products = Product.featured.limit(3)
  end
  
  def show
    # This action shows a single product
    @product = Product.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    # If product not found, redirect to products page
    redirect_to products_path, alert: 'Product not found'
  end
end
