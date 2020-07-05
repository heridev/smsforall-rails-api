# frozen_string_literal: true

class SmsNotificationsQuery < BaseQuery
  attr_reader :relation

  def self.relation(base_relation = nil)
    super(base_relation, SmsNotification)
  end

  def filter_by_params(params, user_id)
    query_select = <<-SQL
      sms_notifications.sms_content,
      sms_notifications.sms_number,
      sms_notifications.unique_id,
      sms_notifications.sms_type,
      sms_notifications.kind_of_notification,
      sms_notifications.processed_by_sms_mobile_hub_id,
      sms_notifications.assigned_to_mobile_hub_id,
      sms_notifications.status
    SQL

    base_query = SmsNotification.select(query_select)
                                .where(user_id: user_id)

    kind_of_notification = params[:kind_of_notification]
    if kind_of_notification.blank?
      kind_of_notification = SmsNotification::KIND_OF_NOTIFICATION.values
    end

    base_query = base_query.where(
      kind_of_notification: kind_of_notification
    )

    text_searched = params[:text_searched]
    if text_searched.present?
      base_query = base_query.where('sms_number ilike ?', "%#{text_searched}%")
    end

    base_query
  end
end
