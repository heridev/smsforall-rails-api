class AddIsMasterToSmsMobileHub < ActiveRecord::Migration[6.0]
  def change
    add_column :sms_mobile_hubs, :is_master, :boolean, default: false
  end
end
