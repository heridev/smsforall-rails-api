class SmsHubsValidationJob < ApplicationJob
  queue_as :default

  def perform(args = {})
    MobileHubValidatorService.new(args).validate_hub!
  end
end
