class AddNewFieldsForSmsMobileHub < ActiveRecord::Migration[6.0]
  def change
    add_column :sms_mobile_hubs, :user_id, :integer
    add_column :sms_mobile_hubs, :activated_at, :datetime
  end
end
