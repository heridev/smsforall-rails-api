# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MobileHubValidatorService do
  describe '#validate_hub!' do
    context 'when the token code is valid' do
      let(:sms_mobile_hub) { create(:sms_mobile_hub) }

      let(:params) do
        {
          device_token_code: sms_mobile_hub.temporal_password,
          firebase_token: 'xd7kl.dktj39rkd93k83ld83dd'
        }
      end

      it 'updates the firebase and status fields for mobile hub' do
        described_class.new(params).validate_hub!
        sms_mobile_hub.reload
        expect(sms_mobile_hub.status).to eq 'activation_in_progress'
        expect(sms_mobile_hub.firebase_token).to eq params[:firebase_token]
      end

      it 'creates a new SmsNotification record' do
        expect do
          described_class.new(params).validate_hub!
        end.to change(SmsNotification, :count).by(1)

        sms_notification = SmsNotification.find_by(sms_number: sms_mobile_hub.device_number)
        expect(sms_notification.sms_type).to eq 'device_validation'
        expect(sms_notification.sms_content).to match('Hola')
      end

      it 'enqueues a new sms notification sender job' do
        described_class.new(params).validate_hub!
        job = find_enqueued_job_by(SmsNotificationSenderJob)
        expect(job[:args].size).to eq 2
        expect(job[:args][0].class).to eq Integer
        expect(job[:args][1].class).to eq Integer
      end
    end

    context 'when the token code is not valid' do
      let(:sms_mobile_hub) { create(:sms_mobile_hub) }

      let(:params) do
        {
          device_token_code: 'invalid-token',
          firebase_token: 'xd7kl.dktj39rkd93k83ld83dd'
        }
      end

      it 'does not make any updates for models' do
        described_class.new(params).validate_hub!
        sms_mobile_hub.reload
        expect(sms_mobile_hub.status).to eq 'pending_activation'
        expect(sms_mobile_hub.firebase_token).to be_nil
      end

      it 'does not create a new SmsNotification record' do
        expect do
          described_class.new(params).validate_hub!
        end.to_not change(SmsNotification, :count)
      end

      it 'does not enqueue a new sms notification sender job' do
        described_class.new(params).validate_hub!
        job = find_enqueued_job_by(SmsNotificationSenderJob)
        expect(job).to be_nil
      end
    end
  end
end
