# frozen_string_literal: true

require 'rails_helper'

RSpec.describe JwtTokenService do

  describe '.encode_token.decode_token' do
    let(:password_value) { 'passwordvalue' }
    let(:password_salt) { BCrypt::Engine.generate_salt }
    let(:password_hash) { { password: password_value } }

    context 'when the secret_key_base is not provided' do
      it 'returns a valid encode and decode' do
        token_encoded = described_class.encode_token(password_hash)
        decoded_token = described_class.decode_token(token_encoded)
        expect(decoded_token[:password]).to eq password_value
      end
    end

    context 'when the secret_key_base is provided' do
      it 'encodes and decodes a valid token' do
        token_encoded = described_class.encode_token(password_hash, password_salt)
        decoded_token = described_class.decode_token(token_encoded, password_salt)
        expect(decoded_token[:password]).to eq password_value
      end
    end

    context 'when the decodes is invalid' do
      it 'does not match the password decoded' do
        token_encoded = described_class.encode_token(password_hash, password_salt)
        decoded_token = described_class.decode_token(token_encoded, 'different-salt-value')
        expect(decoded_token).to be_nil
      end
    end
  end
end
