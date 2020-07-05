class DateCalculatorService
  def initialize(selected_date = Time.zone.now)
    @selected_date = selected_date
  end

  def get_next_half_hour
    minutes_value = @selected_date.strftime('%M').to_i
    rounded_number = ValueConverterService.new(
      minutes_value
    ).round_up_to_thirty
    difference = rounded_number - minutes_value
    (@selected_date + difference.minutes).change(sec: 0)
  end

  def get_previous_half_hour
    get_next_half_hour - 30.minutes
  end
end
