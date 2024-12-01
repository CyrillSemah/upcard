class CreateInvitations < ActiveRecord::Migration[7.1]
  def change
    create_table :invitations do |t|
      t.references :card, null: false, foreign_key: true
      t.string :guest_email
      t.string :guest_name
      t.integer :status
      t.string :token

      t.timestamps
    end
  end
end
