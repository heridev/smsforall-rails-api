# frozen_string_literal: true

class SmsNotificationCreatorService
  attr_reader :notification_params

  # {
  #   mobile_hub_id: sms_mobile_hub.reload.uuid,
  #   sms_number: '+523121231517',
  #   sms_type: 'standard_delivery', # o urgent_delivery
  #   user_id: 1,
  #   sms_customer_reference_id: sms_customer_reference_id # opcional - un valor de referencia de hasta 128 caracteres, con el cual puedes consultar despues el estado actual de dicho mensaje de texto
  # }
  def initialize(notification_params)
    @notification_params = notification_params
    @success_creation = true
  end

  def perform_creation!
    hub_uuid = notification_params[:mobile_hub_id]
    calculator_service = HubCalculatorUsageService.new(hub_uuid)
    current_usage = calculator_service.update_and_return_usage_counter_within_minute

    if calculator_service.limit_by_minute_reached?
      @success_creation = false
      return limit_by_minute_reached_error
    end

    if calculator_service.daily_limit_reached?
      @success_creation = false
      return daily_limit_reached_error
    end

    sms_notification = SmsNotification.create(cleaned_and_safe_params)

    if sms_notification.valid?
      @success_creation = true
      sms_notification.start_delivery_process!
      valid_creation_response(sms_notification)
    else
      @success_creation = false
      invalid_creation_response(sms_notification)
    end
  end

  def cleaned_and_safe_params
    {
      assigned_to_mobile_hub_id: find_mobile_hub.try(:id),
      user_id: notification_params[:user_id],
      sms_number: valid_sms_number,
      sms_type: valid_sms_type,
      sms_content: valid_sms_content_message,
      sms_customer_reference_id: valid_sms_customer_reference
    }
  end

  def valid_sms_number
    ValueConverterService.new(
      notification_params[:sms_number]
    ).take_only_n_characters_from(128)
  end

  def valid_sms_customer_reference
    ValueConverterService.new(
      notification_params[:sms_customer_reference_id]
    ).take_only_n_characters_from(128)
  end

  def valid_sms_content_message
    ValueConverterService.new(
      notification_params[:sms_content]
    ).take_only_160_characters_from
  end

  def valid_sms_type
    sms_type = notification_params[:sms_type]
    return SmsNotification::SMS_TYPES[:default] if sms_type.blank?

    sms_type
  end

  def find_mobile_hub
    @find_mobile_hub ||= SmsMobileHub.find_by(
      uuid: notification_params[:mobile_hub_id]
    )
  end

  def find_error_validation_message(sms_notification)
    error_msg = if sms_notification.assigned_to_mobile_hub_id.blank?
                  I18n.t('api.v2.sms_notifications.failed.invalid_mobile_hub_id')
                else
                  validation_error_message(sms_notification)
                end

    "Existen algunos errores de validación: #{error_msg}"
  end

  def validation_error_message(sms_notification)
    default_error_message = [:desconocido, ['error sin clasificar']]
    first_error = sms_notification.errors.messages.first || default_error_message
    field_name = first_error[0]
    first_error = first_error[1].first
    "#{field_name} - #{first_error}"
  end

  def invalid_creation_response(sms_notification)
    {
      sms_customer_reference_id: sms_notification.sms_customer_reference_id,
      sms_content: sms_notification.sms_content,
      mobile_hub_id: notification_params[:mobile_hub_id],
      api_version: 'V2',
      date_created: Time.zone.now.utc.iso8601,
      status: 'failed',
      error_message: find_error_validation_message(sms_notification),
      sms_number: sms_notification.sms_number
    }
  end

  def valid_creation_response(sms_notification)
    {
      sms_customer_reference_id: sms_notification.sms_customer_reference_id,
      sms_content: sms_notification.sms_content,
      mobile_hub_id: notification_params[:mobile_hub_id],
      api_version: 'V2',
      date_created: Time.zone.now.utc.iso8601,
      status: 'success',
      error_message: nil,
      sms_number: sms_notification.sms_number
    }
  end

  def daily_limit_reached_error
    {
      sms_customer_reference_id: notification_params[:sms_customer_reference_id],
      sms_content: notification_params[:sms_content],
      mobile_hub_id: notification_params[:mobile_hub_id],
      api_version: 'V2',
      date_created: Time.zone.now.utc.iso8601,
      status: 'failed',
      error_message: I18n.t('api.v2.sms_notifications.failed.daily_limit_reached'),
      sms_number: notification_params[:sms_number]
    }
  end

  def limit_by_minute_reached_error
    {
      sms_customer_reference_id: notification_params[:sms_customer_reference_id],
      sms_content: notification_params[:sms_content],
      mobile_hub_id: notification_params[:mobile_hub_id],
      api_version: 'V2',
      date_created: Time.zone.now.utc.iso8601,
      status: 'failed',
      error_message: 'limit_by_minute_reached',
      error_message: I18n.t('api.v2.sms_notifications.failed.limit_by_minute_reached'),
      sms_number: notification_params[:sms_number]
    }
  end

  def valid_creation?
    @success_creation
  end
end