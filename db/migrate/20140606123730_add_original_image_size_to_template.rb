class AddOriginalImageSizeToTemplate < ActiveRecord::Migration
  def change
    add_column :image_templates, :original_height, :integer
    add_column :image_templates, :original_width, :integer
  end
end
