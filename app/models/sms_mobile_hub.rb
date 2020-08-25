# frozen_string_literal: true

class SmsMobileHub < ApplicationRecord
  # Validations
  validates_presence_of :device_name, :device_number, :user_id
  validates :device_number, uniqueness: true

  # Callbacks
  after_create :generate_password_and_token_hub

  # Associations
  belongs_to :user

  STATUSES = {
    default: 'pending_activation',
    activated: 'activated',
    activation_in_progress: 'activation_in_progress',
    banned: 'banned'
  }.freeze

  scope :active, lambda {
    where(status: STATUSES[:activated])
  }

  scope :master_hubs, lambda {
    where(is_master: true)
  }

  def self.find_by_code(pass_code)
    find_by(
      temporal_password: pass_code,
      status: [STATUSES[:default], STATUSES[:activation_in_progress]]
    )
  end

  def self.find_first_master_mobile_hub
    master_hubs.first
  end

  def short_device_name
    device_name[0..20]
  end

  def banned?
    status == STATUSES[:banned]
  end

  # TODO: once we migrate the app in Android we
  # can deprecate the serarch by firebase token
  # and rename this method
  # once we migrate from firebase into
  # pusher.com
  def self.find_by_firebase_token(token)
    where(
      'firebase_token = ? OR mobile_hub_token = ?',
      token,
      token
    ).first
  end

  def mark_as_activation_in_progress!
    update_column(
      :status, STATUSES[:activation_in_progress]
    )
  end

  def friendly_status_name
    status_title = "mobile_hub.statuses.#{status}"
    I18n.t(status_title)
  end

  def mark_as_activated!
    update(
      status: STATUSES[:activated],
      activated_at: Time.zone.now
    )
  end

  def find_international_number
    "+#{country_international_code}#{device_number}"
  end

  private

  def generate_password_and_token_hub
    set_temporal_password
    generate_and_set_mobile_hub_token
  end

  def generate_and_set_mobile_hub_token
    mobile_hub_token = JwtTokenService.encode_token(
      id,
      nil,
      nil
    )
    update_column(
      :mobile_hub_token,
      mobile_hub_token
    )
  end

  def set_temporal_password
    return if temporal_password.present?

    update_column(:temporal_password, generate_temporal_password)
  end

  def generate_temporal_password
    loop do
      temp_password = UtilityService.generate_friendly_code
      unless SmsMobileHub.find_by(temporal_password: temp_password)
        break temp_password
      end
    end
  end
end
