class CreateProcessedImages < ActiveRecord::Migration
  def change
    create_table :processed_images do |t|
      t.integer :template_id
      t.string :image

      t.timestamps
    end
  end
end
