class SmsHubsValidationJob < ApplicationJob
  queue_as :urgent_delivery

  def perform(args = {})
    MobileHubValidatorService.new(args).validate_hub!
  end
end
