# frozen_string_literal: true

class SmsHubNotificationSenderJob < ApplicationJob
  queue_as :standard_delivery

  def perform(sms_hub_id)
    SmsHubNotificationSenderService.new(
      sms_hub_id
    ).create_and_enque_sms!
  end
end
