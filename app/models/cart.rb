# Session-backed cart. Not an ActiveRecord model — it wraps the
# { "variant_id" => quantity } hash stored in the session so the MVP needs no
# checkout/persistence yet. Swap for a DB-backed Order at the payments stage.
class Cart
  LineItem = Struct.new(:variant, :quantity) do
    def subtotal_cents
      variant.effective_price_cents * quantity
    end

    def subtotal
      subtotal_cents / 100.0
    end
  end

  def initialize(store)
    # `store` is the session hash slot; keys are stringified variant ids.
    @store = store || {}
  end

  def add(variant_id, quantity = 1)
    id = variant_id.to_s
    @store[id] = (@store[id].to_i + quantity.to_i).clamp(1, 99)
  end

  def set_quantity(variant_id, quantity)
    id = variant_id.to_s
    qty = quantity.to_i
    if qty <= 0
      remove(variant_id)
    else
      @store[id] = qty.clamp(1, 99)
    end
  end

  def remove(variant_id)
    @store.delete(variant_id.to_s)
  end

  def line_items
    return [] if @store.empty?

    variants = Variant.where(id: @store.keys).includes(:product).index_by { |v| v.id.to_s }
    @store.filter_map do |variant_id, quantity|
      variant = variants[variant_id]
      LineItem.new(variant, quantity.to_i) if variant
    end
  end

  def count
    @store.values.sum(&:to_i)
  end

  def total_cents
    line_items.sum(&:subtotal_cents)
  end

  def total
    total_cents / 100.0
  end

  def empty?
    @store.empty?
  end
end
