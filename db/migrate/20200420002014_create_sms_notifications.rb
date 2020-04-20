class CreateSmsNotifications < ActiveRecord::Migration[6.0]
  def change
    create_table :sms_notifications do |t|
      t.uuid :unique_id, default: "gen_random_uuid()", null: false
      t.text :sms_content
      t.string :sms_number
      t.string :status
      t.integer :processed_by_sms_mobile_hub_id

      t.timestamps
    end
  end
end
