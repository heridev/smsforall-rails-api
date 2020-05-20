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
        it 'returns a valid JWT token based on the user.id' do
          process :create, method: :post, params: valid_params
          expect(response_body[:data][:token_auth]).to be_present
          expect(response.status).to eq 200
        end
      end

      context 'when the email and password are invalid' do
        it 'does not return a valid JWT token' do
          valid_params[:password] = 'password'
          process :create, method: :post, params: valid_params
          error_msg = 'Las credenciales son incorrectas..'
          expect(response_body[:data][:error]).to eq error_msg
          expect(response.status).to eq 422
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
          expect(response.status).to eq 422
        end
      end
    end
  end
end

