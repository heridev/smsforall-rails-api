# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  let(:valid_params) do
    {
      email: 'p@elh.mx',
      password: 'password1',
      name: 'Heriberto Perez'
    }
  end

  describe '.persist_values' do
    context 'when the params are valid' do
      it 'creates a new user with valid tokens' do
        user = User.persist_values(valid_params)
        expect(user.valid?).to be_truthy
      end
    end

    context 'when the params are invalid' do
      it 'does not create a new user with valid tokens' do
        invalid_params = valid_params
        invalid_params[:password] = nil
        user = User.persist_values(invalid_params)
        expect(user.errors.full_messages.first).to match(/Passwor/)
        expect(user.valid?).to be_falsey
      end
    end
  end

  describe '.encode_token.decode_token' do
    let(:password_value) { 'passwordvalue' }
    let(:password_salt) { BCrypt::Engine.generate_salt }
    let(:password_hash) { { password: password_value } }

    context 'when the decodes is valid' do
      it 'encodes and decodes a valid token' do
        token_encoded = User.encode_token(password_hash, password_salt)
        decoded_token = User.decode_token(token_encoded, password_salt)
        expect(decoded_token[:password]).to eq password_value
      end
    end
  end

  describe '.valid_authentication?' do
    let!(:valid_user) { User.persist_values(valid_params) }

    context 'when the email and password are valid' do
      it 'returns the user when' do
        result = User.auth_by_email_and_password(
          valid_params[:email],
          valid_params[:password]
        )

        expect(result.email).to eq valid_params[:email]
      end
    end

    context 'when the email and password are invalid' do
      it 'returns the user when' do
        result = User.auth_by_email_and_password(
          valid_params[:email],
          'otherpass'
        )
        expect(result).to be_falsey
      end
    end
  end
end
