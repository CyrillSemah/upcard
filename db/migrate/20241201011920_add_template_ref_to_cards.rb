class AddTemplateRefToCards < ActiveRecord::Migration[7.1]
  def change
    add_reference :cards, :template, null: false, foreign_key: true
  end
end
