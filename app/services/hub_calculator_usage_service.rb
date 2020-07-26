# frozen_string_literal: true

class HubCalculatorUsageService
  # 30 minutes and 10 seconds
  EXPIRATION_TIME_IN_SECONDS = 1810
  # 24 hours and 10 seconds
  DAILY_EXPIRATION_TIME_IN_SECONDS = 86410
  TOTAL_ALLOWED_PER_DAY = 2000
  TOTAL_ALLOWED_PER_HALF_HOUR = 30
  # 1 minute and 20 seconds
  EVERY_MINUTE_EXPIRATION_TIME_IN_SECONDS = 80
  # That is 25 per minute and 1500 per hour
  TOTAL_REQUESTS_ALLOWED_PER_MINUTE = 25

  attr_accessor :total_usage

  def initialize(hub_uuid)
    @hub_uuid = hub_uuid
  end

  def find_current_minute_counter_key_name
    now = Time.zone.now
    beginning_minute = now.change(sec: 0)
    ending_minute = now.change(sec: 0) + 1.minutes
    "#{beginning_minute.to_i}_#{ending_minute.to_i}_#{@hub_uuid}"
  end

  def find_total_usage_counter_within_minute
    key_name = find_current_minute_counter_key_name
    total_usage = ReadCache.redis.get(key_name).to_i
    total_usage
  end

  def update_and_return_usage_counter_within_minute
    key_name = find_current_minute_counter_key_name
    current_usage = find_total_usage_counter_within_minute
    total_usage = current_usage + 1
    ReadCache.redis.set(
      key_name,
      total_usage,
      calculate_expiration_time_within_minute
    )
    total_usage
  end

  def limit_by_minute_reached?
    limit_allowed = ENV.fetch(
      'TOTAL_REQUESTS_ALLOWED_PER_MINUTE',
      TOTAL_REQUESTS_ALLOWED_PER_MINUTE
    )
    find_total_usage_counter_within_minute > limit_allowed
  end

  def find_daily_counter_key_name
    now = Time.zone.now
    beginning_of_day = now.beginning_of_day
    end_of_day = now.end_of_day
    "#{beginning_of_day.to_i}_#{end_of_day.to_i}_#{@hub_uuid}"
  end

  def find_total_usage_counter_within_today
    key_name = find_daily_counter_key_name
    total_usage = ReadCache.redis.get(key_name).to_i
    total_usage
  end

  def update_and_return_usage_counter_within_today
    key_name = find_daily_counter_key_name
    current_usage = find_total_usage_counter_within_today
    total_usage = current_usage + 1
    ReadCache.redis.set(
      key_name,
      total_usage,
      calculate_expiration_time_within_today
    )
    total_usage
  end

  def daily_limit_reached?
    limit_allowed = ENV.fetch(
      'TOTAL_ALLOWED_PER_DAY',
      TOTAL_ALLOWED_PER_DAY
    )
    find_total_usage_counter_within_today > limit_allowed
  end

  def update_and_return_usage_counter_within_half_hour(selected_date = nil)
    selected_date ||= Time.zone.now
    total_usage = find_total_usage_counter_within_half_hour(
      selected_date
    )
    total_usage += 1
    cache_key_name = find_cache_key_name_for(selected_date)
    ReadCache.redis.set(cache_key_name, total_usage, set_expiration_options)
    total_usage
  end

  # def limit_reached?
  #   limit_allowed = ENV.fetch(
  #     'TOTAL_ALLOWED_PER_HALF_HOUR',
  #     TOTAL_ALLOWED_PER_HALF_HOUR
  #   )
  #   total_usage >= limit_allowed
  # end
  #
  # As we do not want to blow the default setting on some devices which is
  # a maximum of 30 sms per half hour
  # so the period is in the current half hour
  def find_total_usage_counter_within_half_hour(selected_date = nil)
    selected_date ||= Time.zone.now
    cache_key_name = find_cache_key_name_for(selected_date)
    ReadCache.redis.get(cache_key_name).to_i
  end

  def find_cache_key_name_for(selected_date)
    date_calculator = DateCalculatorService.new(selected_date)
    prev_half_hour = date_calculator.get_previous_half_hour
    next_half_hour = date_calculator.get_next_half_hour
    "#{prev_half_hour.to_i}_#{next_half_hour.to_i}_#{@hub_uuid}"
  end

  private

  def calculate_expiration_time_within_minute
    {
      ex: EVERY_MINUTE_EXPIRATION_TIME_IN_SECONDS
    }
  end

  def calculate_expiration_time_within_today
    {
      ex: DAILY_EXPIRATION_TIME_IN_SECONDS
    }
  end

  def set_expiration_options
    {
      ex: EXPIRATION_TIME_IN_SECONDS
    }
  end
end
