class AddUpdateStatusFieldsToSmsNotifications < ActiveRecord::Migration[6.0]
  def change
    add_column :sms_notifications, :additional_update_info, :string
    add_column :sms_notifications, :status_updated_by_hub_at, :datetime
  end
end
