class AddFooterToGalleries < ActiveRecord::Migration[7.0]
  def change
    add_column :galleries, :footer, :text
  end
end
