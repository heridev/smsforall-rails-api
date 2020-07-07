# frozen_string_literal: true

module V1
  class SmsNotificationSerializer
    include FastJsonapi::ObjectSerializer
    attributes :sms_content,
               :sms_number,
               :kind_of_notification,
               :status,
               :unique_id,
               :processed_by_sms_mobile_hub_id,
               :sms_type,
               :decorated_status,
               :created_at,
               :decorated_delivered_at
  end
end
