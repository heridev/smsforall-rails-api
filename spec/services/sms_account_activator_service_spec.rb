# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SmsAccountActivatorService do
  let!(:sms_hub_master) do
    user = create(:user, mobile_number: '3121231617')
    create(:sms_mobile_hub, is_master: true, user: user)
  end
  let(:user) { create(:user, mobile_number: '3121899980') }

  describe '#send_notification' do
    context 'when the sms params are valid' do
      it 'enqueues an urgent sms notification to be sent' do
        argument_params = {
          user_id: user.id,
          user_name: user.first_ten_chars_from_name,
          user_pin_code: user.registration_pin_code,
          user_phone_number: user.find_international_number
        }

        described_class.send_notification(argument_params)
        job = find_enqueued_job_by(UrgentSmsNotificationSenderJob)
        expect(job[:args].size).to eq 2
      end
    end

    context 'when the sms params are NOT valid' do
      it 'does not enqueue any notifications' do
        argument_params = {
          user_name: user.first_ten_chars_from_name,
          user_pin_code: user.registration_pin_code,
          user_phone_number: user.find_international_number
        }

        described_class.send_notification(argument_params)
        job = find_enqueued_job_by(UrgentSmsNotificationSenderJob)
        expect(job).to be_nil
      end
    end
  end
end
