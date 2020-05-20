# frozen_string_literal: true

class SmsMobileHub < ApplicationRecord
  # Validations
  validates_presence_of :device_name, :device_number, :user_id

  # Callbacks
  after_create :set_temporal_password

  # Associations
  belongs_to :user

  STATUSES = {
    default: 'pending_activation',
    activated: 'activated',
    activation_in_progress: 'activation_in_progress'
  }.freeze

  def self.find_by_code(pass_code)
    find_by(
      temporal_password: pass_code,
      status: STATUSES[:default]
    )
  end

  def mark_as_activation_in_progress!
    update_column(
      :status, STATUSES[:activation_in_progress]
    )
  end

  def mark_as_activated!
    update_attributes(
      status: STATUSES[:activated],
      activated_at: Time.zone.now
    )
  end

  private

  def set_temporal_password
    return if temporal_password.present?

    update_column(:temporal_password, generate_temporal_password)
  end

  def generate_temporal_password
    loop do
      temp_password = SecureRandom.base64(4)[0...6].gsub(/\W|_/, ('A'..'Z').to_a.sample)
      unless SmsMobileHub.find_by(temporal_password: temp_password)
        break temp_password
      end
    end
  end
end
