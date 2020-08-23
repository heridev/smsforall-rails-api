# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AuthorizeApiRequestService do
  describe '.validate_user_token' do
    context 'when using the V1 version' do
      let(:valid_user) { create(:user) }
      let!(:valid_token) do
        JwtTokenService.encode_token(
          { user_id: valid_user.id },
          valid_user.jwt_salt
        )
      end

      let(:headers) do
        {
          'Authorization-Token' => "Bearer #{valid_token}",
          'Authorization-Client' => valid_user.jwt_salt
        }
      end

      let(:invalid_headers) do
        {
          'Authorization-Token' => valid_token,
          'Authorization-Client' => valid_user.jwt_salt
        }
      end

      context 'when the authorization headers are valid' do
        it 'finds the user' do
          result = described_class.new(headers).validate_user_token
          expect(result.email).to eq valid_user.email
          expect(result.name).to eq valid_user.name
        end
      end

      context 'when the authorization headers are not present' do
        it 'does not find any user' do
          result = described_class.new({}).validate_user_token
          expect(result).to be_nil
        end
      end

      context 'when the authorization-Token does not specify the Bearer work' do
        it 'finds the user' do
          result = described_class.new(invalid_headers).validate_user_token
          expect(result.email).to eq valid_user.email
          expect(result.name).to eq valid_user.name
        end
      end
    end

    context 'when using the V2 version' do
      let(:secondary_user) do
        user = create(:user, mobile_number: '3121561517')
        UserPreparatorService.new(user)
        user
      end
      let!(:third_party_applications) do
        create_list(:third_party_application, 10, user: secondary_user)
      end
      let(:valid_user) do
        user = create(:user)
        UserPreparatorService.new(user)
        user
      end
      let(:user_api_keys) do
        valid_user.third_party_applications.first
      end
      let(:headers) do
        {
          'Authorization-Token' => "Bearer #{user_api_keys.api_authorization_token}",
          'Authorization-Client' => user_api_keys.api_authorization_client
        }
      end
      let(:different_headers_format) do
        {
          'Authorization-Token' => user_api_keys.api_authorization_token,
          'Authorization-Client' => user_api_keys.api_authorization_client
        }
      end

      context 'when the authorization headers are valid' do
        it 'finds the right USER associated to the third party application keys' do
          user = described_class.new(headers, 'V2').validate_user_token
          expect(user.name).to eq valid_user.name
          expect(user.id).to eq valid_user.id
        end
      end

      context 'when the authorization headers are not present' do
        it 'does not find any third party application keys' do
          result = described_class.new({}, 'V2').validate_user_token
          expect(result).to be_nil
        end
      end

      context 'when the authorization-Token does not specify the Bearer work' do
        it 'finds the right third party application' do
          user = described_class.new(
            different_headers_format,
            'V2'
          ).validate_user_token
          expect(user.name).to eq valid_user.name
          expect(user.id).to eq valid_user.id
        end
      end
    end
  end
end
