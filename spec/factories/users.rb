FactoryBot.define do
  factory :user do
    initialize_with do
      user_params = {
        email: 'p@elh.mx',
        password: 'password1',
        name: 'Heriberto Perez'
      }
      User.persist_values(user_params)
    end
  end
end
