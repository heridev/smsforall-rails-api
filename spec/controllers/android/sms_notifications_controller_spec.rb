# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Android::SmsNotificationsController, type: :controller do
  let(:user) { create(:user, mobile_number: '3121231818') }
  let(:other_user) { create(:user, mobile_number: '3121231718') }
  let(:sms_mobile_hub) do
    create(
      :sms_mobile_hub,
      :activated,
      device_number: '3121232030',
      user: user
    )
  end

  describe '#receive' do
    context 'when the sms content and number are not valid' do
      it 'does not create a sms notification' do
        params = {
          'firebase_token': sms_mobile_hub.firebase_token
        }

        process :receive, method: :post, params: params
        expect(response.status).to eq 422
        error_keys = response_body[:data][:errors].keys
        expect(error_keys).to eq  [:sms_content, :sms_number]
      end
    end

    context 'when the firebase token hub is not valid' do
      it 'does not create a sms notification' do
        params = {
          'sms_number': '+523121231111',
          'sms_content': 'Muchas gracias por la confirmación',
          'firebase_token': 'xxx'
        }
        process :receive, method: :post, params: params
        expect(response.status).to eq 404
      end
    end

    context 'when the firebase token hub is valid' do
      it 'creates a new sms notification' do
        params = {
          'sms_number': '+523121231111',
          'sms_content': 'Muchas gracias por la confirmación',
          'firebase_token': sms_mobile_hub.firebase_token
        }
        process :receive, method: :post, params: params
        expect(response.status).to eq 200
        expect(response_body[:data][:message]).to match(/created successfully/)
      end
    end
  end

  describe '#update_status' do
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
      context 'n + 1 queries are under control' do
        # Only three queries
        # and two SAVEPOINTS, because the update
        it 'executes only 5 query' do
          params = {
            'sms_notification_uid': individual_sms_notification.reload.unique_id,
            'status': 'delivered',
            'firebase_token': sms_mobile_hub.firebase_token
          }
          result = count_queries_for do
            process :update_status, method: :put, params: params
          end
          expect(result).to eq 5
        end
      end

      context 'when the notification is marked as delivered' do
        before do
          params = {
            'sms_notification_uid': individual_sms_notification.reload.unique_id,
            'status': 'delivered',
            'firebase_token': sms_mobile_hub.firebase_token
          }
          process :update_status, method: :put, params: params
        end

        it 'responds with a 200 success status code' do
          expect(response.status).to eq 200
        end

        it 'responds with the right status and information' do
          expect(response_body[:data][:message]).to eq I18n.t('sms_notification.controllers.succcess_update')
          expect(individual_sms_notification.reload.status).to eq SmsNotification::STATUSES[:delivered]
        end
      end

      context 'when the notification is marked as undelivered' do
        before do
          params = {
            'sms_notification_uid': individual_sms_notification.reload.unique_id,
            'status': 'undelivered',
            'firebase_token': sms_mobile_hub.firebase_token
          }
          process :update_status, method: :put, params: params
        end

        it 'responds with a 200 success status code' do
          expect(response.status).to eq 200
        end

        it 'responds with the right status and information' do
          expect(response_body[:data][:message]).to eq I18n.t('sms_notification.controllers.succcess_update')
          expect(individual_sms_notification.reload.status).to eq SmsNotification::STATUSES[:undelivered]
        end
      end
    end
  end
end
