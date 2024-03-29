FactoryBot.define do
  factory :sms_mobile_hub do
    device_name { 'Mi nueva tablet' }
    device_number { '3121231111' }
    country_international_code { '52' }
    association :user, factory: :user

    trait :activated do
      firebase_token { 'd93l.d484ddpwoq23,3kdifj7' }
      status { 'activated' }
    end
  end
end
