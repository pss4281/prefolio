class CreateImageTemplates < ActiveRecord::Migration
  def change
    create_table :image_templates do |t|
      t.string :image
      t.string :transparency_color
      t.text :destination_points
      t.integer :composite_position_x
      t.integer :composite_position_y
      t.integer :destination_size_x
      t.integer :destination_size_y
      t.string :background_color

      t.timestamps
    end
  end
end
