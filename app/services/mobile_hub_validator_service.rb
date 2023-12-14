class MobileHubValidatorService
  attr_reader :device_token_code,
              :firebase_token,
              :mobile_hub

  def initialize(args = {})
    args = args.with_indifferent_access
    @device_token_code = args[:device_token_code]

    # TODO: deprecate the firebase_token value once we migrate to
    # use the new android/ namespace endpoints
    @firebase_token = find_device_token_value(args)
    @mobile_hub = SmsMobileHub.find_by_code(device_token_code)
  end

  # TODO: deprecate the firebase_token value once we migrate to
  # use the new android/ namespace endpoints in the Android app
  def find_device_token_value(args)
    return args[:firebase_token] if args[:firebase_token].present?

    # declared in the android endpoints
    args[:mobile_hub_token]
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
    mobile_hub.user.first_ten_chars_from_name
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
      mobile_hub_id: mobile_hub.uuid,
      sms_type: SmsNotification::SMS_TYPES[:device_validation]
    }

  sms_creator = SmsNotificationCreatorService.new(
      sms_confirmation_params
    )
    sms_creator.perform_creation!
  end
end
