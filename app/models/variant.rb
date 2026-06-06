class Variant < ApplicationRecord
  belongs_to :product

  validates :label, presence: true
  validates :price_cents, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  # Falls back to the product's base price when no per-variant override is set.
  def effective_price_cents
    price_cents.presence || product.base_price_cents
  end

  def price
    effective_price_cents.to_i / 100.0
  end

  def display_name
    "#{product.title} — #{label}"
  end
end
