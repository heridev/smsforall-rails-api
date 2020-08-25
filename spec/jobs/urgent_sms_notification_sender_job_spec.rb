# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UrgentSmsNotificationSenderJob, type: :job do
  before do
    ActiveJob::Base.queue_adapter.enqueued_jobs.clear
    ActiveJob::Base.queue_adapter.performed_jobs.clear
  end

  let!(:user) { create(:user, mobile_number: '3121789090') }
  let!(:sms_mobile_hub) do
    create(:sms_mobile_hub, device_number: '3121789090', user: user)
  end
  let(:sms_notification) { create(:sms_notification, user: user) }
  let(:valid_firebase_response) do
    {
      status_code: 200,
      body: {
        multicast_id: 8_573_675_465_357_843_813,
        success: 1,
        failure: 0,
        canonical_ids: 0
      }.to_json
    }
  end

  it 'jobs is added to the default queue' do
    expect(described_class.new.queue_name).to eq('urgent_delivery')
  end

  it 'marks the sms notification as marks as failure' do
    perform_enqueued_jobs do
      described_class.perform_later(sms_notification.id, sms_mobile_hub.id)
    end

    job = find_performed_job_by(UrgentSmsNotificationSenderJob)
    expect(job).to be_present
    expect(sms_notification.reload.status).to eq 'failed_sent_to_firebase'
  end
end

