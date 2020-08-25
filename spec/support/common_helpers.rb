# frozen_string_literal: true

module CommonHelpers
  def find_enqueued_job_by(class_name)
    enqueued_jobs = ActiveJob::Base.queue_adapter.enqueued_jobs
    enqueued_jobs.detect do |job|
      job[:job] == class_name
    end
  end

  def find_performed_job_by(class_name)
    enqueued_jobs = ActiveJob::Base.queue_adapter.performed_jobs
    enqueued_jobs.detect do |job|
      job[:job] == class_name
    end
  end

  def inject_user_headers_on_controller(user = nil)
    valid_user = user || create(:user)
    valid_token = JwtTokenService.encode_token(
      { user_id: valid_user.id },
      valid_user.jwt_salt
    )

    headers = {
      'Authorization-Token' => "Bearer #{valid_token}",
      'Authorization-Client' => valid_user.jwt_salt
    }
    request.headers.merge! headers
  end

  def inject_user_headers_on_v2_controller(user = nil)
    valid_user = user || create(:user)
    api_keys = valid_user.third_party_applications.first

    headers = {
      'Authorization-Token' => "Bearer #{api_keys.api_authorization_token}",
      'Authorization-Client' => api_keys.api_authorization_client
    }
    request.headers.merge! headers
  end

  def print_all_queries(&block)
    counter_f = ->(name, started, finished, unique_id, payload) {
      unless payload[:name].in? %w[ CACHE SCHEMA ]
        puts '='*100
        puts payload
        puts '='*100
      end
    }

    ActiveSupport::Notifications.subscribed(counter_f, "sql.active_record", &block)
  end

  def print_queries(&block)
    counter_f = ->(name, started, finished, unique_id, payload) {
      unless payload[:name].in? %w[CACHE SCHEMA]
        puts '='*100
        puts "name: #{payload[:name]} sql: #{payload[:sql]}"
        puts '='*100
      end
    }

    ActiveSupport::Notifications.subscribed(counter_f, "sql.active_record", &block)
  end

  def count_queries_for &block
    count = 0

    counter_f = ->(name, started, finished, unique_id, payload) {
      unless payload[:name].in? %w[CACHE SCHEMA]
        count += 1
      end
    }

    ActiveSupport::Notifications.subscribed(counter_f, "sql.active_record", &block)

    count
  end
end
