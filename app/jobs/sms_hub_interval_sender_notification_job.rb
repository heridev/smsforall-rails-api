# frozen_string_literal: true

class SmsHubIntervalSenderNotificationJob < ApplicationJob
  queue_as :standard_delivery

  # We only send sms messages if the current time is between
  # 06:00 am  - 11:00 pm Mexico's time
  def perform
    mexico_time_zone = 'America/Mexico_City'
    now = Time.zone.now
    current_mexico_time = now.in_time_zone('America/Mexico_City')

    morning_time = now.in_time_zone(
      mexico_time_zone
    ).change(hour: '06')

    night_time = now.in_time_zone(
      mexico_time_zone
    ).change(hour: '23')

    invalid_time = current_mexico_time > night_time ||
                   current_mexico_time < morning_time

    disabled_control = ENV.fetch(
      'ENABLED_OFFICE_HOURS_SMS_CHECKER_CONTROL',
      false
    )

    return if invalid_time && disabled_control

    SmsMobileHub.active.pluck(:id).each do |hub_id|
      SmsHubNotificationSenderJob.perform_later(
        hub_id
      )
    end
  end
end
