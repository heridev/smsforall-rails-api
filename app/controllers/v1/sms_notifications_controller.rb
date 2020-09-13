# frozen_string_literal: true

module V1
  class SmsNotificationsController < ::V1::AuthorizedController
    PER_PAGE_RECORDS = 100
    skip_before_action :authenticate_request, only: :update_status
    before_action :find_mobile_hub, only: :create
    before_action :find_sms_notification, only: :update_status
    before_action :find_mobile_hub_by_firebase_token, only: :update_status

    def index
      query_object = SmsNotificationsQuery.relation
      responses = query_object.filter_by_params(params, @current_api_user.id)
                              .page(page_number)
                              .per(PER_PAGE_RECORDS)
                              .order('created_at DESC')

      serialized_data = serialize_hash(
        responses,
        ::V1::SmsNotificationSerializer
      )

      data_response = {
        data: {
          sms_notifications: serialized_data[:data],
          page_number: page_number,
          tot_notifications: responses.total_count,
          tot_pages: responses.total_pages
        }
      }

      render_json_dump(data_response)
    end

    def create
      new_params = sms_notification_params.merge(
        user_id: @current_api_user.id,
        hub_id: @find_mobile_hub.id
      )
      sms_notification = SmsNotification.create_record(new_params)

      if sms_notification.valid?
        sms_notification.reload
        sms_notification.start_delivery_process!

        render_serialized(
          sms_notification,
          ::V1::SmsNotificationSerializer
        )
      else
        render_error_object(sms_notification.errors.messages)
      end
    end

    def update_status
      cleaned_params = {
        status: params[:status],
        additional_update_info: params[:additional_update_info],
        processed_by_sms_mobile_hub_id: find_mobile_hub_by_firebase_token&.id
      }
      if @find_sms_notification.update_status(cleaned_params)
        render_serialized(
          @find_sms_notification,
          ::V1::SmsNotificationSerializer
        )
      else
        render_error_object(@find_sms_notification.errors.messages)
      end
    end

    private

    # TODO: once we migrate the app in Android we
    # can deprecate the firebase_token param
    def find_mobile_hub_by_firebase_token
      token_hub = if params[:firebase_token].present?
                    params[:firebase_token]
                  else
                    params[:mobile_hub_token]
                  end
      @find_mobile_hub_by_firebase_token ||= SmsMobileHub.find_by_firebase_token(
        token_hub
      )
    end

    def find_sms_notification
      @find_sms_notification ||= SmsNotification.find_by(
        unique_id: params[:sms_notification_uid]
      )

      return if @find_sms_notification

      activerecord_not_found I18n.t('sms_notification.controllers.sms_notification_update_status_not_found')
    end

    def page_number
      params[:page_number].try(:to_i) || 1
    end

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
