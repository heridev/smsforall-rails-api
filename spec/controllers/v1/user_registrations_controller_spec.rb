require 'rails_helper'

RSpec.describe V1::UserRegistrationsController, type: :controller do

  describe '#create' do
    let(:expected_keys) do
      [
        :email,
        :name
      ]
    end

    context 'when the params are not valid' do
      it 'does not create a new user' do
        params = {
          user: {
            name: 'name goes here'
          }
        }
        process :create, method: :post, params: params
        body_errors = response_body[:data][:errors]
        password_error = body_errors[:password_salt]
        email_error = body_errors[:email]
        expect(password_error).to be_present
        expect(email_error).to be_present
        expect(response.status).to eq 422
      end
    end

    context 'when the params are valid' do
      it 'returns a valid user data created' do
        params = {
          user: {
            email: 'email@example.com',
            name: 'name goes here',
            password: 'password1'
          }
        }
        process :create, method: :post, params: params
        expect(response.status).to eq 200
        expect(response_body[:data][:attributes].keys).to eq expected_keys
      end
    end
  end
end

