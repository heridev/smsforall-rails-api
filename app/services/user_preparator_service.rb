class UserPreparatorService
  attr_reader :user

  def initialize(user_id)
    @user = User.find_by(id: user_id)
    execute_callbacks!
  end

  def execute_callbacks!
    return unless user

    update_registration_pin_code!
    print_user_pin_code_for_development
    send_activation_account!
    create_api_keys!
  end

  def update_registration_pin_code!
    user.update(registration_pin_code: generate_pin_code)
  end

  def generate_pin_code
    loop do
      pin_code = UtilityService.generate_friendly_code
      unless User.find_by(registration_pin_code: pin_code)
        break pin_code
      end
    end
  end

  def send_activation_account!
    argument_params = {
      user_id: user.id,
      user_name: user.first_ten_chars_from_name,
      user_pin_code: user.registration_pin_code,
      user_phone_number: user.find_international_number
    }

    SmsAccountActivatorService.send_notification(argument_params)
  end

  def create_api_keys!
    api_keys_name = 'My API keys #1'
    user.create_api_keys(api_keys_name)
  end

  private

  def print_user_pin_code_for_development
    return unless Rails.env.development?

    Rails.logger.info '=' * 100
    Rails.logger.info "Pin code to use in the Android App is #{user.reload.registration_pin_code}"
    Rails.logger.info '=' * 100
  end
end
