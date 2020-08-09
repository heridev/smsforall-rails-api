class AddMobileHubTokenToSmsMobileHub < ActiveRecord::Migration[6.0]
  def change
    add_column :sms_mobile_hubs, :mobile_hub_token, :text
  end
end
