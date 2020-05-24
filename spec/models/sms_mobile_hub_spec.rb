require 'rails_helper'

RSpec.describe SmsMobileHub, type: :model do
  let(:user) { create(:user, email: 'newemail@example.com') }
  describe 'validations' do
    describe '.uniqueness#device_number' do
      context 'when the device number is already registered' do
        before do
          create(:sms_mobile_hub, device_number: '+523121231517', user: user)
        end

        it 'triggers an error in the email validation' do
          result = build(:sms_mobile_hub, device_number: '+523121231517')
          expect(result.valid?).to be_falsey
          expect(result.errors.messages.keys).to include :device_number
        end
      end

      context 'when the device number does not exist' do
        it 'does not trigger an email validation error' do
          result = build(:sms_mobile_hub, device_number: '+523121231517')
          expect(result.valid?).to be_truthy
        end
      end
    end
  end
  describe 'private#set_temporal_password' do
    let(:sms_mobile_hub) { create(:sms_mobile_hub) }

    it 'generates a valid temporal password' do
      expect(sms_mobile_hub.temporal_password).to be_present
    end

    it 'temporal password has a length of 6 characters' do
      expect(sms_mobile_hub.temporal_password.size).to eq 6
    end
  end
end

