FactoryBot.define do
  factory :third_party_application do
    name { 'Pacientes Web' }
    association :user, factory: :user
  end
end

