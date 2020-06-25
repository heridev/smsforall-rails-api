class RenameApiKeyForSmsMobileHub < ActiveRecord::Migration[6.0]
  def change
    rename_column :sms_mobile_hubs, :api_key, :uuid
  end
end
