# frozen_string_literal: true

class SmsNotification < ApplicationRecord
  MAXIMUM_NUMBER_OF_INTENTS_TO_DELIVER = 3

  STATUSES = {
    default: 'queued',
    pending: 'pending',
    delivered: 'delivered',
    received: 'received',
    failed_sent_to_firebase: 'failed_sent_to_firebase',
    sent_to_firebase: 'sent_to_firebase',
    failed: 'failed',
    undelivered: 'undelivered'
  }.freeze

  SMS_TYPES = {
    default: 'standard_delivery',
    urgent_delivery: 'urgent_delivery',
    device_validation: 'device_validation',
    schedule_checker: 'schedule_checker'
  }.freeze

  KIND_OF_NOTIFICATION = {
    in: 'in',
    out: 'out'
  }.freeze

  validates_presence_of :sms_content,
                        :sms_number,
                        :user_id,
                        :status,
                        :sms_type,
                        :assigned_to_mobile_hub_id

  validates_inclusion_of :sms_type, in: SMS_TYPES.values
  validates_inclusion_of :kind_of_notification, in: KIND_OF_NOTIFICATION.values

  belongs_to :processed_by_sms_mobile_hub,
             class_name: 'SmsMobileHub',
             foreign_key: :processed_by_sms_mobile_hub_id,
             optional: true

  belongs_to :assigned_to_mobile_hub,
             class_name: 'SmsMobileHub',
             foreign_key: :assigned_to_mobile_hub_id,
             optional: true

  belongs_to :user,
             optional: true

  def self.create_received_notification(controller_params)
    hub_id = controller_params[:hub_id]
    sms_content = controller_params[:sms_content]
    sms_number = controller_params[:sms_number]
    user_id = controller_params[:user_id]
    cleaned_params = {
      user_id: user_id,
      assigned_to_mobile_hub_id: hub_id,
      processed_by_sms_mobile_hub_id: hub_id,
      delivered_at: Time.zone.now,
      sms_number: sms_number,
      sms_content: sms_content,
      kind_of_notification: KIND_OF_NOTIFICATION[:in],
      sms_type: SMS_TYPES[:default],
      status: STATUSES[:received]
    }
    create(cleaned_params)
  end

  def self.create_record(controller_params)
    user_id = controller_params[:user_id]
    hub_id = controller_params[:hub_id]
    sms_content = controller_params[:sms_content]
    sms_type = controller_params[:sms_type] || SMS_TYPES[:default]
    sms_number = controller_params[:sms_number]

    valid_sms_content = SmsContentCleanerService.new(
      sms_content
    ).clean_content!

    cleaned_params = {
      user_id: user_id,
      assigned_to_mobile_hub_id: hub_id,
      sms_number: sms_number,
      sms_content: valid_sms_content,
      kind_of_notification: KIND_OF_NOTIFICATION[:out],
      sms_type: sms_type,
      status: STATUSES[:default]
    }
    create(cleaned_params)
  end

  def mark_sent_to_firebase_as_success!(sms_mobile_hub_id)
    update(
      sent_to_firebase_at: Time.zone.now,
      assigned_to_mobile_hub_id: sms_mobile_hub_id,
      status: STATUSES[:sent_to_firebase]
    )
  end

  def increase_number_of_intents_to_be_delivered!
    update(
      number_of_intents_to_be_delivered: number_of_intents_to_be_delivered + 1,
    )
  end

  def update_status(params = {})
    now = Time.zone.now

    if params[:status] == STATUSES[:delivered]
      params[:delivered_at] = now
    else
      params[:failed_delivery_at] = now
      enqueue_to_be_processed_again!
    end

    params[:status_updated_by_hub_at] = now
    update(
      params
    )
  end

  def enqueue_to_be_processed_again!
    if number_of_intents_to_be_delivered >= MAXIMUM_NUMBER_OF_INTENTS_TO_DELIVER
      return
    end

    start_delivery_process!
  end

  def mark_sent_to_firebase_as_failure!(sms_mobile_hub_id)
    update(
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
    update(
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
