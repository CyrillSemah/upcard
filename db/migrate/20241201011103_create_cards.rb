class CreateCards < ActiveRecord::Migration[7.1]
  def change
    create_table :cards do |t|
      t.string :title
      t.text :description
      t.datetime :event_date
      t.integer :status
      t.integer :event_type
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
