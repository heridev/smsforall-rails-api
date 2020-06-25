class AddCountryInternationalCodeToMobileHubs < ActiveRecord::Migration[6.0]
  def change
    add_column :sms_mobile_hubs, :country_international_code, :string, default: ''
  end
end
