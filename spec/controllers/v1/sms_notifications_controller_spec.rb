require 'rails_helper'

RSpec.describe V1::SmsNotificationsController, type: :controller do
  describe '#create' do
    let(:firebase_token) { 'firebase-token' }
    let(:sms_mobile_hub) do
      create(:sms_mobile_hub, firebase_token: firebase_token)
    end

    before do
      inject_user_headers_on_controller(sms_mobile_hub.user)
    end

    context 'when the params are valid' do
      let(:message) do
        'Hola h, xxx x xxxxx xxxxxx xxxxxxxxxxxxx xxxxxxxx xxxxxxxx xx x xxxx xxxxx xxxxxxx xxxxxx xxxxxxx xxxxxxx xxxxxx xxxxxxx xxxxxxx xxxxxxxx xxxxxxx xxxxxx xx fin'
      end

      let(:sms_notification_params) do
        {
          hub_uuid: sms_mobile_hub.reload.uuid,
          sms_notification: {
            sms_content: message,
            sms_number: '+523121231517',
            sms_type: 'standard_delivery'
          }
        }
      end

      context 'when the sms mobile uuid is valid' do
        it 'creates a new sms notification' do
          process :create, method: :post, params: sms_notification_params
          expect(response.status).to eq 200
          keys = response_body[:data][:attributes].keys
          expect(keys).to include(:sms_content)
          expect(keys).to include(:sms_number)
          expect(keys).to include(:status)
          expect(keys).to include(:processed_by_sms_mobile_hub_id)
          expect(keys).to include(:sms_type)
        end

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
            sms_notification_params[:sms_notification][:sms_type] = 'urgent_delivery'
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
          sms_notification_params[:hub_uuid] = 'xxxx'
        end

        it 'does not create any sms notifications' do
          process :create, method: :post, params: sms_notification_params
          expect(response.status).to eq 404
        end
      end
    end

    context 'when the params are invalid' do
      let(:sms_notification_params) do
        {
          hub_uuid: sms_mobile_hub.reload.uuid,
          sms_notification: {
            sms_content: 'Hola heriberto, gracias por visitar pacientesweb.com',
            sms_type: 'standard_delivery'
          }
        }
      end

      it 'does not create a sms notification' do
        process :create, method: :post, params: sms_notification_params
        expect(response.status).to eq 422
        expect(response_body[:data][:errors][:sms_number]).to eq ['no puede estar en blanco']
      end
    end
  end
end
