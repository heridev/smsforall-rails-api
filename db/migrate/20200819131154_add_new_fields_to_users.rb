class AddNewFieldsToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :registration_pin_code, :string, default: ''
    add_column :users, :status, :string, default: 'pending_confirmation'
    add_column :users, :signup_completed_at, :datetime
    add_column :users, :registration_pin_code_sent_at, :datetime
    add_column :users, :account_blocked_at, :datetime
    remove_column :users, :activation_in_progress
    remove_column :users, :main_api_token_salt
    remove_column :users, :secondary_api_token_salt
  end
end
