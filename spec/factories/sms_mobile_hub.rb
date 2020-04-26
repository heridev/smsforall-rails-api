FactoryBot.define do
  factory :sms_mobile_hub do
    device_name { 'Mi nueva tablet' }
    device_number { '+523121231517' }
    # association :user, factory: :user
  end
end
