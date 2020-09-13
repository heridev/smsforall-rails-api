# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SmsHubNotificationSenderService do
  let(:user) { create(:user, mobile_number: '3121899980') }

  describe '#create_and_enque_sms!' do
    let(:sms_notification) { create(:sms_notification, user: user) }
    let(:sms_notification_two) do
      create(:sms_notification, sms_number: '+523121708994', user: user)
    end
    let(:sms_mobile_hub) do
      create(:sms_mobile_hub, :activated, device_number: '31211231718', user: user)
    end
    let(:sms_mobile_hub_two) do
      create(:sms_mobile_hub, :activated, device_number: '3121708994', user: user)
    end

    context 'when the DEFAULT_MASTER_RECEIVER_PHONE_NUMBER is NOT set' do
      context 'when the mobile hub is valid' do
        it 'creates and enqueues a new sms notification' do
          service = described_class.new(
            sms_mobile_hub.id
          )
          service.create_and_enque_sms!
          job = find_enqueued_job_by(SmsNotificationSenderJob)
          expect(job[:args].size).to eq 2
          expect(job[:queue]).to eq 'standard_delivery'
          sms_notification = SmsNotification.find(job[:args].first)
          expect(sms_notification.status).to eq SmsNotification::STATUSES[:pending]
          expect(sms_notification.sms_type).to eq SmsNotification::SMS_TYPES[:schedule_checker]
          expect(sms_notification.sms_number).to eq sms_mobile_hub.find_international_number
        end
      end

      context 'when the mobile hub is not valid' do
        it 'does not create any new sms notification' do
          service = described_class.new(
            'invalidid'
          )
          service.create_and_enque_sms!
          enqueued_jobs = ActiveJob::Base.queue_adapter.enqueued_jobs
          expect(enqueued_jobs.size).to be_zero
        end
      end
    end

    context 'when the DEFAULT_MASTER_RECEIVER_PHONE_NUMBER is set' do
      let(:default_phone_number) { '+523121231517' }
      before { ENV['DEFAULT_MASTER_RECEIVER_PHONE_NUMBER'] = default_phone_number }
      after { ENV['DEFAULT_MASTER_RECEIVER_PHONE_NUMBER'] = nil }

      it 'creates and enqueues a new sms notification' do
        service = described_class.new(
          sms_mobile_hub_two.id
        )
        service.create_and_enque_sms!
        job = find_enqueued_job_by(SmsNotificationSenderJob)
        expect(job[:args].size).to eq 2
        expect(job[:queue]).to eq 'standard_delivery'
        sms_notification = SmsNotification.find(job[:args].first)
        expect(sms_notification.sms_content).to match(/Verificación automática/)
        expect(sms_notification.sms_content).to match(/desde Mi nueva tablet/)
        expect(sms_notification.status).to eq SmsNotification::STATUSES[:pending]
        expect(sms_notification.sms_number).to eq default_phone_number
      end
    end
  end
end
