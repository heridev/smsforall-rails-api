class AddUserIdToSmsNotifications < ActiveRecord::Migration[6.0]
  def change
    add_column :sms_notifications, :user_id, :integer
  end
end
