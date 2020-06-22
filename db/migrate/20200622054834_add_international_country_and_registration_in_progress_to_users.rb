class AddInternationalCountryAndRegistrationInProgressToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :country_international_code, :string, default: ''
    add_column :users, :activation_in_progress, :boolean, default: true
    add_column :users, :mobile_number, :string, default: ''
  end
end
