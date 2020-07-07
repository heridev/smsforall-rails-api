# frozen_string_literal: true

class SmsNotification < ApplicationRecord
  STATUSES = {
    default: 'queued',
    delivered: 'delivered',
    received: 'received',
    failed_sent_to_firebase: 'failed_sent_to_firebase',
    sent_to_firebase: 'sent_to_firebase'
  }.freeze

  SMS_TYPES = {
    default: 'standard_delivery',
    urgent_delivery: 'urgent_delivery',
    device_validation: 'device_validation'
  }.freeze

  KIND_OF_NOTIFICATION = {
    in: 'in',
    out: 'out'
  }.freeze

  validates_presence_of :sms_content,
                        :sms_number,
                        :status,
                        :sms_type,
                        :assigned_to_mobile_hub_id

  validates_inclusion_of :sms_type, in: SMS_TYPES.values
  validates_inclusion_of :kind_of_notification, in: KIND_OF_NOTIFICATION.values

  belongs_to :processed_by_mobile_hub,
             class_name: 'SmsMobileHub',
             foreign_key: :processed_by_sms_mobile_hub_id,
             optional: true

  belongs_to :assigned_to_mobile_hub,
             class_name: 'SmsMobileHub',
             foreign_key: :assigned_to_mobile_hub_id,
             optional: true

  belongs_to :user

  def mark_sent_to_firebase_as_success!(sms_mobile_hub_id)
    update_attributes(
      sent_to_firebase_at: Time.zone.now,
      assigned_to_mobile_hub_id: sms_mobile_hub_id,
      status: STATUSES[:sent_to_firebase]
    )
  end

  def mark_sent_to_firebase_as_failure!(sms_mobile_hub_id)
    update_attributes(
      status: STATUSES[:failed_sent_to_firebase],
      assigned_to_mobile_hub_id: sms_mobile_hub_id,
      failed_sent_to_firebase_at: Time.zone.now
    )
  end

  def decorated_status
    I18n.t(status.to_sym, scope: 'sms_notification.statuses')
  end

  def decorated_delivered_at
    delivered_at.present? ? delivered_at : 'N/A'
  end

  def mark_as_delivered!(sms_mobile_hub_id)
    update_attributes(
      status: STATUSES[:delivered],
      processed_by_sms_mobile_hub_id: sms_mobile_hub_id,
      delivered_at: Time.zone.now
    )
  end

  def start_delivery_process!
    if sms_type == SMS_TYPES[:urgent_delivery]
      return UrgentSmsNotificationSenderJob.perform_later(
        id,
        assigned_to_mobile_hub_id
      )
    end

    SmsNotificationSenderJob.perform_later(
      id,
      assigned_to_mobile_hub_id
    )
  end
end
