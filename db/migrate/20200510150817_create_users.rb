class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :email
      t.string :name
      t.text   :jwt_token
      t.string :password_hash
      t.string :password_salt

      t.timestamps
    end
  end
end
