# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SmsNotificationSenderService do
  let(:user) { create(:user, mobile_number: '3121899980') }

  describe '#deliver_notification' do
    let(:sms_notification) { create(:sms_notification, user: user) }
    let(:sms_notification_two) do
      create(:sms_notification, sms_number: '+523121708994', user: user)
    end
    let(:sms_mobile_hub) do
      create(:sms_mobile_hub, :activated, device_number: '31211231718', user: user)
    end
    let(:sms_mobile_hub_two) do
      create(:sms_mobile_hub, :activated, device_number: '3121708994', user: user)
    end

    context 'when the message is sent to Google firebase' do
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

      before do
        allow_any_instance_of(FCM).to receive(
          :send
        ).and_return(valid_firebase_response)

        service = described_class.new(
          sms_notification_two.id,
          sms_mobile_hub_two.id
        )
        service.deliver_notification!
        sms_notification_two.reload
      end

      it 'marks the sms notification as sent to firebase' do
        expect(sms_notification_two.status).to eq 'sent_to_firebase'
        expect(sms_notification_two.sent_to_firebase_at).to be_present
        expect(
          sms_notification_two.assigned_to_mobile_hub_id
        ).to eq sms_mobile_hub_two.id
      end

      it 'increases the number of intents to be delivered' do
        expect(
          sms_notification_two.number_of_intents_to_be_delivered
        ).to eq 1
        expect(sms_notification_two.status).to eq 'sent_to_firebase'
      end
    end

    context 'when the message is NOT sent to Google firebase' do
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

      it 'marks the sms notification as failed' do
        allow_any_instance_of(FCM).to receive(
          :send
        ).and_return(invalid_firebase_response)

        service = described_class.new(
          sms_notification.id,
          sms_mobile_hub.id
        )
        service.deliver_notification!
        sms_notification.reload
        expect(sms_notification.status).to eq 'failed_sent_to_firebase'
        expect(sms_notification.failed_sent_to_firebase_at).to be_present
        expect(
          sms_notification.assigned_to_mobile_hub_id
        ).to eq sms_mobile_hub.id
      end
    end
  end
end
