require 'rails_helper'

RSpec.describe V1::PublicSmsNotificationsController, type: :controller do
  describe '#create' do
    context 'when the params are not valid' do
      it 'does not enqueue the sms notification message' do
        params = {
          sms_notification: {
            sms_content: 'some content without sms_number'
          }
        }
        process :create, method: :post, params: params
        expect(response.status).to eq 422
        error_message = response_body[:data][:error]
        expect(error_message).to be_present
      end
    end

    context 'when the params are valid' do
      let(:params) do
        {
          sms_notification: {
            sms_content: 'some content without sms_number',
            sms_number: '+523121231111'
          }
        }
      end

      it 'responds with a success message' do
        process :create, method: :post, params: params
        expect(response.status).to eq 200
        message = 'We will be sending your message shortly'
        expect(response_body[:data][:message]).to eq message
      end

      it 'enqueues the message to be sent soon' do
        process :create, method: :post, params: params
        job = find_enqueued_job_by(ServiceEnqueuerJob)
        expect(job[:args].size).to eq 3
        expect(job[:job]).to eq ServiceEnqueuerJob
        expect(job[:queue]).to eq 'urgent_delivery'
      end
    end
  end
end
