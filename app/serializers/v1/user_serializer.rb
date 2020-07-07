# frozen_string_literal: true

module V1
  class UserSerializer
    include FastJsonapi::ObjectSerializer
    attributes :email,
               :name,
               :country_international_code,
               :mobile_number
  end
end
