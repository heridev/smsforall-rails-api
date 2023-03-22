# frozen_string_literal: true

class PublicSmsNotificationSenderService
  class << self
    def send_notification(arguments = {})
      sms_params = format_notification_params(arguments)
      sms_creator = SmsNotificationCreatorService.new(
        sms_params
      )
      sms_creator.perform_creation!
    end

    private

    def find_master_hub
      SmsMobileHub.find_first_master_mobile_hub
    end

    def format_notification_params(arguments = {})
      hash_params = arguments.with_indifferent_access
      sms_number = hash_params[:sms_number]
      sms_content = hash_params[:sms_content]
      mobile_hub_id = find_master_hub&.id

      {
        sms_content: sms_content,
        sms_number: sms_number,
        user_id: find_master_hub&.user_id,
        assigned_to_mobile_hub_id: mobile_hub_id,
        mobile_hub_id: find_master_hub&.uuid,
        sms_type: SmsNotification::SMS_TYPES[:urgent_delivery]
      }
    end
  end
end
