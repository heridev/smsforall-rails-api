FactoryBot.define do
  factory :sms_mobile_hub do
    device_name { 'Mi nueva tablet' }
    device_number { '+523121231517' }
    association :user, factory: :user

    trait :activated do
      firebase_token { 'd93l.d484ddpwoq23,3kdifj7' }
      status { 'activated' }
    end
  end
end
