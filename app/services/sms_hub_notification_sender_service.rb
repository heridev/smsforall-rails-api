# frozen_string_literal: true

class SmsHubNotificationSenderService
  def initialize(sms_hub_id)
    @mobile_hub = SmsMobileHub.find_by(id: sms_hub_id)
  end

  def create_and_enque_sms!
    return unless @mobile_hub

    current_time = Time.now.in_time_zone(
      'America/Mexico_City'
    ).strftime('%a, %b %e %I:%M:%S%P')

    sms_content = I18n.t(
      'mobile_hub.content.sms_interval_checker_msg',
      current_time: current_time,
      device_short_name: @mobile_hub.short_device_name,
      hub_id: @mobile_hub.id
    )
    sms_confirmation_params = {
      sms_content: sms_content,
      sms_number: find_sms_mobile_hub_number,
      user_id: @mobile_hub.user_id,
      assigned_to_mobile_hub_id: @mobile_hub.id,
      sms_type: SmsNotification::SMS_TYPES[:default]
    }

    sms_notification = SmsNotification.create(sms_confirmation_params)
    return unless sms_notification.persisted?

    SmsNotificationSenderJob.perform_later(
      sms_notification.id,
      @mobile_hub.id
    )
  end

  private

  def find_sms_mobile_hub_number
    ENV.fetch(
      'DEFAULT_MASTER_RECEIVER_PHONE_NUMBER',
      @mobile_hub.find_international_number
    )
  end
end
