# frozen_string_literal: true

class SmsNotification < ApplicationRecord
  STATUSES = {
    default: 'pending',
    device_validation: 'device_validation',
    delivered: 'delivered',
    failed_sent_to_firebase: 'failed_sent_to_firebase',
    sent_to_firebase: 'sent_to_firebase'
  }.freeze

  validates_presence_of :sms_content,
                        :sms_number,
                        :status,
                        :sms_type

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

  def mark_as_delivered!(sms_mobile_hub_id)
    update_attributes(
      status: STATUSES[:delivered],
      processed_by_sms_mobile_hub_id: sms_mobile_hub_id,
      delivered_at: Time.zone.now
    )
  end

  def start_delivery_process!
    if sms_type == 'urgent_delivery'
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
