require 'rails_helper'

RSpec.describe V1::UserRegistrationsController, type: :controller do

  describe '#create' do
    let(:expected_keys) do
      [
        :email,
        :name,
        :country_international_code,
        :mobile_number,
        :api_authorization_token,
        :api_authorization_client
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
      let(:user_email) { 'email@example.com' }

      context 'when the email does not exist in the database' do
        let(:params) do
          {
            user: {
              email: user_email,
              name: 'name goes here',
              password: 'password1'
            }
          }
        end

        it 'creates a new user' do
          process :create, method: :post, params: params
          expect(response.status).to eq 200
          expect(response_body[:data][:attributes].keys).to eq expected_keys
        end

        it 'includes the right token headers' do
          process :create, method: :post, params: params
          headers = response.headers
          expect(headers.keys).to include 'Authorization-Client'
          expect(headers.keys).to include 'Authorization-Token'
          expect(response.status).to eq 200
        end
      end

      context 'when the email already exists in the database' do
        before do
          create(:user, email: user_email)
        end

        it 'does not create a new user' do
          params = {
            user: {
              email: user_email,
              name: 'name goes here',
              password: 'password1'
            }
          }
          process :create, method: :post, params: params
          expect(response.status).to eq 422
          email_msg = response_body[:data][:errors][:email]
          expect(email_msg.first).to include('has already been take')
        end
      end
    end
  end
end

