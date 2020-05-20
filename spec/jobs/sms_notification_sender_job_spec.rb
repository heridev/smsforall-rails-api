require 'rails_helper'

RSpec.describe SmsNotificationSenderJob, type: :job do
  let(:sms_mobile_hub) { create(:sms_mobile_hub) }
  let(:sms_notification) { create(:sms_notification) }

  it 'enqueues the job' do
    expect do
      described_class.perform_later(sms_mobile_hub.id, sms_notification.id)
    end.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it 'jobs is added to the default queue' do
    expect(described_class.new.queue_name).to eq('default')
  end
end
