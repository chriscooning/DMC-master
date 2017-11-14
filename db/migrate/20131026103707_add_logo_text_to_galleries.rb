class AddLogoTextToGalleries < ActiveRecord::Migration
  def change
    add_column :galleries, :logo_text, :string
  end
end
