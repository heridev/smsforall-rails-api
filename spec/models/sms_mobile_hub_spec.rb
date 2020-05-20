require 'rails_helper'

RSpec.describe SmsMobileHub, type: :model do
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

