class AddLocationToCards < ActiveRecord::Migration[7.1]
  def change
    add_column :cards, :location, :string
  end
end
