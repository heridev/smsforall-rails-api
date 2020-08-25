# frozen_string_literal: true

module V1
  class UserSerializer
    include FastJsonapi::ObjectSerializer
    attributes :email,
               :name,
               :country_international_code,
               :mobile_number,
               :status,
               :pending_confirmation?,
               :find_international_number
  end
end
