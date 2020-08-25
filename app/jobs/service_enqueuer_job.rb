# frozen_string_literal: true

class ServiceEnqueuerJob < ApplicationJob
  queue_as :urgent_delivery

  # Usage eg:
  #  ServiceEnqueuerJob.perform_later(
  #    'SmsAccountActivatorService',
  #    'send_notification',
  #    argument_params
  #  )
  #
  #  ServiceEnqueuerJob.perform_later(
  #    'MyServiceClass',
  #    'new',
  #     initialize_params
  #  )
  def perform(service_class_name, method_name, params = {})
    service = service_class_name.constantize
    if params.present?
      service.send(method_name, params)
    else
      service.send(method_name)
    end
  end
end
