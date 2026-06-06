class CartItemsController < ApplicationController
  before_action :set_variant, only: :create

  def create
    quantity = params.fetch(:quantity, 1).to_i
    current_cart.add(@variant.id, quantity)
    @notice = "Added #{@variant.display_name} to your cart 🛒"
    respond_after_change
  end

  def update
    current_cart.set_quantity(params[:id], params[:quantity])
    respond_after_change
  end

  def destroy
    current_cart.remove(params[:id])
    @notice = "Removed from cart"
    respond_after_change
  end

  private

  def set_variant
    @variant = Variant.find(params[:variant_id])
  end

  def respond_after_change
    @cart = current_cart
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to cart_path, notice: @notice }
    end
  end
end
