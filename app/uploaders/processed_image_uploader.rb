# encoding: utf-8

class ProcessedImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::RMagick

  storage :file

  def store_dir
    "uploads/processed_images/#{model.id}"
  end

  process :merge_with_template

  def merge_with_template
    image_path =
      unless model.prev_image_id.present?
        template = model.template
        template.image.with_placeholder.path
      else
        ProcessedImage.find(model.prev_image_id).image.path
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
