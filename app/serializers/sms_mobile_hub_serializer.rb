class SmsMobileHubSerializer
  include FastJsonapi::ObjectSerializer
  attributes :device_name,
             :device_number,
             :temporal_password
end

