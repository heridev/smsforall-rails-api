class CreateSmsMobileHubs < ActiveRecord::Migration[6.0]
  def change
    create_table :sms_mobile_hubs do |t|
      t.uuid :api_key, default: "gen_random_uuid()", null: false
      t.string :device_name, null: false
      t.string :temporal_password
      t.string :status, default: 'pending_activation', null: false
      t.string :device_number, null: false
      t.text :firebase_token

      t.timestamps
    end
  end
end
