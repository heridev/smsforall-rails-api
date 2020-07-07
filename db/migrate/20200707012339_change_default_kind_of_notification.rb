class ChangeDefaultKindOfNotification < ActiveRecord::Migration[6.0]
  def change
    change_column_default :sms_notifications, :kind_of_notification, 'out'
  end
end
