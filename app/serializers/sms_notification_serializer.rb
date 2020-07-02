class SmsNotificationSerializer
  include FastJsonapi::ObjectSerializer
  attributes :sms_content,
             :sms_number,
             :status,
             :unique_id,
             :processed_by_sms_mobile_hub_id,
             :sms_type
end
