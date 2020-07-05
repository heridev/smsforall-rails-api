require 'rails_helper'

RSpec.describe V1::SmsMobileHubsController, type: :controller do
  let(:user) do
    create(:user, mobile_number: '3121231617')
  end

  describe '#index' do
    let(:firebase_token) { 'firebase-token' }
    let(:sms_mobile_hub) do
      create(:sms_mobile_hub, firebase_token: firebase_token, user: user)
    end

    context 'when the user has sms mobile hub records' do
      before do
        inject_user_headers_on_controller(sms_mobile_hub.user)
      end

      it 'includes only the ones that belong to that user' do
        get :index, method: :get
        expect(response.status).to eq 200
        data = response_body[:data]
        expect(data.size).to eq 1
        expect(data.first[:attributes][:uuid]).to eq sms_mobile_hub.reload.uuid
      end
    end

    context 'when the user does not have sms mobile hub records' do
      before do
        inject_user_headers_on_controller
      end

      it 'responds with zero records' do
        get :index, method: :get
        expect(response.status).to eq 200
        expect(response_body[:data].size).to eq 0
      end
    end
  end

  describe '#activated' do
    let(:firebase_token) { 'firebase-token' }
    let(:sms_mobile_hub) do
      create(:sms_mobile_hub, :activated, firebase_token: firebase_token)
    end
    let!(:sms_mobile_hub_two) do
      create(
        :sms_mobile_hub,
        device_name: 'new device 1',
        device_number: '3121708994',
        firebase_token: 'y.283dj87dlk2838kljd.dkl3/389djkd',
        user: sms_mobile_hub.user
      )
    end
    let!(:sms_mobile_hub_three) do
      create(
        :sms_mobile_hub,
        device_name: 'new device 2',
        device_number: '3121231718',
        firebase_token: 'y.283dj87dlk2',
        user: sms_mobile_hub.user
      )
    end

    context 'when the user has sms mobile hub records' do
      before do
        inject_user_headers_on_controller(sms_mobile_hub.user)
      end

      it 'includes only the ones that belong to that user and are activated' do
        get :activated, method: :get
        expect(response.status).to eq 200
        data = response_body[:data]
        expect(data.size).to eq 1
        expect(data.first[:attributes][:uuid]).to eq sms_mobile_hub.reload.uuid
      end
    end

    context 'when the user does not have sms mobile hub records' do
      before do
        inject_user_headers_on_controller(user)
      end

      it 'responds with zero records' do
        get :activated, method: :get
        expect(response.status).to eq 200
        expect(response_body[:data].size).to eq 0
      end
    end
  end

  describe '#create' do
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

    context 'when the params are valid' do
      let(:sms_mobile_params) do
        {
          sms_mobile_hub: {
            device_name: 'mi tablet',
            device_number: '3121231517'
          }
        }
      end

      context 'when the token authorization is valid' do
        it 'creates a new sms mobile hub record' do
          headers = {
            'Authorization-Token' => "Bearer #{valid_token}",
            'Authorization-Client' => valid_user.jwt_salt
          }
          request.headers.merge! headers
          process :create, method: :post, params: sms_mobile_params
          keys = response_body[:data][:attributes].keys
          expect(keys).to include(:device_name)
          expect(keys).to include(:device_number)
          expect(response.status).to eq 200
        end
      end

      context 'when the token authorization is invalid' do
        it 'does not create a new sms mobile hub record' do
          process :create, method: :post, params: sms_mobile_params
          expect(response.status).to eq 401
        end
      end
    end

    context 'when the params are invalid' do
      let(:sms_mobile_params) do
        {
          sms_mobile_hub: {
            device_number: '3121231517'
          }
        }
      end

      context 'when the token authorization is valid' do
        it 'creates a new sms mobile hub record' do
          headers = {
            'Authorization-Token' => "Bearer #{valid_token}",
            'Authorization-Client' => valid_user.jwt_salt
          }
          request.headers.merge! headers
          process :create, method: :post, params: sms_mobile_params
          expect(response.status).to eq 422
          expect(response_body[:data][:errors][:device_name]).to eq ["no puede estar en blanco"]
        end
      end
    end
  end

  describe '#validate' do
    let(:sms_mobile_hub) { create(:sms_mobile_hub) }

    context 'when the information is valid' do
      let(:sms_mobile_params) do
        {
          sms_mobile_hub: {
            device_token_code: sms_mobile_hub.temporal_password,
            firebase_token: 'xksdk939393933.29j23lkjlsdfds'
          }
        }
      end

      context 'when the sms_mobile_hub password is valid' do
        it 'enqueues a new job that will process the mobile hub validation' do
          process :validate, method: :post, params: sms_mobile_params
          job = find_enqueued_job_by(SmsHubsValidationJob)
          expect(job[:args].first.keys).to include 'device_token_code'
          expect(job[:args].first.keys).to include 'firebase_token'
        end
      end
    end

    context 'when the information is invalid' do
      let(:sms_mobile_params) do
        {
          sms_mobile_hub: {
            device_token_code: sms_mobile_hub.temporal_password,
            firebase_token: 'xksdk939393933.29j23lkjlsdfds'
          }
        }
      end

      context 'when the sms_mobile_hub password is valid but the firebase token is not present' do
        before do
          sms_mobile_params[:sms_mobile_hub][:firebase_token] = nil
        end

        it 'responds with a not found error' do
          process :validate, method: :post, params: sms_mobile_params
          expect(response.status).to eq 404
        end
      end

      context 'when the sms_mobile_hub password is invalid' do
        before do
          sms_mobile_params[:sms_mobile_hub][:device_token_code] = nil
        end

        it 'responds with a not found error' do
          process :validate, method: :post, params: sms_mobile_params
          expect(response.status).to eq 404
        end
      end

      context 'when the sms_mobile_hub password is valid but the mobile hub was already validated' do
        before do
          sms_mobile_hub.mark_as_activation_in_progress!
        end

        it 'responds with a not found error' do
          process :validate, method: :post, params: sms_mobile_params
          expect(response.status).to eq 404
        end
      end
    end
  end

  describe '#show' do
    let(:firebase_token) { 'firebase-token' }
    let(:sms_mobile_hub) do
      create(:sms_mobile_hub, firebase_token: firebase_token)
    end

    before do
      inject_user_headers_on_controller(sms_mobile_hub.user)
    end

    context 'when the sms mobile hub uuid is valid' do
      it 'responds with the correct attributes' do
        params = { uuid: sms_mobile_hub.reload.uuid }
        get :show, method: :get, params: params
        attrs = response_body[:data][:attributes]
        expect(attrs[:device_name]).to eq 'Mi nueva tablet'
        expect(attrs[:temporal_password]).to eq sms_mobile_hub.temporal_password
        expect(response.status).to eq 200
      end
    end

    context 'when the sms mobile hub uuid is not valid' do
      it 'responds with a 404 status code' do
        params = { uuid: 'xxxx-xxx' }
        get :show, method: :get, params: params
        expect(response_body[:data][:error]).to be_present
        expect(response.status).to eq 404
      end
    end
  end

  describe '#destroy' do
    let(:firebase_token) { 'firebase-token' }
    let(:sms_mobile_hub) do
      create(:sms_mobile_hub, firebase_token: firebase_token)
    end

    before do
      inject_user_headers_on_controller(sms_mobile_hub.user)
    end

    context 'when the sms mobile hub uuid is valid' do
      it 'destroys the mobile device' do
        params = { uuid: sms_mobile_hub.reload.uuid }
        delete :destroy, method: :delete, params: params
        data = response_body[:data]
        expect(data[:message]).to be_present
        expect(response.status).to eq 200
      end
    end

    context 'when the sms mobile hub uuid is not valid' do
      it 'responds with a 404 status code' do
        params = { uuid: 'xxxx-xxx' }
        delete :destroy, method: :delete, params: params
        expect(response.status).to eq 404
      end
    end
  end

  describe '#activate' do
    let(:firebase_token) { 'firebase-token' }
    let(:sms_mobile_hub) do
      create(:sms_mobile_hub, firebase_token: firebase_token)
    end
    let(:sms_notification) do
      create(:sms_notification, user: user, assigned_to_mobile_hub: sms_mobile_hub)
    end

    context 'when the information is valid' do
      let(:sms_mobile_params) do
        {
          sms_notification_uid: sms_notification.reload.unique_id,
          firebase_token: sms_mobile_hub.firebase_token
        }
      end

      before do
        process :activate, method: :post, params: sms_mobile_params
        sms_mobile_hub.reload
        sms_notification.reload
      end

      it 'marks sms notification as delivered' do
        expect(response.status).to eq 200
        expect(
          sms_notification.processed_by_sms_mobile_hub_id
        ).to eq sms_mobile_hub.id
        expect(sms_notification.status).to eq 'delivered'
        expect(sms_notification.delivered_at).to be_present
      end

      it 'marks the mobile hub as activated' do
        expect(response.status).to eq 200
        expect(sms_mobile_hub.status).to eq 'activated'
        expect(sms_mobile_hub.activated_at).to be_present
      end
    end

    context 'when the information is invalid' do
      let(:sms_mobile_params) do
        {
          sms_notification_uid: sms_notification.unique_id,
          firebase_token: 'invalid-firebase-token'
        }
      end

      before do
        process :activate, method: :post, params: sms_mobile_params
        sms_mobile_hub.reload
        sms_notification.reload
      end

      it 'does not mark sms notification as delivered' do
        expect(response_body[:data][:error]).to be_present
        expect(response.status).to eq 404
        expect(
          sms_notification.processed_by_sms_mobile_hub_id
        ).to be_nil
        expect(sms_notification.status).to_not eq 'delivered'
        expect(sms_notification.delivered_at).to_not be_present
      end

      it 'does not mark the mobile hub as activated' do
        expect(response.status).to eq 404
        expect(sms_mobile_hub.status).to_not eq 'activated'
        expect(sms_mobile_hub.activated_at).to_not be_present
      end

    end
  end
end
