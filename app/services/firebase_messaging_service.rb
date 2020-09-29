class FirebaseMessagingService
  SUCCESS_STATUS_CODE = 200

  attr_reader :sms_content,
              :sms_number,
              :device_token_firebase,
              :sms_type,
              :sms_notification_id,
              :firebase_response

  def initialize(params = {})
    params = params.with_indifferent_access
    @sms_number = clean_characters_from(params[:sms_number])
    @sms_notification_id = params[:sms_notification_id]
    @device_token_firebase = params[:device_token_firebase]
    @sms_content = find_valid_message_content(params[:sms_content])
    @sms_type = params[:sms_type] || 'transactional'
    @firebase_response = {}
  end

  def find_valid_message_content(message_content)
    SmsContentCleanerService.new(
      message_content
    ).clean_content!
  end

  def valid_info?
    sms_content.present? &&
      sms_number.present? &&
      device_token_firebase.present? &&
      sms_type.present?
  end

  def send_to_google!
    return unless valid_info?

    devise_ids = [
      device_token_firebase
    ]
    options = {
      priority: 10,
      android: {
        priority: 'high'
      },
      data: {
        sms_number: sms_number,
        sms_content: sms_content,
        sms_type: sms_type,
        sms_notification_id: sms_notification_id
      }
    }
    response = fcm_service.send(devise_ids, options)
    if response[:status_code] == SUCCESS_STATUS_CODE
      return @firebase_response = JSON.parse(
        response[:body],
        symbolize_names: true
      )
    end

    @firebase_response = {
      success: 0,
      failure: 1
    }
  end

  # Removes any text characters such as spaces and letters
  def clean_characters_from(mobile_number)
    mobile_number.gsub(/\D+/, '')
  end

  def valid_response?
    firebase_response[:success] == 1
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
