class SmsNotificationSenderJob < ApplicationJob
  queue_as :default

  def perform(sms_notification_id, sms_hub_id)
    SmsNotificationSenderService.new(
      sms_notification_id,
      sms_hub_id
    ).deliver_notification!
  end
end
