# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SmsHubNotificationSenderJob, type: :job do
  let(:user) { create(:user) }
  let!(:sms_mobile_hub) { create(:sms_mobile_hub, user: user) }
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

  it 'enqueues the job' do
    expect do
      described_class.perform_later(sms_mobile_hub.id)
    end.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it 'jobs is added to the default queue' do
    expect(described_class.new.queue_name).to eq('standard_delivery')
  end

  it 'updates and marks the mobile hub as activation in progress' do
    allow_any_instance_of(FCM).to receive(
      :send_v1
    ).and_return(valid_firebase_response)

    perform_enqueued_jobs do
      described_class.perform_later(sms_mobile_hub.id)
    end

    # Two jobs per mobile hub
    # and the described_class
    expect(
      ActiveJob::Base.queue_adapter.performed_jobs.size
    ).to eq 2

    sms_created = SmsNotification.find_by(
      assigned_to_mobile_hub_id: sms_mobile_hub.id
    )
    expect(sms_created).to be_present
    expect(sms_created.status).to eq 'failed_sent_to_firebase'
  end
end
