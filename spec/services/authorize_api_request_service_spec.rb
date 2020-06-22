# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AuthorizeApiRequestService do
  describe '.validate_user_token' do

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
end
