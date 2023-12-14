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

  context "when the current time is early than 11 pm mexico's time" do

    before do
      current_time = Time.parse('2020-05-25 22:59:47 -0500')
      travel_to current_time
    end

    after do
      travel_back
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

  context 'when the checker is disabled temporarily' do
    before do
      current_time = Time.parse('2020-05-25 06:01:47 -0500')
      travel_to current_time
      ENV['AUTOMATIC_SMS_CHECKER_DISABLED'] = 'true'
    end

    after do
      travel_back
      ENV['AUTOMATIC_SMS_CHECKER_DISABLED'] = nil
    end

    it 'does not enqueue any jobs' do
      perform_enqueued_jobs do
        described_class.perform_later
      end

      expect(
        ActiveJob::Base.queue_adapter.performed_jobs.size
      ).to eq 1
    end
  end

  context "when the current time is late than 6 am mexico's time" do
    before do
      current_time = Time.parse('2020-05-25 06:01:47 -0500')
      travel_to current_time
    end

    after do
      travel_back
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

  context "when the current time is later than 11 pm mexico's time" do
    before do
      ENV['ENABLED_OFFICE_HOURS_SMS_CHECKER_CONTROL'] = 'true'
      current_time = Time.parse('2020-05-25 23:01:47 -0500')
      travel_to current_time
    end

    after do
      ENV['ENABLED_OFFICE_HOURS_SMS_CHECKER_CONTROL'] = nil
      travel_back
    end

    it 'does not enqueue any jobs' do
      perform_enqueued_jobs do
        described_class.perform_later
      end

      expect(
        ActiveJob::Base.queue_adapter.performed_jobs.size
      ).to eq 1
    end
  end

  context "when the current time is earlier than 6 am mexico's time" do
    before do
      ENV['ENABLED_OFFICE_HOURS_SMS_CHECKER_CONTROL'] = 'true'
      current_time = Time.parse('2020-05-25 05:59:47 -0500')
      travel_to current_time
    end

    after do
      ENV['ENABLED_OFFICE_HOURS_SMS_CHECKER_CONTROL'] = nil
      travel_back
    end

    it 'does not enqueue any jobs' do
      perform_enqueued_jobs do
        described_class.perform_later
      end

      expect(
        ActiveJob::Base.queue_adapter.performed_jobs.size
      ).to eq 1
    end
  end
end
