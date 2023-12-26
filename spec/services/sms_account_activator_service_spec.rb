# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SmsAccountActivatorService do
  let(:user) { create(:user, mobile_number: '3121899980') }
  let!(:sms_mobile_hub_master) do
    user = create(
      :user,
      mobile_number: '3121231617',
      country_international_code: '52'
    )
    @sms_mobile_hub_master ||= begin
      create(
        :sms_mobile_hub,
        is_master: true,
        user: user,
        device_name: 'hub master'
      )
    end
  end

  describe '#send_notification' do
    context 'when the sms params are NOT valid' do
      it 'does not enqueue any notifications' do
        argument_params = {
          user_name: user.first_ten_chars_from_name,
          user_pin_code: user.registration_pin_code,
          user_phone_number: user.find_international_number
        }

        result = described_class.send_notification(argument_params)
        sms_notification = SmsNotification.find_by(user_id: user.id)
        expect(sms_notification).to be_nil
      end
    end

    context 'when the sms params are valid' do
      it 'enqueues an urgent sms notification to be sent' do
        argument_params = {
          user_id: user.id,
          user_name: user.first_ten_chars_from_name,
          user_pin_code: user.registration_pin_code,
          user_phone_number: user.find_international_number
        }

        result = described_class.send_notification(argument_params)
        expect(result[:status]).to eq 'enqueued'
        expect(result[:sms_content]).to match('your activation token')
        expect(result[:sms_number]).to match('3121899980')
        sms_mobile_hub_master
      end
    end
  end
end
