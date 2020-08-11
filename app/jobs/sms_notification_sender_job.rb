# frozen_string_literal: true

class SmsNotificationSenderJob < ApplicationJob
  queue_as :standard_delivery

  def perform(sms_notification_id, sms_hub_id)
    SmsNotificationSenderService.new(
      sms_notification_id,
      sms_hub_id
    ).deliver_notification!
  end
end
