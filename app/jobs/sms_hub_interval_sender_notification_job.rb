# frozen_string_literal: true

class SmsHubIntervalSenderNotificationJob < ApplicationJob
  queue_as :standard_delivery

  def perform
    SmsMobileHub.active.pluck(:id).each do |hub_id|
      SmsHubNotificationSenderJob.perform_later(
        hub_id
      )
    end
  end
end

