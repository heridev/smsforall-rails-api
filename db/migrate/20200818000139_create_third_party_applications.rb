class CreateThirdPartyApplications < ActiveRecord::Migration[6.0]
  def change
    create_table :third_party_applications do |t|
      t.text :api_authorization_token
      t.text :api_authorization_client
      t.string :name
      t.integer :user_id
      t.uuid :uuid, default: 'gen_random_uuid()', null: false

      t.timestamps
    end
  end
end
