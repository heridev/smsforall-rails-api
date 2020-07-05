class AddCustomerReferenceIdToSmsNotifications < ActiveRecord::Migration[6.0]
  def change
    add_column :sms_notifications,
               :sms_customer_reference_id,
               :string,
               default: '',
               null: false
  end
end
