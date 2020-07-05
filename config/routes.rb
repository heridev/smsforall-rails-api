# frozen_string_literal: true

require 'sidekiq/web'

Rails.application.routes.draw do
  root 'home#index'
  # authenticate :user, ->(u) { u.admin? } do
  #   mount Sidekiq::Web => '/sidekiq'
  # end
  mount Sidekiq::Web => '/panel/sidekiq'

  constraints do
    namespace :v1, path: '/v1' do
      resources :user_registrations, only: :create
      resources :user_sessions, only: %i[create] do
        collection do
          get :user_details_by_token
        end
      end

      resources :sms_mobile_hubs, only: %i[create show index destroy], param: :uuid do
        collection do
          get :activated
          post :validate
          post :activate
        end
      end

      resources :sms_notifications, param: :unique_id
    end

    namespace :v2, path: '/v2' do
      post '/sms/create',
           to: 'sms_notifications#create',
           defaults: { format: 'json' },
           via: [:post]
      # resources :sms_notifications
    end
  end
end
