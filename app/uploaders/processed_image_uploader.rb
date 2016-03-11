# encoding: utf-8

class ProcessedImageUploader < CarrierWave::Uploader::Base

  # Include RMagick or MiniMagick support:
  include CarrierWave::RMagick
  # include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  storage :file
  # storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/processed_images/#{model.id}"
  end

  process :merge_with_template

  def merge_with_template
    p "processing"
    p model.prev_image_id

    unless model.prev_image_id
      template = model.template
      image_path = template.image.with_placeholder.path
    else
      image_path = ProcessedImage.find(model.prev_image_id).image.path
    end
    img     = Magick::Image::read(image_path).first
    overlay = Magick::Image::read(@file.file).first
    embed_rule = model.embed_rule
    overlay.resize!(embed_rule.destination_size_x, embed_rule.destination_size_y)
    overlay.virtual_pixel_method = Magick::TransparentVirtualPixelMethod
    overlay = overlay.distort(Magick::PerspectiveDistortion, embed_rule.destination_points, false)
    overlay.background_color = 'black'
    overlay = overlay.transparent('black')
    img.composite!(overlay, embed_rule.composite_position_x, embed_rule.composite_position_y, Magick::OverCompositeOp)

    img.write(@file.file)
  end

  def extension_white_list
    %w(jpg jpeg png)
  end

end
