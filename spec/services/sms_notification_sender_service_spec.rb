require 'rails_helper'

RSpec.describe SmsNotificationSenderService do
  describe '#deliver_notification' do
    let(:sms_notification) { create(:sms_notification) }
    let(:sms_mobile_hub) { create(:sms_mobile_hub, :activated) }

    context 'when the message is sent to Google firebase' do
      let(:valid_firebase_response) do
        {
          body: {
            multicast_id: 8573675465357843813,
            success: 1,
            failure: 0,
            canonical_ids: 0
          }.to_json
        }
      end

      it 'marks the sms notification as sent to firebase' do
        allow_any_instance_of(FCM).to receive(
          :send
        ).and_return(valid_firebase_response)

        service = described_class.new(
          sms_notification.id,
          sms_mobile_hub.id
        )
        service.deliver_notification!
        sms_notification.reload
        expect(sms_notification.status).to eq 'sent_to_firebase'
        expect(sms_notification.sent_at).to be_present
        expect(
          sms_notification.assigned_to_mobile_hub_id
        ).to eq sms_mobile_hub.id
      end
    end

    context 'when the message is NOT sent to Google firebase' do
      let(:invalid_firebase_response) do
        {
          body: {
            multicast_id: 8573675465357843813,
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

  describe '#find_valid_sms_content' do
    let(:sms_notification) do
      sms_content = 'x' * 180
      create(:sms_notification, sms_content: sms_content)
    end
    let(:sms_mobile_hub) { create(:sms_mobile_hub, :activated) }

    context 'when the characters lenght is longer than 160 characters' do
      it 'limits the content to only 160 characters' do
        service = described_class.new(
          sms_notification.id,
          sms_mobile_hub.id
        )
        content = service.find_valid_sms_content
        expect(content.size).to eq 160
      end
    end

    context 'when the characters lenght is sorter than 160 characters' do
      let(:sms_notification) do
        sms_content = 'x' * 100
        create(:sms_notification, sms_content: sms_content)
      end

      it 'returns all the original characters' do
        service = described_class.new(
          sms_notification.id,
          sms_mobile_hub.id
        )
        content = service.find_valid_sms_content
        expect(content.size).to eq 100
      end
    end
  end
end
