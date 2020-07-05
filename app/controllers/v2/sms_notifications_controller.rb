# frozen_string_literal: true

module V2
  class SmsNotificationsController < ::V2::AuthorizedController

    def create
      creation_params = sms_notification_params.merge(
        user_id: @current_api_user.id
      )
      sms_creator = SmsNotificationCreatorService.new(creation_params)

      result = sms_creator.perform_creation!

      if sms_creator.valid_creation?
        render_json_dump(result)
      else
        render_json_dump(result, :unprocessable_entity)
      end
    end

    private

    def sms_notification_params
      params.permit(
        :mobile_hub_id,
        :sms_customer_reference_id,
        :mobile_hub_id,
        :sms_number,
        :sms_content,
        :sms_type
      )
    end
  end
end
