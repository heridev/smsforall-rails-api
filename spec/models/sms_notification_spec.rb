require 'rails_helper'

RSpec.describe SmsNotification, type: :model do
  let(:user) { create(:user, email: 'newemail@example.com') }
  let(:sms_mobile_hub) do
    create(
      :sms_mobile_hub,
      :activated,
      device_number: '3121232030',
      user: user
    )
  end
  let(:message) do
    'Hola ' * 100
  end
  let(:sms_notification_params) do
    {
      hub_id: sms_mobile_hub.id,
      user_id: user.id,
      sms_content: message,
      sms_number: '+523121231517',
      sms_type: 'standard_delivery'
    }
  end

  describe '#update_status' do
    let!(:sms_notification) do
      described_class.create_record(sms_notification_params)
    end

    let(:failing_params) do
      {
        additional_update_info: 'generic failure',
        status: 'undelivered'
      }
    end

    let(:success_delivered) do
      {
        additional_update_info: '',
        status: 'delivered'
      }
    end

    context 'when the sms notification fails to be delivered' do
      it 'enqueues the sms notification again' do
        expect do
          sms_notification.update_status(failing_params)
        end.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
      end
    end

    context 'when the sms fails to be delivered but already tried it twice' do
      before do
        sms_notification.update(number_of_intents_to_be_delivered: 2)
      end

      it 'does not enqueue the sms notification again' do
        expect do
          sms_notification.update_status(failing_params)
        end.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(0)
      end
    end

    context 'when the sms notification was delivered successfully' do
      it 'does not enqueue the sms notification again' do
        expect do
          sms_notification.update_status(success_delivered)
        end.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(0)
      end
    end
  end

  describe '.create_record' do
    context 'when the params are valid' do
      it 'creates the record' do
        result = described_class.create_record(sms_notification_params)
        expect(result.valid?).to be_truthy
      end

      context 'when the sms_type is not present' do
        it 'creates the record with the default sms_type' do
          sms_notification_params[:sms_type] = nil
          result = described_class.create_record(sms_notification_params)
          expect(result.valid?).to be_truthy
        end
      end
    end

    context 'when params are invalid' do
      context 'when the user_id is not present' do
        it 'does not create the record' do
          sms_notification_params[:user_id] = nil
          result = described_class.create_record(sms_notification_params)
          expect(result.valid?).to be_falsey
        end
      end

    end
  end
end

