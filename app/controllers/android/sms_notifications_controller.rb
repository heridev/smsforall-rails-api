# frozen_string_literal: true

module Android
  class SmsNotificationsController < ::V1::ApplicationController
    before_action :find_sms_notification, only: :update_status
    before_action :find_mobile_hub_by_firebase_token, only: :update_status

    def update_status
      cleaned_params = {
        status: params[:status],
        additional_update_info: params[:additional_update_info],
        processed_by_sms_mobile_hub_id: find_mobile_hub_by_firebase_token&.id
      }
      if @find_sms_notification.update_status(cleaned_params)
        render_json_message(
          {
            message: I18n.t('sms_notification.controllers.succcess_update')
          }
        )
      else
        render_error_object(@find_sms_notification.errors.messages)
      end
    end

    def find_sms_notification
      @find_sms_notification ||= SmsNotification.find_by(
        unique_id: params[:sms_notification_uid]
      )

      return if @find_sms_notification

      activerecord_not_found(
        I18n.t('sms_notification.controllers.sms_notification_update_status_not_found')
      )
    end

    def find_mobile_hub_by_firebase_token
      @find_mobile_hub_by_firebase_token ||= SmsMobileHub.find_by_firebase_token(
        params[:mobile_hub_token]
      )
    end
  end
end
