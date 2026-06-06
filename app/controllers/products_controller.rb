class ProductsController < ApplicationController
  def index
    @products = Product.active.order(created_at: :desc)
    @products = @products.where(category: params[:category]) if params[:category].present?
    @categories = Product::CATEGORIES
  end

  def show
    @product = Product.active.includes(:variants).find_by!(slug: params[:id])
    @variants = @product.variants.order(:id)
  end
end
