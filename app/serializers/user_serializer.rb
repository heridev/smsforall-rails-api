class UserSerializer
  include FastJsonapi::ObjectSerializer
  attributes :email,
             :name,
             :country_international_code,
             :mobile_number
end
