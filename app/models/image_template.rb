class ImageTemplate < ActiveRecord::Base
  mount_uploader :image, ImageTemplateUploader

  validates :image, presence: true

  has_many :processed_images, foreign_key: :template_id
  has_many :embed_rules, dependent: :destroy

  accepts_nested_attributes_for :embed_rules, allow_destroy: true
end
