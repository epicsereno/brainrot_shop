class Product < ApplicationRecord
  CATEGORIES = %w[tee hoodie hat poster sticker].freeze

  has_many :variants, dependent: :destroy
  has_one_attached :image

  validates :title, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :base_price_cents, numericality: { greater_than_or_equal_to: 0 }
  validates :category, inclusion: { in: CATEGORIES }, allow_blank: true

  before_validation :set_slug, if: -> { slug.blank? && title.present? }

  scope :active, -> { where(active: true) }

  def to_param
    slug
  end

  def base_price
    base_price_cents.to_i / 100.0
  end

  private

  def set_slug
    base = title.parameterize
    candidate = base
    i = 2
    while Product.where(slug: candidate).where.not(id: id).exists?
      candidate = "#{base}-#{i}"
      i += 1
    end
    self.slug = candidate
  end
end
