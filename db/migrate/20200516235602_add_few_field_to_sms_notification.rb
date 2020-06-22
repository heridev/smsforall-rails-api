class AddFewFieldToSmsNotification < ActiveRecord::Migration[6.0]
  def up
    change_column :sms_notifications, :status, :string, default: 'pending'
    add_column :sms_notifications, :failed_sent_to_firebase_at, :datetime
    add_column :sms_notifications, :failed_delivery_at, :datetime
    add_column :sms_notifications, :delivered_at, :datetime
    add_column :sms_notifications, :sent_to_firebase_at, :datetime
    add_column :sms_notifications, :assigned_to_mobile_hub_id, :integer
    add_column :sms_notifications, :sms_type, :string, default: 'transactional'
  end

  def down
    change_column :sms_notifications, :status, :string, default: nil
    remove_column :sms_notifications, :failed_sent_to_firebase_at, :datetime
    remove_column :sms_notifications, :failed_delivery_at, :datetime
    remove_column :sms_notifications, :delivered_at, :datetime
    remove_column :sms_notifications, :sent_to_firebase_at, :datetime
    remove_column :sms_notifications, :assigned_to_mobile_hub_id, :integer
    remove_column :sms_notifications, :sms_type, :string
  end
end
