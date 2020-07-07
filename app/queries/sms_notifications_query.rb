# frozen_string_literal: true

class SmsNotificationsQuery < BaseQuery
  attr_reader :relation

  def self.relation(base_relation = nil)
    super(base_relation, SmsNotification)
  end

  def filter_by_params(params, user_id)
    puts "params #{params.inspect}"
    base_query = SmsNotification.order(created_at: :asc).where(user_id: user_id)

    kind_of_notification = params[:kind_of_notification]
    if kind_of_notification.blank?
      kind_of_notification = SmsNotification::KIND_OF_NOTIFICATION.values
    end

    base_query = base_query.where(
      kind_of_notification: kind_of_notification
    )

    text_searched = params[:text_searched]
    if text_searched.present?
      base_query = base_query.where(
        'sms_number ilike ? OR sms_content ilike ?',
        "%#{text_searched}%", "%#{text_searched}%"
      )
    end

    base_query
  end
end
