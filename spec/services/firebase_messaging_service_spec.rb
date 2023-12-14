# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FirebaseMessagingService do
  let(:user) { create(:user, mobile_number: '3121899980') }
  let(:sms_mobile_hub) { create(:sms_mobile_hub, :activated, user: user) }

  # include_examples 'fcm stub request'

  describe '#initialize' do
    describe 'characters limits' do
      context 'when the SMS_CONTENT_LIMIT is not set' do
        let(:sms_mobile_hub) { create(:sms_mobile_hub, :activated, user: user) }
        let(:sms_notification) do
          sms_content = 'x' * 300
          create(
            :sms_notification,
            sms_content: sms_content,
            user: user,
            assigned_to_mobile_hub: sms_mobile_hub
          )
        end
        let(:params) do
          {
            sms_content: sms_notification.sms_content,
            sms_number: sms_mobile_hub.device_number,
            sms_type: sms_notification.sms_type,
            sms_notification_id: sms_notification.unique_id,
            device_token_firebase: sms_mobile_hub.firebase_token
          }
        end
        it 'does not limit the original message' do
          service = described_class.new(params)
          content = service.sms_content
          expect(content.size).to eq 300
        end
      end

      context 'when the sms_number has text or white spaces in it' do
        let(:sms_notification) do
          sms_content = 'x' * 180
          create(
            :sms_notification,
            sms_content: sms_content,
            user: user,
            assigned_to_mobile_hub: sms_mobile_hub
          )
        end
        let(:params) do
          {
            sms_content: sms_notification.sms_content,
            sms_number: '312 123 15 17 movi',
            sms_type: sms_notification.sms_type,
            sms_notification_id: sms_notification.unique_id,
            device_token_firebase: sms_mobile_hub.firebase_token
          }
        end

        it 'returns only the numeric elements' do
          service = described_class.new(params)
          sms_number = service.sms_number
          expect(sms_number.size).to eq 10
          expect(sms_number).to eq '3121231517'
        end
      end

      context 'when the SMS_CONTENT_LIMIT is set' do
        before do
          ENV['SMS_CONTENT_LIMIT'] = '160'
        end

        after do
          ENV['SMS_CONTENT_LIMIT'] = nil
        end

        let(:sms_notification) do
          sms_content = 'x' * 180
          create(
            :sms_notification,
            sms_content: sms_content,
            user: user,
            assigned_to_mobile_hub: sms_mobile_hub
          )
        end
        let(:params) do
          {
            sms_content: sms_notification.sms_content,
            sms_number: sms_mobile_hub.device_number,
            sms_type: sms_notification.sms_type,
            sms_notification_id: sms_notification.unique_id,
            device_token_firebase: sms_mobile_hub.firebase_token
          }
        end
        it 'limits the content to only 160 characters' do
          service = described_class.new(params)
          content = service.sms_content
          expect(content.size).to eq 160
        end
      end

      context 'when the characters length is sorter than 160 characters' do
        let(:sms_mobile_hub) do
          create(:sms_mobile_hub, :activated, user: user, device_number: '3121231518')
        end
        let(:sms_notification) do
          sms_content = 'x' * 100
          create(
            :sms_notification,
            sms_content: sms_content,
            user: user,
            assigned_to_mobile_hub: sms_mobile_hub
          )
        end

        let(:params) do
          {
            sms_content: sms_notification.sms_content,
            sms_number: sms_mobile_hub.device_number,
            sms_type: sms_notification.sms_type,
            sms_notification_id: sms_notification.unique_id,
            device_token_firebase: sms_mobile_hub.firebase_token
          }
        end

        it 'returns all the original characters' do
          service = described_class.new(params)
          content = service.sms_content
          expect(content.size).to eq 100
        end
      end
    end
  end

  describe '#send_to_google!' do
    let(:sms_mobile_hub) { create(:sms_mobile_hub, :activated, user: user) }
    let(:sms_notification) do
      create(:sms_notification, user: user, assigned_to_mobile_hub: sms_mobile_hub)
    end
    let(:params) do
      {
        sms_content: sms_notification.sms_content,
        sms_number: sms_mobile_hub.device_number,
        sms_type: sms_notification.sms_type,
        sms_notification_id: sms_notification.unique_id,
        device_token_firebase: sms_mobile_hub.firebase_token
      }
    end

    context 'when the cloud messaging is successfully sent' do
      let(:valid_firebase_response) do
        {
          status_code: 200,
          body: {
            multicast_id: 8_573_675_465_357_843_813,
            success: 1,
            failure: 0,
            canonical_ids: 0
          }.to_json
        }
      end

      it 'returns a valid response and is accesible' do
        allow_any_instance_of(FCM).to receive(
          :send_v1
        ).and_return(valid_firebase_response)
        service = described_class.new(params)
        service.send_to_google!
        expect(service.firebase_response.class).to eq Hash
        expect(service.valid_response?).to be_truthy
        expect(service.firebase_response.keys).to include :success
        expect(service.firebase_response.keys).to include :failure
      end
    end

    context 'when the cloud messaging fails' do
      let(:invalid_firebase_response) do
        {
          body: {
            multicast_id: 8_573_675_465_357_843_813,
            success: 0,
            failure: 1,
            canonical_ids: 0,
            results: [
              { error: 'InvalidRegistration' }
            ]
          }.to_json
        }
      end

      it 'returns an invalid response' do
        allow_any_instance_of(FCM).to receive(
          :send_v1
        ).and_return(invalid_firebase_response)
        service = described_class.new(params)
        service.send_to_google!
        expect(service.firebase_response.class).to eq Hash
        expect(service.valid_response?).to be_falsey
        expect(service.firebase_response.keys).to include :success
        expect(service.firebase_response.keys).to include :failure
      end
    end
  end
end
