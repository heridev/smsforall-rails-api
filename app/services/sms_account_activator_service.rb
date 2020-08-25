# frozen_string_literal: true

class SmsAccountActivatorService
  class << self
    def send_notification(arguments = {})
      sms_params = format_notification_params(arguments)
      sms_notification = SmsNotification.create(sms_params)
      return unless sms_notification.persisted?

      UrgentSmsNotificationSenderJob.perform_later(
        sms_notification.id,
        find_master_hub&.id
      )
    end

    private

    def find_master_hub
      @find_master_hub ||= SmsMobileHub.find_first_master_mobile_hub
    end

    def format_notification_params(arguments = {})
      hash_params = arguments.with_indifferent_access
      user_pin_code = hash_params[:user_pin_code]
      user_name = hash_params[:user_name]
      user_phone_number = hash_params[:user_phone_number]
      user_id = hash_params[:user_id]
      mobile_hub_id = find_master_hub&.id

      sms_content = I18n.t(
        'mobile_hub.content.welcome_msg_with_activation_pin',
        user_name: user_name,
        pin_code: user_pin_code
      )

      {
        sms_content: sms_content,
        sms_number: user_phone_number,
        user_id: user_id,
        assigned_to_mobile_hub_id: mobile_hub_id,
        sms_type: SmsNotification::SMS_TYPES[:urgent_delivery]
      }
    end
  end
end
