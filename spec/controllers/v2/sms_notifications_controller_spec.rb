# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V2::SmsNotificationsController, type: :controller do
  let(:user) do
    user = create(:user)
    UserPreparatorService.new(user)
    user
  end
  let(:other_user) do
    user = create(:user, mobile_number: '3121231718')
    UserPreparatorService.new(user)
    user
  end

  describe '#create' do
    let(:firebase_token) { 'firebase-token' }
    let(:sms_mobile_hub) do
      create(
        :sms_mobile_hub,
        firebase_token: firebase_token,
        user: other_user
      )
    end
    let(:expected_keys) do
      %i[
        sms_customer_reference_id
        sms_content
        sms_number
        mobile_hub_id
        api_version
        date_created
        status
        error_message
      ]
    end

    before do
      inject_user_headers_on_v2_controller(sms_mobile_hub.user)
    end

    context 'when the params are valid' do
      let(:sms_customer_reference_id) do
        '2873937'
      end
      let(:sms_content) do
        'Hola h, xxx x xxxxx xxxxxx xxxxxxxxxxxxx xxxxxxxx xxxxxxxx xx x xxxx xxxxx xxxxxxx xxxxxx xxxxxxx xxxxxxx xxxxxx xxxxxxx xxxxxxx xxxxxxxx xxxxxxx xxxxxx xx fin'
      end
      let(:sms_notification_params) do
        {
          mobile_hub_id: sms_mobile_hub.reload.uuid,
          sms_number: '+523121231111',
          sms_type: 'standard_delivery', # o urgent_delivery
          sms_content: sms_content,
          sms_customer_reference_id: sms_customer_reference_id # opcional - un valor de referencia de hasta 128 caracteres, con el cual puedes consultar despues el estado actual de dicho mensaje de texto
        }
      end

      context 'when the minute limit is reached' do
        before do
          25.times do
            process :create, method: :post, params: sms_notification_params
            expect(response.status).to eq 200
          end
        end

        it 'does not create a new sms notification' do
          process :create, method: :post, params: sms_notification_params
          expect(response.status).to eq 422
          expect(response_body.keys).to eq expected_keys
        end
      end

      context 'when params are valid' do
        context 'when the sms_type is set as the standard delivery method' do
          it 'enqueues the sms notification to be sent in the right queue' do
            process :create, method: :post, params: sms_notification_params
            job = find_enqueued_job_by(SmsNotificationSenderJob)
            expect(job[:args].size).to eq 2
            expect(job[:queue]).to eq 'standard_delivery'
          end
        end

        context 'when the sms_type is set as the urgent delivery method' do
          before do
            sms_notification_params[:sms_type] = 'urgent_delivery'
          end

          it 'enqueues the sms notification to be sent in the right queue' do
            process :create, method: :post, params: sms_notification_params
            job = find_enqueued_job_by(UrgentSmsNotificationSenderJob)
            expect(job[:args].size).to eq 2
            expect(job[:queue]).to eq 'urgent_delivery'
          end
        end
      end

      context 'when the sms mobile uuid is not valid' do
        before do
          sms_notification_params[:mobile_hub_id] = 'xxxx'
        end

        it 'does not create the sms notification' do
          process :create, method: :post, params: sms_notification_params
          expect(response.status).to eq 422
          expect(response_body[:error_message]).to match('The mobile_hub_id is invalid')
        end
      end
    end

    context 'when the params are invalid' do
      let(:sms_notification_params) do
        {
          mobile_hub_id: sms_mobile_hub.reload.uuid,
          sms_type: 'standard_delivery',
          sms_content: 'example content',
          sms_customer_reference_id: ''
        }
      end

      it 'does not create a sms notification' do
        process :create, method: :post, params: sms_notification_params
        expect(response.status).to eq 422
        expect(response_body[:error_message]).to match("sms_number - can't be blank")
      end
    end
  end
end
