# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Android::SmsNotificationsController, type: :controller do
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
      context 'n + 1 queries are under control' do
        # Only three queries
        # and two SAVEPOINTS, because the update
        it 'executes only 5 query' do
          params = {
            'sms_notification_uid': individual_sms_notification.reload.unique_id,
            'status': 'delivered',
            'mobile_hub_token': sms_mobile_hub.firebase_token
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
            'mobile_hub_token': sms_mobile_hub.firebase_token
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
            'mobile_hub_token': sms_mobile_hub.firebase_token
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

