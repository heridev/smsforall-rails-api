# frozen_string_literal: true

module CommonHelpers
  def find_enqueued_job_by(class_name)
    enqueued_jobs = ActiveJob::Base.queue_adapter.enqueued_jobs
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
    valid_token = JwtTokenService.encode_token(
      { user_id: valid_user.id },
      valid_user.main_api_token_salt
    )

    headers = {
      'Authorization-Token' => "Bearer #{valid_token}",
      'Authorization-Client' => valid_user.main_api_token_salt
    }
    request.headers.merge! headers
  end
end
