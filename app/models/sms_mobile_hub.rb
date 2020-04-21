class SmsMobileHub < ApplicationRecord
  validates_presence_of :device_name, :device_number
  after_create :set_temporal_password

  private

  def set_temporal_password
    unless temporal_password
      update_column(:temporal_password, generate_temporal_password)
    end
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
