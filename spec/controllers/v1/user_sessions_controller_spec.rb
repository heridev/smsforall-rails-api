require 'rails_helper'

RSpec.describe V1::UserSessionsController, type: :controller do

  describe '#create' do
    context 'when the user exists' do
      let(:valid_params) do
        {
          email: 'p@elh.mx',
          password: 'password1',
          name: 'Heriberto Perez'
        }
      end

      let!(:valid_user) { User.persist_values(valid_params) }

      context 'when the email and password are valid' do
        it 'returns some valid tokens included in headers' do
          process :create, method: :post, params: valid_params
          headers = response.headers
          expect(headers.keys).to include 'Authorization-Client'
          expect(headers.keys).to include 'Authorization-Token'
          expect(response.status).to eq 200
        end

        it 'returns a valid decoded token' do
          process :create, method: :post, params: valid_params
          data = response_body[:data][:attributes]
          expect(data.keys).to include(:email)
          expect(data.keys).to include(:name)
          expect(response.status).to eq 200
        end
      end

      context 'when the email and password are invalid' do
        it 'does not return a valid JWT token' do
          valid_params[:password] = 'password'
          process :create, method: :post, params: valid_params
          error_msg = 'Las credenciales son incorrectas..'
          expect(response_body[:data][:error]).to eq error_msg
          expect(response.status).to eq 401
        end
      end
    end

    context 'when the user does not exist' do
      let(:invalid_params) do
        {
          email: 'p@elh.mx',
          password: 'password1'
        }
      end

      context 'when the email and password are valid' do
        it 'returns a valid JWT token based on the user.id' do
          process :create, method: :post, params: invalid_params
          error_msg = 'Las credenciales son incorrectas..'
          expect(response_body[:data][:error]).to eq error_msg
          expect(response.status).to eq 401
        end
      end
    end
  end
end

