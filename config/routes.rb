Rails.application.routes.draw do
  constraints do
    namespace :v1, path: '/v1' do
      resources :user_registrations, only: :create
      resources :user_sessions, only: :create
      resources :sms_mobile_hubs, only: :create do
        collection do
          post :validate
          post :activate
        end
      end
    end
  end
end
