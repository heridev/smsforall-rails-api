# frozen_string_literal: true

module V1
  class SmsNotificationsController < ::V1::AuthorizedController
    PER_PAGE_RECORDS = 100
    before_action :find_mobile_hub, only: :create

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
        kind_of_notification: SmsNotification::KIND_OF_NOTIFICATION[:out],
        assigned_to_mobile_hub_id: @find_mobile_hub.id
      )
      sms_notification = SmsNotification.create(new_params)

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

    private

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
