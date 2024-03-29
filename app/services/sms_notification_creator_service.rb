#. frozen_string_literaf: true

class SmsNotificationCreatorService
  attr_reader :user_id,
              :sms_content,
              :sms_notification,
              :sms_type,
              :sms_number,
              :mobile_hub_id,
              :sms_customer_reference_id

  # {
  #   mobile_hub_id: sms_mobile_hub.reload.uuid,
  #   sms_number: '+523121231111',
  #   sms_type: 'standard_delivery', # o urgent_delivery
  #   user_id: 1,
  #   sms_customer_reference_id: sms_customer_reference_id # opcional - un valor de referencia de hasta 128 caracteres, con el cual puedes consultar despues el estado actual de dicho mensaje de texto
  # }
  def initialize(notification_params)
    @sms_type = notification_params[:sms_type]
    @sms_content = notification_params[:sms_content]
    @user_id = notification_params[:user_id]
    @sms_number = notification_params[:sms_number]
    @mobile_hub_id = notification_params[:mobile_hub_id]
    @sms_customer_reference_id = notification_params[:sms_customer_reference_id].to_s
    @success_creation = true
  end

  def perform_creation!
    hub_uuid = mobile_hub_id
    calculator_service = HubCalculatorUsageService.new(hub_uuid)
    calculator_service.update_and_return_usage_counter_within_minute

    if calculator_service.limit_by_minute_reached?
      @success_creation = false
      return limit_by_minute_reached_error
    end

    if calculator_service.daily_limit_reached?
      @success_creation = false
      return daily_limit_reached_error
    end

    @sms_notification = SmsNotification.create(cleaned_and_safe_params)

    if sms_notification.valid?
      @success_creation = true
      sms_notification.start_delivery_process!
      valid_creation_response
    else
      @success_creation = false
      invalid_creation_response
    end
  end

  def cleaned_and_safe_params
    {
      kind_of_notification: SmsNotification::KIND_OF_NOTIFICATION[:out],
      assigned_to_mobile_hub_id: find_mobile_hub.try(:id),
      user_id: user_id,
      sms_number: format_valid_sms_number,
      sms_type: valid_sms_type,
      sms_content: valid_sms_content_message,
      sms_customer_reference_id: valid_sms_customer_reference
    }
  end

  def format_valid_sms_number
    valid_number = ValueConverterService.new(
      sms_number
    ).take_only_n_characters_from(15)
    code_country = find_mobile_hub&.country_international_code
    return valid_number if code_country.blank?

    splitted_by_code_country = valid_number.split("+#{code_country}")

    # Output:
    #  ["", "3121231111"]
    #  or when no match
    #  ["+13121231111"]
    # we take only the right number as we are sending a local
    # number not international one and in Mexico now you get an error
    # so just fix it
    if splitted_by_code_country.size == 2
      splitted_by_code_country[1]
    else
      splitted_by_code_country[0]
    end
  end

  def valid_sms_customer_reference
    ValueConverterService.new(
      sms_customer_reference_id
    ).take_only_n_characters_from(128)
  end

  def valid_sms_content_message
    SmsContentCleanerService.new(
      sms_content
    ).clean_content!
  end

  def valid_sms_type
    return sms_type if sms_type.present?

    SmsNotification::SMS_TYPES[:default]
  end

  def find_mobile_hub
    @find_mobile_hub ||= SmsMobileHub.find_by(
      uuid: mobile_hub_id
    )
  end

  def find_error_validation_message(sms_notification)
    error_msg = if sms_notification.assigned_to_mobile_hub_id.blank?
                  I18n.t('api.v2.sms_notifications.failed.invalid_mobile_hub_id')
                else
                  validation_error_message(sms_notification)
                end
    there_are_errors = I18n.t('api.v2.sms_notifications.failed.there_are_errors')
    "#{there_are_errors} #{error_msg}"
  end

  def validation_error_message(sms_notification)
    default_error_message = [:desconocido, ['error sin clasificar']]
    first_error = sms_notification.errors.messages.first || default_error_message
    field_name = first_error[0]
    first_error = first_error[1].first
    "#{field_name} - #{first_error}"
  end

  def invalid_creation_response
    {
      sms_customer_reference_id: sms_notification.sms_customer_reference_id,
      sms_content: sms_notification.sms_content,
      mobile_hub_id: mobile_hub_id,
      api_version: 'V2',
      date_created: Time.zone.now.utc.iso8601,
      status: 'failed',
      error_message: find_error_validation_message(sms_notification),
      sms_number: sms_notification.sms_number
    }
  end

  def valid_creation_response
    {
      sms_customer_reference_id: sms_notification.sms_customer_reference_id,
      sms_content: sms_notification.sms_content,
      mobile_hub_id: mobile_hub_id,
      api_version: 'V2',
      date_created: Time.zone.now.utc.iso8601,
      status: 'enqueued',
      error_message: nil,
      sms_number: sms_notification.sms_number
    }
  end

  def daily_limit_reached_error
    {
      sms_customer_reference_id: sms_customer_reference_id,
      sms_content: sms_content,
      mobile_hub_id: mobile_hub_id,
      api_version: 'V2',
      date_created: Time.zone.now.utc.iso8601,
      status: 'failed',
      error_message: I18n.t('api.v2.sms_notifications.failed.daily_limit_reached'),
      sms_number: sms_number
    }
  end

  def limit_by_minute_reached_error
    {
      sms_customer_reference_id: sms_customer_reference_id,
      sms_content: sms_content,
      sms_number: sms_number,
      mobile_hub_id: mobile_hub_id,
      api_version: 'V2',
      date_created: Time.zone.now.utc.iso8601,
      status: 'failed',
      error_message: I18n.t('api.v2.sms_notifications.failed.limit_by_minute_reached')
    }
  end

  def valid_creation?
    @success_creation
  end
end
