class AddApiTokenSaltFieldsToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :main_api_token_salt, :string
    add_column :users, :secondary_api_token_salt, :string

    User.where(main_api_token_salt: nil).each do |user|
      user.update_column(:main_api_token_salt, BCrypt::Engine.generate_salt)
      user.update_column(:secondary_api_token_salt, BCrypt::Engine.generate_salt)
    end
  end
end
