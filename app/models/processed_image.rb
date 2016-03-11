class ProcessedImage < ActiveRecord::Base
  belongs_to :template, class_name: ImageTemplate
  belongs_to :embed_rule

  mount_uploader :image, ProcessedImageUploader
  validates :template_id, :image, presence: true

  attr_accessor :prev_image_id
end
