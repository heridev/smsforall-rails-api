# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DateCalculatorService do
  describe '.get_next_half_hour' do
    it 'returns the next day when the day is ending' do
      time = Time.local(2020, 7, 1, 23, 59, 15)
      result = described_class.new(time).get_next_half_hour
      expect(result).to eq '2020-07-02 00:00:00 -0500'.to_datetime
    end

    it 'returns the next half hour in the same hour' do
      time = Time.local(2020, 7, 1, 12, 16, 59)
      result = described_class.new(time).get_next_half_hour
      expect(result).to eq '2020-07-01 12:30:00 -0500'.to_datetime
    end

    it 'returns the next half hour at noon' do
      time = Time.local(2020, 7, 1, 12, 14, 59)
      result = described_class.new(time).get_next_half_hour
      expect(result).to eq '2020-07-01 12:30:00 -0500'.to_datetime
    end
  end

  describe '.get_previous_half_hour' do
    it 'returns the previous half hour to the next day' do
      time = Time.local(2020, 7, 1, 23, 59, 15)
      result = described_class.new(time).get_previous_half_hour
      expect(result).to eq '2020-07-01 23:30:00 -0500'.to_datetime
    end

    it 'returns the previous half hour at noon' do
      time = Time.local(2020, 7, 1, 12, 14, 59)
      result = described_class.new(time).get_previous_half_hour
      expect(result).to eq '2020-07-01 12:00:00 -0500'.to_datetime
    end
  end
end
