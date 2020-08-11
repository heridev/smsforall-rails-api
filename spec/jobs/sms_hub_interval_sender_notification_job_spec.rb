require 'rails_helper'

RSpec.describe SmsHubIntervalSenderNotificationJob, type: :job do
  let(:user) { create(:user) }
  let!(:sms_mobile_hub) { create(:sms_mobile_hub, user: user) }
  let!(:sms_mobile_hub_activated_one) do
    create(
      :sms_mobile_hub,
      :activated,
      device_number: '3121698453',
      user: user
    )
  end
  let!(:sms_mobile_hub_activated_two) do
    create(
      :sms_mobile_hub,
      :activated,
      device_number: '3121128453',
      user: user
    )
  end

  it 'enqueues the job' do
    expect do
      described_class.perform_later
    end.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it 'jobs is added to the default queue' do
    expect(described_class.new.queue_name).to eq('standard_delivery')
  end

  it 'enqueues the jobs to create new notifications and deliver them' do
    perform_enqueued_jobs do
      described_class.perform_later
    end

    # Two jobs per mobile hub
    # and the described_class
    expect(
      ActiveJob::Base.queue_adapter.performed_jobs.size
    ).to eq 5
  end
end
