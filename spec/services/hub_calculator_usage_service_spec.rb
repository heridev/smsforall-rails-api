require 'rails_helper'

RSpec.describe HubCalculatorUsageService do
  # let(:redis) { Redis.new }
  describe '.update_and_return_usage_counter_within_half_hour' do
    let(:user) { create(:user) }
    let(:sms_mobile_hub) { create(:sms_mobile_hub, :activated, user: user) }

    context 'when the redis is updated only once' do
      it 'returns zero in the first call' do
        time = Time.local(2020, 7, 1, 23, 59, 15)
        service = described_class.new(sms_mobile_hub)
        counter = service.update_and_return_usage_counter_within_half_hour(
          time
        )
        expect(counter).to eq 1
        # expected_key =
        # expect(redis.get(
      end
    end

    context 'when the redis is updated multiple times' do
      let(:selected_dates) do
        [
          Time.local(2020, 7, 1, 23, 39, 32),
          Time.local(2020, 7, 1, 23, 40, 0),
          Time.local(2020, 7, 1, 23, 44, 10),
          Time.local(2020, 7, 1, 23, 50, 5),
          Time.local(2020, 7, 1, 23, 55, 1),
          Time.local(2020, 7, 1, 23, 59, 2)
        ]
      end

      before do
        selected_dates.each do |selected_date|
          service = described_class.new(sms_mobile_hub.uuid)
          service.update_and_return_usage_counter_within_half_hour(
            selected_date
          )
        end
      end

      it 'returns six messages sent' do
        time = Time.local(2020, 7, 1, 23, 59, 15)
        service = described_class.new(sms_mobile_hub.uuid)
        counter = service.find_total_usage_counter_within_half_hour(
          time
        )
        expect(counter).to eq 6
      end
    end
  end
end
