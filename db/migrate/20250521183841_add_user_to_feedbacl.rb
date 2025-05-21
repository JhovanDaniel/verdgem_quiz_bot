class AddUserToFeedbacl < ActiveRecord::Migration[7.1]
  def change
    add_reference :feedbacks, :user, type: :uuid, foreign_key: true
  end
end
