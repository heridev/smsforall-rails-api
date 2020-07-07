# frozen_string_literal: true

module V1
  class SmsMobileHubSerializer
    include FastJsonapi::ObjectSerializer
    attributes :device_name,
               :device_number,
               :temporal_password,
               :uuid,
               :country_international_code,
               :friendly_status_name,
               :status
  end
end
