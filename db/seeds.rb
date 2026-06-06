# Idempotent seed data for the Brainrot Shop catalog MVP.
# Run with: bin/rails db:seed

PRODUCTS = [
  {
    title: "Skibidi Toilet Tee",
    category: "tee",
    base_price_cents: 2499,
    description: "Premium cotton tee for the truly cooked. Wear it to confuse boomers.",
    variants: ["S / Black", "M / Black", "L / Black", "XL / Black"]
  },
  {
    title: "Gyatt Hoodie",
    category: "hoodie",
    base_price_cents: 4999,
    description: "Heavyweight fleece hoodie. Maximum gyatt, maximum warmth.",
    variants: ["S / Charcoal", "M / Charcoal", "L / Charcoal", "XL / Charcoal"]
  },
  {
    title: "Rizz Lord Dad Hat",
    category: "hat",
    base_price_cents: 2299,
    description: "Unstructured 6-panel cap with embroidered rizz. One size fits all (W).",
    variants: ["One Size"]
  },
  {
    title: "Sigma Grindset Poster",
    category: "poster",
    base_price_cents: 1799,
    description: "Museum-grade matte poster. Stare into it before your 4am ice bath.",
    variants: ["12x18", "18x24", "24x36"]
  },
  {
    title: "Ohio Final Boss Sticker Pack",
    category: "sticker",
    base_price_cents: 799,
    description: "Weatherproof vinyl sticker pack. Slap 'em wherever, only in Ohio.",
    variants: ["Pack of 5"]
  },
  {
    title: "Fanum Tax Tee",
    category: "tee",
    base_price_cents: 2499,
    description: "Soft-wash tee. They will tax your fanum, but never your drip.",
    variants: ["S / White", "M / White", "L / White", "XL / White"]
  }
]

PRODUCTS.each do |attrs|
  variants = attrs.delete(:variants)
  product = Product.find_or_initialize_by(slug: attrs[:title].parameterize)
  product.assign_attributes(attrs.merge(active: true))
  product.save!

  variants.each_with_index do |label, i|
    sku = "#{product.slug}-#{i + 1}".upcase.tr("-", "_")
    variant = product.variants.find_or_initialize_by(sku: sku)
    variant.update!(label: label)
  end
end

puts "Seeded #{Product.count} products / #{Variant.count} variants."
