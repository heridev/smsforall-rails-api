# frozen_string_literal: true

module CommonHelpers
  def find_enqueued_job_by(class_name)
    enqueued_jobs = ActiveJob::Base.queue_adapter.enqueued_jobs
    enqueued_jobs.detect do |job|
      job[:job] == class_name
    end
  end
end
