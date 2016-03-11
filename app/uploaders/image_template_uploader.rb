# encoding: utf-8

class ImageTemplateUploader < CarrierWave::Uploader::Base
  include Rails.application.routes.url_helpers
  # Include RMagick or MiniMagick support:
  include CarrierWave::RMagick
  # include CarrierWave::MiniMagick

  process :store_geometry
  # Choose what kind of storage to use for this uploader:
  storage :file
  # storage :fog

  version :with_placeholder do
    process :add_placeholder_img
  end

  version :small, from_version: :with_placeholder do
    process resize_to_limit: [420, 258]
    process convert: 'png'
  end

  def store_dir
    "uploads/templates/#{model.id}"
  end


  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    %w(jpg jpeg png)
  end

  private

  def store_geometry
    img = ::Magick::Image::read(@file.file).first
    if model
      model.original_width  = img.columns
      model.original_height = img.rows
    end
  end

  def add_placeholder_img
    return if model.new_record?
    img = ::Magick::Image::read(@file.file).first
    
    # rendering placeholder image from url:
    path = Rails.root.join('public', 'placeholder.html')
    render_output = Rails.root.join('tmp', 'render_output.png')
    for rule in model.embed_rules
      Rasterizer.render(path, render_output, rule.destination_size_x, rule.destination_size_y)
      placeholder  = Magick::Image::read(render_output).first
      placeholder.resize!(rule.destination_size_x, rule.destination_size_y)
      placeholder.virtual_pixel_method = Magick::TransparentVirtualPixelMethod
      placeholder = placeholder.distort(Magick::PerspectiveDistortion, rule.destination_points, false)
      placeholder.background_color = "black"
      placeholder = placeholder.transparent("black")
      img.composite!(placeholder, rule.composite_position_x, rule.composite_position_y, Magick::OverCompositeOp)
    end
    img.write(@file.file)
  end

end
