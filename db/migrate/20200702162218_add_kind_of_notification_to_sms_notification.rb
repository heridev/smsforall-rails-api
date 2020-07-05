class AddKindOfNotificationToSmsNotification < ActiveRecord::Migration[6.0]
  def change
    add_column :sms_notifications, :kind_of_notification, :string, default: 'in', null: false
  end
end
