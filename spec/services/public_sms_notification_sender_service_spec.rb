# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PublicSmsNotificationSenderService do
  let(:user) { create(:user, mobile_number: '3121899980') }
  let!(:sms_mobile_hub_master) do
    user = create(
      :user,
      mobile_number: '3121231617',
      country_international_code: '52'
    )
    create(
      :sms_mobile_hub,
      is_master: true,
      user: user,
      device_name: 'hub master'
    )
  end

  describe '#send_notification' do
    context 'when the sms params are valid' do
      let(:sms_content) { 'Que onda compi, como te va?' }
      let(:sms_number) { '+523121231111' }

      it 'responds with the sms notification details' do
        argument_params = {
          sms_number: sms_number,
          sms_content: sms_content
        }

        result = described_class.send_notification(argument_params)
        expect(result[:status]).to eq 'enqueued'
        expect(result[:api_version]).to eq 'V2'
        expect(result[:mobile_hub_id]).to eq sms_mobile_hub_master.reload.uuid
        expect(result[:sms_content]).to eq sms_content
        expect(sms_number).to match(result[:sms_number])
      end

      it 'enqueues an urgent sms notification to be sent' do
        argument_params = {
          sms_number: sms_number,
          sms_content: sms_content
        }

        described_class.send_notification(argument_params)
        job = find_enqueued_job_by(UrgentSmsNotificationSenderJob)
        expect(job[:args].size).to eq 2
        expect(job[:job]).to eq UrgentSmsNotificationSenderJob
        expect(job[:queue]).to eq 'urgent_delivery'
      end
    end
  end
end
