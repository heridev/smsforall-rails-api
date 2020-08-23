# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserPreparatorService do
  let!(:sms_hub_master) do
    user = create(:user, mobile_number: '3121231617')
    create(:sms_mobile_hub, is_master: true, user: user)
  end
  let(:user) { create(:user, mobile_number: '3121899980') }

  describe '#initialize' do
    it 'generates the sms notifications' do
      described_class.new(user.id)
      expect(user.sms_notifications.size).to eq 1
    end

    it 'generates the registration pin code' do
      described_class.new(user.id)
      expect(user.reload.registration_pin_code).to be_present
      expect(user.registration_pin_code.size).to eq 6
    end

    it 'generates a default third party application keys' do
      described_class.new(user.id)
      expect(user.third_party_applications.size).to eq 1
    end
  end
end
