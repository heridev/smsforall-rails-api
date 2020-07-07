FactoryBot.define do
  factory :sms_notification do
    sms_content { 'Welcome to smsparatodos.com' }
    sms_number { '+523121231517' }
    status { SmsNotification::STATUSES[:default] }
    sms_type { 'standard_delivery' }
    association :user, factory: :user
    association :assigned_to_mobile_hub, factory: :sms_mobile_hub

    trait :sent_to_firebase do
      status { 'sent_to_firebase' }
      failed_delivery_at { nil }
      sent_to_firebase_at { Time.zone.now }
    end

    trait :delivered do
      status { 'delivered' }
      association :assigned_to_mobile_hub, factory: :sms_mobile_hub
      failed_delivery_at { nil }
      delivered_at { Time.zone.now }
    end
  end
end

