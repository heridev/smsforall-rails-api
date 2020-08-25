require 'rails_helper'

RSpec.describe ThirdPartyApplication, type: :model do
  describe 'private#generate_api_keys' do
    let(:third_party_application) { create(:third_party_application) }

    it 'generates valid api keys' do
      expect(third_party_application.api_authorization_token).to be_present
      expect(third_party_application.api_authorization_client).to be_present
      expect(third_party_application.reload.uuid).to be_present
    end

    it 'includes the id hash' do
      token = JwtTokenService.decode_token(
        third_party_application.api_authorization_token,
        third_party_application.api_authorization_client
      )
      expect(token['id']).to eq third_party_application.reload.id
    end
  end
end


