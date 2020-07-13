# frozen_string_literal: true

module V1
  class SmsNotificationSerializer
    include FastJsonapi::ObjectSerializer
    attributes :sms_content,
               :sms_number,
               :kind_of_notification,
               :status,
               :unique_id,
               :sms_type,
               :decorated_status,
               :created_at,
               :decorated_delivered_at

    attribute :processed_by_sms_mobile_hub do |sms_notification|
      ::V1::SmsMobileHubSerializer.new(
        sms_notification.processed_by_sms_mobile_hub
      )
    end

    attribute :assigned_to_mobile_hub do |sms_notification|
      ::V1::SmsMobileHubSerializer.new(
        sms_notification.assigned_to_mobile_hub
      )
    end
  end
end
