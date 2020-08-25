# frozen_string_literal: true

class UtilityService
  class << self
    def generate_friendly_code(number_of_characters = 6)
      SecureRandom.base64(4)[
        0...number_of_characters
      ].gsub(/\W|_/, ('A'..'Z').to_a.sample)
    end
  end
end
