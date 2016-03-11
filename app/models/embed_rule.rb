class EmbedRule < ActiveRecord::Base

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