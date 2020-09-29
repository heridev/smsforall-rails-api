# frozen_string_literal: true

class SmsNotificationSenderService
  attr_reader :mobile_hub, :sms_notification

  def initialize(sms_notification_id, sms_hub_id)
    @sms_notification = SmsNotification.find_by(id: sms_notification_id)
    @mobile_hub = SmsMobileHub.find_by(id: sms_hub_id)
  end

  def deliver_notification!
    return unless sms_notification
    return unless mobile_hub

    params = {
      sms_content: sms_notification.sms_content,
      sms_number: sms_notification.sms_number,
      sms_type: sms_notification.sms_type,
      sms_notification_id: sms_notification.unique_id,
      device_token_firebase: mobile_hub.firebase_token
    }
    firebase_service = FirebaseMessagingService.new(params)
    firebase_service.send_to_google!

    if firebase_service.valid_response?
      sms_notification.mark_sent_to_firebase_as_success!(mobile_hub.id)
      sms_notification.increase_number_of_intents_to_be_delivered!
    else
      sms_notification.mark_sent_to_firebase_as_failure!(mobile_hub.id)
    end
  end
end
