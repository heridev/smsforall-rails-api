require 'rails_helper'

RSpec.describe SmsMobileHub, type: :model do
  it 'hello' do
    expect(true).to be_truthy
    holo = create(:sms_mobile_hub)
    expect(holo.temporal_password).to be_present
  end
end
