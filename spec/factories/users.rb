# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    initialize_with do
      random_handler = SecureRandom.base64(4)[0...6].gsub(/\W|_/, ('A'..'Z').to_a.sample)
      user_email = "#{random_handler}@example.com"
      user_params = {
        email: user_email,
        mobile_number: '3121231111',
        password: 'password1',
        name: 'Heriberto Perez'
      }
      User.persist_values(user_params)
    end
  end
end
