class AddTitleDescriptionToImageTemplate < ActiveRecord::Migration
  def change
    add_column :image_templates, :title, :string
    add_column :image_templates, :description, :text
  end
end
