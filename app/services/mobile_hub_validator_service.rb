class MobileHubValidatorService
  attr_reader :device_token_code,
              :firebase_token,
              :mobile_hub

  def initialize(args = {})
    args = args.with_indifferent_access
    @device_token_code = args[:device_token_code]
    @firebase_token = args[:firebase_token]
    @mobile_hub = SmsMobileHub.find_by_code(device_token_code)
  end

  def validate_hub!
    return unless mobile_hub

    mobile_hub.update_column(
      :firebase_token,
      firebase_token
    )
    mobile_hub.mark_as_activation_in_progress!
    send_sms_activation_notification!
  end

  def first_ten_characters_from_name
    user_name = mobile_hub.user.name || ''
    user_name_splitted = user_name.split(' ')
    user_name_splitted.first[0.10]
  end

  def send_sms_activation_notification!
    sms_content = I18n.t(
      'mobile_hub.content.welcome_msg',
      user_name: first_ten_characters_from_name
    )
    sms_confirmation_params = {
      sms_content: sms_content,
      sms_number: mobile_hub.find_international_number,
      user_id: mobile_hub.user_id,
      assigned_to_mobile_hub_id: mobile_hub.id,
      sms_type: SmsNotification::SMS_TYPES[:device_validation]
    }

    sms_notification = SmsNotification.create(sms_confirmation_params)
    return unless sms_notification.persisted?

    SmsNotificationSenderJob.perform_later(
      sms_notification.id,
      mobile_hub.id
    )
  end
end
