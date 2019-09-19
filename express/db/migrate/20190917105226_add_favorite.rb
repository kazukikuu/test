class AddFavorite < ActiveRecord::Migration[5.2]
  def change
    add_column :histories, :favorite, :booleam, default: false
  end
end
