# frozen_string_literal: true

module V1
  class PublicSmsNotificationsController < ::V1::ApplicationController
    def create
      if valid_sms_data?
        ServiceEnqueuerJob.perform_later(
          'PublicSmsNotificationSenderService',
          'send_notification',
          sms_notification_params
        )
        sms_message = I18n.t(
          'sms_notification.controllers.sms_public_message_success_enqueued'
        )

        json_content = { message: sms_message, requested_time: Time.zone.now.to_i }
        render_json_message(json_content)
      else
        failing_sms_message = I18n.t(
          'sms_notification.controllers.sms_public_message_invalid_enqueued'
        )
        render_with_error failing_sms_message
      end
    end

    private

    def valid_sms_data?
      sms_notification_params[:sms_content].present? &&
        sms_notification_params[:sms_number].present?
    end

    def sms_notification_params
      params.require(
        :sms_notification
      ).permit(
        :sms_content,
        :sms_number
      )
    end
  end
end
