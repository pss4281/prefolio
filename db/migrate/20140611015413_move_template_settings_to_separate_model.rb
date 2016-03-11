class MoveTemplateSettingsToSeparateModel < ActiveRecord::Migration
  def change
    create_table :embed_rules do |t|
      t.string :transparency_color
      t.text :destination_points
      t.integer :composite_position_x
      t.integer :composite_position_y
      t.integer :destination_size_x
      t.integer :destination_size_y
      t.string :background_color
      t.integer :image_template_id
    end

    ImageTemplate.all.each do |it|
      it.embed_rules << EmbedRule.new(
        transparency_color: it.transparency_color,
        background_color: it.background_color,
        destination_points: it.destination_points,
        composite_position_x: it.composite_position_x,
        composite_position_y: it.composite_position_y,
        destination_size_x: it.destination_size_x,
        destination_size_y: it.destination_size_y
      )
    end

    remove_column :image_templates, :transparency_color
    remove_column :image_templates, :destination_points
    remove_column :image_templates, :composite_position_x
    remove_column :image_templates, :composite_position_y
    remove_column :image_templates, :destination_size_x
    remove_column :image_templates, :destination_size_y
    remove_column :image_templates, :background_color
  end
end
