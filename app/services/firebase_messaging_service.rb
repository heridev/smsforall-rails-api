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

  def format_message_content
    {
      'token': device_token_firebase,
      'data': {
        sms_number: sms_number,
        sms_content: sms_content,
        sms_type: sms_type,
        sms_notification_id: sms_notification_id
      },
      android: {
        priority: 'high'
      },
      webpush: {
        headers: {
          Urgency: 'high'
        }
      }
    }
  end

  def send_to_google!
    return unless valid_info?

    response = fcm_service.send_v1(format_message_content)
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
    @fcm_service ||= FCM.new(
      nil,
      find_google_firebase_credentials_io,
      ENV['FIREBASE_PROJECT_ID']
    )
  end

  def find_google_firebase_credentials_io
    firebase_credentials_array = Rails.application.credentials[:google_firebase]
    credentials_as_hash = firebase_credentials_array.inject(:update)
    StringIO.new(credentials_as_hash.to_json)
  end
end
