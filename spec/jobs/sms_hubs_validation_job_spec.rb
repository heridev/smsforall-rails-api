require 'rails_helper'

RSpec.describe SmsHubsValidationJob, type: :job do
  let(:sms_mobile_hub) { create(:sms_mobile_hub) }

  let(:params) do
    {
      device_token_code: sms_mobile_hub.temporal_password,
      firebase_token: 'xd7kl.dktj39rkd93k83ld83dd'
    }
  end

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

  before do
    allow_any_instance_of(FCM).to receive(:send_v1).and_return(valid_firebase_response)
  end

  # We expect 2 jobs as the sms_mobile_hub and user internally spins a new job
  it 'enqueues the job' do
    expect do
      described_class.perform_later(params)
    end.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(2)
  end

  it 'jobs is added to the default queue' do
    expect(described_class.new.queue_name).to eq('urgent_delivery')
  end

  it 'updates and marks the mobile hub as activation in progress' do
    perform_enqueued_jobs do
      described_class.perform_later(params)
    end

    expect(
      sms_mobile_hub.reload.status
    ).to eq SmsMobileHub::STATUSES[:activation_in_progress]

    expect(
      sms_mobile_hub.firebase_token
    ).to be_present
  end
end
