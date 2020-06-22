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

        it 'returns the user information attributes' do
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

  describe '#show' do
    let(:user_params) do
      {
        email: 'p@elh.mx',
        password: 'password1',
        name: 'Heriberto Perez'
      }
    end
    let(:valid_user) { User.persist_values(user_params) }
    let!(:valid_token) do
      JwtTokenService.encode_token(
        { user_id: valid_user.id },
        valid_user.jwt_salt
      )
    end

    context 'when the authorization tokens are valid' do
      before do
        headers = {
          'Authorization-Token' => "Bearer #{valid_token}",
          'Authorization-Client' => valid_user.jwt_salt
        }
        request.headers.merge! headers
      end

      it 'responds with the user details' do
        get :user_details_by_token, method: :get
        data = response_body[:data][:attributes]
        expect(data.keys).to include(:email)
        expect(data.keys).to include(:name)
        expect(response.status).to eq 200
      end
    end

    context 'when the authorization tokens are NOT valid' do
      before do
        headers = {
          'Authorization-Token' => 'Bearer xxxxx',
          'Authorization-Client' => valid_user.jwt_salt
        }
        request.headers.merge! headers
      end

      it 'does not return any user details' do
        get :user_details_by_token, method: :get
        expect(response.status).to eq 401
      end
    end
  end
end
