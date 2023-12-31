# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SmsNotificationSenderJob, type: :job do
  let(:user) { create(:user, mobile_number: '3121899980') }
  let(:sms_mobile_hub) { create(:sms_mobile_hub) }
  let(:sms_notification) do
    create(:sms_notification, user: user, assigned_to_mobile_hub: sms_mobile_hub)
  end

  # We expect 2 jobs as he user creation always create an additional one
  it 'enqueues the job' do
    expect do
      described_class.perform_later(sms_mobile_hub.id, sms_notification.id)
    end.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(2)
  end

  it 'jobs is added to the default queue' do
    expect(described_class.new.queue_name).to eq('standard_delivery')
  end
end
