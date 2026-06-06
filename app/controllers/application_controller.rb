class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  helper_method :current_cart

  private

  def current_cart
    @current_cart ||= Cart.new(session[:cart] ||= {})
  end
end
