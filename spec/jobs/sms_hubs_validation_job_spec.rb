require 'rails_helper'

RSpec.describe SmsHubsValidationJob, type: :job do
  let(:sms_mobile_hub) { create(:sms_mobile_hub) }

  let(:params) do
    {
      device_token_code: sms_mobile_hub.temporal_password,
      firebase_token: 'xd7kl.dktj39rkd93k83ld83dd'
    }
  end

  it 'enqueues the job' do
    expect do
      described_class.perform_later(params)
    end.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
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
