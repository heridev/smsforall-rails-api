# frozen_string_literal: true

module V1
  class SmsMobileHubsController < ::V1::AuthorizedController
    skip_before_action :authenticate_request,
                       only: %i[validate activate]
    before_action :find_mobile_hub_and_notification, only: :activate

    def create
      new_params = sms_mobile_hub_params.merge(
        user_id: @current_api_user.id
      )
      sms_mobile = SmsMobileHub.create(new_params)

      if sms_mobile.valid?
        render_serialized(
          sms_mobile,
          SmsMobileHubSerializer
        )
      else
        render_error_object(sms_mobile.errors.messages)
      end
    end

    def validate
      mobile_hub = SmsMobileHub.find_by_code(
        validation_params[:device_token_code]
      )
      firebase_token_present = validation_params[:firebase_token].present?

      if mobile_hub && firebase_token_present
        render_json_message(
          {
            message: I18n.t('mobile_hub.controllers.successful_hub_validation')
          }
        )
        SmsHubsValidationJob.perform_later validation_params.to_h
      else
        activerecord_not_found(
          I18n.t('mobile_hub.controllers.failure_hub_validation')
        )
      end
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

    def find_mobile_hub_and_notification
      @mobile_hub = SmsMobileHub.find_by(
        firebase_token: activation_params[:firebase_token]
      )

      @sms_notification = SmsNotification.find_by(
        unique_id: activation_params[:sms_notification_uid]
      )

      if !@mobile_hub || !@sms_notification
        activerecord_not_found(
          I18n.t('mobile_hub.controllers.failure_hub_validation')
        )
      end
    end

    def activation_params
      params.permit(
        :sms_notification_uid,
        :firebase_token
      )
    end


    def validation_params
      params.require(
        :sms_mobile_hub
      ).permit(
        :device_token_code,
        :firebase_token
      )
    end

    def sms_mobile_hub_params
      params.require(
        :sms_mobile_hub
      ).permit(
        :device_name,
        :device_number
      )
    end
  end
end
