# frozen_string_literal: true

module V1
  class SmsNotificationsController < ::V1::AuthorizedController
    before_action :find_mobile_hub, only: :create

    # def index
    #   render_serialized(
    #     @current_api_user.sms_notifications,
    #     SmsNotificationSerializer
    #   )
    # end

    def create
      new_params = sms_notification_params.merge(
        user_id: @current_api_user.id,
        assigned_to_mobile_hub_id: @find_mobile_hub.id
      )
      sms_notification = SmsNotification.create(new_params)

      if sms_notification.valid?
        sms_notification.reload
        sms_notification.start_delivery_process!

        render_serialized(
          sms_notification,
          SmsNotificationSerializer
        )
      else
        render_error_object(sms_notification.errors.messages)
      end
    end

    private

    def find_mobile_hub
      @find_mobile_hub ||= SmsMobileHub.find_by(
        uuid: params[:hub_uuid]
      )

      unless @find_mobile_hub
        activerecord_not_found I18n.t('mobile_hub.controllers.hub_not_found')
      end
    end

    def sms_notification_params
      params.require(
        :sms_notification
      ).permit(
        :sms_content,
        :sms_number,
        :sms_type
      )
    end
  end
end
