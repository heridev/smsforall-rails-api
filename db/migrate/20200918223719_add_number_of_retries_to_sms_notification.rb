class AddNumberOfRetriesToSmsNotification < ActiveRecord::Migration[6.0]
  def change
    add_column :sms_notifications, :number_of_intents_to_be_delivered, :integer, default: 0
  end
end
