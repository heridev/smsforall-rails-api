require 'rails_helper'

RSpec.describe Android::SmsMobileHubsController, type: :controller do
  let(:user) do
    create(:user, mobile_number: '3121231617')
  end

  describe '#validate' do
    let(:sms_mobile_hub) { create(:sms_mobile_hub) }
    let(:firebase_token) { 'y.8j9ik$d8dl4mnesw9l(733.nd' }

    context 'when the information is valid' do
      let(:sms_mobile_params) do
        {
          firebase_token: firebase_token,
          device_token_code: sms_mobile_hub.temporal_password
        }
      end

      context 'when the sms_mobile_hub password is valid' do
        it 'enqueues a new job that will process the mobile hub validation' do
          process :validate, method: :post, params: sms_mobile_params
          job = find_enqueued_job_by(SmsHubsValidationJob)
          expect(job[:args].first.keys).to include 'device_token_code'
          expect(job[:args].first.keys).to include 'firebase_token'
        end
      end
    end

    context 'when the information is invalid' do
      let(:sms_mobile_params) do
        {
          device_token_code: 'xxxx'
        }
      end

      context 'when the sms_mobile_hub password is invalid' do
        it 'responds with a not found error' do
          process :validate, method: :post, params: sms_mobile_params
          expect(response.status).to eq 404
        end
      end

      context 'when the sms_mobile_hub password is valid but the mobile hub was already validated' do
        let(:sms_mobile_params) do
          {
            device_token_code: sms_mobile_hub.temporal_password,
            firebase_token: firebase_token
          }
        end

        before do
          sms_mobile_hub.mark_as_activated!
        end

        it 'responds with a not found error' do
          process :validate, method: :post, params: sms_mobile_params
          expect(response.status).to eq 404
        end
      end
    end
  end

  describe '#activate' do
    let(:firebase_token) { 'firebase-token' }
    let(:sms_mobile_hub) do
      create(:sms_mobile_hub, firebase_token: firebase_token)
    end
    let(:sms_notification) do
      create(:sms_notification, user: user, assigned_to_mobile_hub: sms_mobile_hub)
    end

    context 'when the sms mobile hub is searched by firebase token' do
      let(:sms_mobile_params) do
        {
          sms_notification_uid: sms_notification.reload.unique_id,
          firebase_token: firebase_token
        }
      end

      before do
        process :activate, method: :post, params: sms_mobile_params
        sms_mobile_hub.reload
        sms_notification.reload
      end

      it 'marks sms notification as delivered' do
        expect(response.status).to eq 200
        expect(
          sms_notification.processed_by_sms_mobile_hub_id
        ).to eq sms_mobile_hub.id
        expect(sms_notification.status).to eq 'delivered'
        expect(sms_notification.delivered_at).to be_present
      end

      it 'marks the mobile hub as activated' do
        expect(response.status).to eq 200
        expect(sms_mobile_hub.status).to eq 'activated'
        expect(sms_mobile_hub.activated_at).to be_present
      end
    end

    context 'when the information is invalid' do
      let(:sms_mobile_params) do
        {
          sms_notification_uid: sms_notification.unique_id,
          firebase_token: 'invalid'
        }
      end

      before do
        process :activate, method: :post, params: sms_mobile_params
        sms_mobile_hub.reload
        sms_notification.reload
      end

      it 'does not mark sms notification as delivered' do
        expect(response_body[:data][:error]).to be_present
        expect(response.status).to eq 404
        expect(
          sms_notification.processed_by_sms_mobile_hub_id
        ).to be_nil
        expect(sms_notification.status).to_not eq 'delivered'
        expect(sms_notification.delivered_at).to_not be_present
      end

      it 'does not mark the mobile hub as activated' do
        expect(response.status).to eq 404
        expect(sms_mobile_hub.status).to_not eq 'activated'
        expect(sms_mobile_hub.activated_at).to_not be_present
      end
    end
  end
end

