# frozen_string_literal: true

module Android
  class SmsMobileHubsController < ::V1::ApplicationController
    before_action :find_mobile_hub_and_notification, only: :activate
    before_action :find_mobile_hub_by_code, only: :validate

    def validate
      render_json_message(
        {
          message: I18n.t('mobile_hub.controllers.successful_hub_validation')
        }
      )
      job_validation_params = {
        firebase_token: validation_params[:firebase_token],
        device_token_code: validation_params[:device_token_code]
      }
      SmsHubsValidationJob.perform_later job_validation_params
    end

    def activate
      mobile_update = @mobile_hub.mark_as_activated!
      notification_update = @sms_notification.mark_as_delivered!(@mobile_hub.id)

      if mobile_update && notification_update
        render_json_message(
          {
            message: I18n.t('mobile_hub.controllers.successful_hub_activation')
          }
        )
      else
        render_error_object(
          {
            message: I18n.t('mobile_hub.controllers.failure_hub_activation')
          }
        )
      end
    end

    private

    def find_mobile_hub
      @sms_mobile = SmsMobileHub.find_by(uuid: params[:uuid])

      activerecord_not_found unless @sms_mobile
    end

    def find_mobile_hub_by_code
      @sms_mobile_hub = SmsMobileHub.find_by_code(
        validation_params[:device_token_code]
      )

      firebase_token_present = validation_params[:firebase_token].present?
      return if @sms_mobile_hub && firebase_token_present

      activerecord_not_found(
        I18n.t('mobile_hub.controllers.failure_hub_validation')
      )
    end

    def find_mobile_hub_and_notification
      @mobile_hub = SmsMobileHub.find_by_firebase_token(
        activation_params[:firebase_token]
      )

      @sms_notification = SmsNotification.find_by(
        unique_id: activation_params[:sms_notification_uid]
      )

      return if @mobile_hub && @sms_notification

      activerecord_not_found(
        I18n.t('mobile_hub.controllers.hub_activation_not_found')
      )
    end

    def validation_params
      params.permit(:device_token_code, :firebase_token)
    end

    def activation_params
      params.permit(
        :sms_notification_uid,
        :firebase_token
      )
    end
  end
end
