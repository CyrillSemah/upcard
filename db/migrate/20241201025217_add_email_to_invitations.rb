class AddEmailToInvitations < ActiveRecord::Migration[7.1]
  def change
    add_column :invitations, :email, :string
  end
end
