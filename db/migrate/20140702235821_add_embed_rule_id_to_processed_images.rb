class AddEmbedRuleIdToProcessedImages < ActiveRecord::Migration
  def change
    add_column :processed_images, :embed_rule_id, :integer
  end
end
