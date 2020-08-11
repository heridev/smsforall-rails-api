# frozen_string_literal: true

require 'sidekiq/web'
require 'sidekiq-scheduler/web'

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

      resources :sms_notifications, param: :unique_id do
        collection do
          put :update_status
        end
      end
    end

    namespace :v2, path: '/v2' do
      post '/sms/create',
           to: 'sms_notifications#create',
           defaults: { format: 'json' },
           via: [:post]
      # resources :sms_notifications
    end

    namespace :android, path: '/android' do
      post '/sms_mobile_hubs/validate',
           to: 'sms_mobile_hubs#validate',
           defaults: { format: 'json' },
           via: [:post]

      post '/sms_mobile_hubs/activate',
           to: 'sms_mobile_hubs#activate',
           defaults: { format: 'json' },
           via: [:post]

      put '/sms_notifications/update_status',
           to: 'sms_notifications#update_status',
           defaults: { format: 'json' },
           via: [:put]
    end
  end
end
