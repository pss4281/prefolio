class EmbedRule < ActiveRecord::Base

  DEFAULT_ATTRIBUTES = {
    destination_points: %w(0 0 10 10 150 0 140 10 150 150 140 140 0 150 10 140),
    composite_position_x: 100,
    composite_position_y: 100,
    destination_size_x: 150,
    destination_size_y: 150
  } 

  belongs_to :image_template
  serialize :destination_points

  def destination_points
    (read_attribute(:destination_points) || []).map(&:to_i)
  end

  [:destination_size_x, :destination_size_y, :composite_position_x, :composite_position_y].each do |method_name|
    define_method method_name do
      read_attribute(method_name).to_i
    end
  end
end
