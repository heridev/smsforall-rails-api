require 'rails_helper'

class MyServiceClass
  def self.create_message
    'new message'
  end
end

RSpec.describe ServiceEnqueuerJob, type: :job do
  it 'enqueues the job' do
    expect do
      described_class.perform_later(
        'SmsAccountActivatorService',
        'send_notification',
        { value: 'value' }
      )
    end.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it 'jobs is added to the default queue' do
    expect(described_class.new.queue_name).to eq('urgent_delivery')
  end

  it 'enqueues a service class method to be executed in background' do
    perform_enqueued_jobs do
      described_class.perform_later(
        'MyServiceClass',
        'create_message',
        {}
      )
    end

    # Two jobs per mobile hub
    # and the described_class
    expect(
      ActiveJob::Base.queue_adapter.performed_jobs.size
    ).to eq 1
  end
end
