# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::SmsNotificationsController, type: :controller do
  let(:user) { create(:user, mobile_number: '3121231818') }
  let(:other_user) { create(:user, mobile_number: '3121231718') }

  describe '#update_status' do
    let(:sms_mobile_hub) do
      create(
        :sms_mobile_hub,
        :activated,
        device_number: '3121232030',
        user: user
      )
    end
    let!(:individual_sms_notification) do
      create(
        :sms_notification,
        user: user,
        sms_number: '3121701111',
        assigned_to_mobile_hub: sms_mobile_hub
      )
    end

    let(:expected_keys) do
      %i[
        sms_notifications
        page_number
        tot_notifications
        tot_pages
      ]
    end

    context 'when the sms notification uid is not valid' do
      it 'returns 404 not found status code' do
        params = {
          'sms_notification_uid': 'xxx-xxxxx-xxxxxx-xx',
          'status': 'delivered',
          'additional_update_info': 'generic failure'
        }
        process :update_status, method: :put, params: params
        expect(response.status).to eq 404
      end
    end

    context 'when the params are valid' do
      context 'when the notification is marked as delivered' do
        before do
          params = {
            'sms_notification_uid': individual_sms_notification.reload.unique_id,
            'status': 'delivered',
            firebase_token: sms_mobile_hub.firebase_token
          }
          process :update_status, method: :put, params: params
        end

        it 'responds with a 200 success status code' do
          expect(response.status).to eq 200
        end

        it 'responds with the right status and information' do
          data = response_body[:data][:attributes]
          processed_by = data[:processed_by_sms_mobile_hub][:data][:attributes]
          expect(processed_by[:uuid]).to eq sms_mobile_hub.reload.uuid
          expect(data[:decorated_status]).to eq 'delivered'
          expect(data[:decorated_delivered_at]).to_not eq 'N/A'
        end
      end

      context 'when the notification is marked as undelivered' do
        before do
          params = {
            'sms_notification_uid': individual_sms_notification.reload.unique_id,
            'status': 'undelivered',
            firebase_token: sms_mobile_hub.firebase_token
          }
          process :update_status, method: :put, params: params
        end

        it 'responds with a 200 success status code' do
          expect(response.status).to eq 200
        end

        it 'responds with the right status and information' do
          data = response_body[:data][:attributes]
          processed_by = data[:processed_by_sms_mobile_hub][:data][:attributes]
          expect(processed_by[:uuid]).to eq sms_mobile_hub.reload.uuid
          expect(data[:decorated_status]).to eq 'undelivered'
          expect(data[:decorated_delivered_at]).to eq 'N/A'
        end
      end
    end
  end

  describe '#index' do
    let(:sms_mobile_hub_two) do
      create(
        :sms_mobile_hub,
        :activated,
        device_number: '3121709090',
        user: user
      )
    end
    let(:sms_mobile_hub) do
      create(
        :sms_mobile_hub,
        :activated,
        device_number: '3121232030',
        user: user
      )
    end
    let!(:sms_notifications) do
      create_list(
        :sms_notification,
        5,
        user: user,
        assigned_to_mobile_hub: sms_mobile_hub
      )
    end
    let!(:sms_notifications_other_user) do
      create_list(
        :sms_notification,
        5,
        user: other_user,
        assigned_to_mobile_hub: sms_mobile_hub_two
      )
    end
    let!(:individual_sms_notification) do
      create(
        :sms_notification,
        user: user,
        sms_number: '3121701111',
        assigned_to_mobile_hub: sms_mobile_hub
      )
    end

    let(:expected_keys) do
      %i[
        sms_notifications
        page_number
        tot_notifications
        tot_pages
      ]
    end

    let(:expected_individual_keys) do
      %i[
        sms_content
        sms_number
        kind_of_notification
        status
        unique_id
        sms_type
        decorated_status
        created_at
        decorated_delivered_at
        processed_by_sms_mobile_hub
        assigned_to_mobile_hub
      ]
    end

    before do
      inject_user_headers_on_controller(user)
    end

    context 'when no params are included in the request' do
      it 'responds with a successful status code' do
        process :index, method: :get
        expect(response.status).to eq 200
      end

      it 'includes the pagination attributes' do
        process :index, method: :get
        expect(response_body[:data].keys).to eq expected_keys
      end

      it 'returns all sms notifications' do
        process :index, method: :get
        expect(response_body[:data][:sms_notifications].size).to eq 6
      end

      it 'includes the right key names and fields for individual notifications' do
        process :index, method: :get
        data_attributes = response_body[:data][:sms_notifications].first[:attributes]
        expect(data_attributes.keys).to eq expected_individual_keys
        a_hub = data_attributes[:assigned_to_mobile_hub][:data][:attributes]
        expect(a_hub.keys.size).to eq 8
      end

      it 'executes only 3 queries' do
        result = count_queries_for do
          process :index, method: :get
        end
        expect(result).to eq 3
      end
    end

    context 'when there are params/filters are included in the request' do
      context 'when searching by sms number' do
        let(:search_by_params) do
          {
            text_searched: '170111'
          }
        end

        it 'returns only the one that matches with the sms_number' do
          process :index, method: :get, params: search_by_params
          expect(response_body[:data][:sms_notifications].size).to eq 1
          expect(response_body[:data][:page_number]).to eq 1
          expect(response_body[:data][:tot_pages]).to eq 1
          expect(response_body[:data][:tot_notifications]).to eq 1
        end

        it 'executes only 3 queries' do
          result = count_queries_for do
            process :index, method: :get, params: search_by_params
          end
          expect(result).to eq 3
        end
      end

      context 'when searching by kind of notification' do
        let(:by_kind_out) do
          {
            kind_of_notification: 'out'
          }
        end
        let(:by_kind_in) do
          {
            kind_of_notification: 'in'
          }
        end

        it 'returns the ones that were received' do
          get :index, method: :get, params: by_kind_in
          expect(response_body[:data][:sms_notifications].size).to eq 0
        end

        it 'returns the ones that were delivered' do
          get :index, method: :get, params: by_kind_out
          expect(response_body[:data][:sms_notifications].size).to eq 6
        end

        it 'executes only 3 queries' do
          result = count_queries_for do
            process :index, method: :get, params: by_kind_out
          end
          expect(result).to eq 3
        end
      end

      it 'responds with a successful status code' do
        get :index, method: :get
        expect(response.status).to eq 200
      end

      it 'includes the pagination attributes' do
        get :index, method: :get
        expect(response_body[:data].keys).to eq expected_keys
      end

      it 'returns all sms notifications' do
        get :index, method: :get
        expect(response_body[:data][:sms_notifications].size).to eq 6
      end
    end
  end

  describe '#create' do
    let(:firebase_token) { 'firebase-token' }
    let(:sms_mobile_hub) do
      create(:sms_mobile_hub, firebase_token: firebase_token)
    end

    before do
      inject_user_headers_on_controller(sms_mobile_hub.user)
    end

    context 'when the params are valid' do
      let(:message) do
        'Hola h, xxx x xxxxx xxxxxx xxxxxxxxxxxxx xxxxxxxx xxxxxxxx xx x xxxx xxxxx xxxxxxx xxxxxx xxxxxxx xxxxxxx xxxxxx xxxxxxx xxxxxxx xxxxxxxx xxxxxxx xxxxxx xx fin'
      end

      let(:sms_notification_params) do
        {
          hub_uuid: sms_mobile_hub.reload.uuid,
          sms_notification: {
            sms_content: message,
            sms_number: '+523121231517',
            sms_type: 'standard_delivery'
          }
        }
      end

      context 'when the sms mobile uuid is valid' do
        it 'creates a new sms notification' do
          process :create, method: :post, params: sms_notification_params
          expect(response.status).to eq 200
          keys = response_body[:data][:attributes].keys
          expect(keys).to include(:sms_content)
          expect(keys).to include(:sms_number)
          expect(keys).to include(:status)
           expect(keys).to include(:processed_by_sms_mobile_hub)
          expect(keys).to include(:sms_type)
        end

        context 'when the sms_type is set as the standard delivery method' do
          it 'enqueues the sms notification to be sent in the right queue' do
            process :create, method: :post, params: sms_notification_params
            job = find_enqueued_job_by(SmsNotificationSenderJob)
            expect(job[:args].size).to eq 2
            expect(job[:queue]).to eq 'standard_delivery'
          end
        end

        context 'when the sms_type is set as the urgent delivery method' do
          before do
            sms_notification_params[:sms_notification][:sms_type] = 'urgent_delivery'
          end

          it 'enqueues the sms notification to be sent in the right queue' do
            process :create, method: :post, params: sms_notification_params
            job = find_enqueued_job_by(UrgentSmsNotificationSenderJob)
            expect(job[:args].size).to eq 2
            expect(job[:queue]).to eq 'urgent_delivery'
          end
        end
      end

      context 'when the sms mobile uuid is not valid' do
        before do
          sms_notification_params[:hub_uuid] = 'xxxx'
        end

        it 'does not create any sms notifications' do
          process :create, method: :post, params: sms_notification_params
          expect(response.status).to eq 404
        end
      end
    end

    context 'when the params are invalid' do
      let(:sms_notification_params) do
        {
          hub_uuid: sms_mobile_hub.reload.uuid,
          sms_notification: {
            sms_content: 'Hola heriberto, gracias por visitar pacientesweb.com',
            sms_type: 'standard_delivery'
          }
        }
      end

      it 'does not create a sms notification' do
        process :create, method: :post, params: sms_notification_params
        expect(response.status).to eq 422
        expect(response_body[:data][:errors][:sms_number]).to eq ["can't be blank"]
      end
    end
  end
end
