# frozen_string_literal: true

class OnDemandSmsSenderService
  def initialize(options)
    @devise_firebase_token = options[:devise_firebase_token]
    @sms_type = options[:sms_type] || 'transactional'
    @phone_recipient_number = options[:phone_recipient_number]
    @message_content = take_only_128_characters_from(options[:message_content])
    @sms_notification_id = options[:sms_notification_id]
  end

  def take_only_128_characters_from(message_content)
    if message_content.present?
      message_content[0..127]
    else
      ''
    end
  end

  def valid_params?
    @devise_firebase_token.present? &&
      @sms_type.present? &&
      @phone_recipient_number.present? &&
      @message_content.present? &&
      @sms_notification_id.present?
  end

  def send_now!
    unless valid_params?
      return {
        success: false
      }
    end

    options = {
      'data': {
        'sms_number': @phone_recipient_number,
        'sms_content': @message_content,
        'sms_notification_id': @sms_notification_id,
        'type': @sms_type
      }
    }
    response = fcm_service.send([@devise_firebase_token], options)
    body_response = JSON.parse(response[:body], symbolize_names: true)

    if body_response[:success] == 1
      return {
        success: true
      }
    end

    {
      success: false
    }
  end

  private

  def fcm_service
    @fcm_service ||= begin
                       FCM.new(
                         Rails.application.credentials[:fcm_server_key],
                         timeout: ENV['FCM_SERVICE_TIMEOUT'] || 3
                       )
                     end
  end
end
