require 'rails_helper'

RSpec.describe FirebaseMessagingService do
  describe '#send_to_google!' do
    let(:sms_notification) { create(:sms_notification) }
    let(:sms_mobile_hub) { create(:sms_mobile_hub, :activated) }
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
          body: {
            multicast_id: 8573675465357843813,
            success: 1,
            failure: 0,
            canonical_ids: 0
          }.to_json
        }
      end

      it 'returns a valid response and is accesible' do
        allow_any_instance_of(FCM).to receive(
          :send
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

      it 'returns an invalid response' do
        allow_any_instance_of(FCM).to receive(
          :send
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

