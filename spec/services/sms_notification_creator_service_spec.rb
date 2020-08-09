# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SmsNotificationCreatorService do
  let(:user) { create(:user, mobile_number: '3121899980') }

  describe '#perform_creation!' do
    let(:sms_mobile_hub) { create(:sms_mobile_hub, :activated) }
    let(:normal_sms_content) { 'x ' * 80 }
    let(:sms_number) { '+523121231517' }
    let(:long_sms_content) { 'superlongtext' * 300 }
    let(:sms_customer_reference_id) { '748474' }
    let(:expected_keys) do
      %i[
        sms_customer_reference_id
        sms_content
        mobile_hub_id
        api_version
        date_created
        status
				error_message
        sms_number
      ]
    end

    context 'when the sms_content a really long one' do
      it 'responds with valid and creates a new sms notification' do
        params = {
          mobile_hub_id: sms_mobile_hub.reload.uuid,
          sms_number: sms_number,
          user_id: user.id,
          sms_type: 'standard_delivery',
          sms_content: long_sms_content,
          sms_customer_reference_id: sms_customer_reference_id
        }
        service = described_class.new(params)
        result = service.perform_creation!
        expect(service.valid_creation?).to be_truthy
        expect(result[:sms_content].size).to eq 160
        expect(result.keys).to eq expected_keys
      end
    end

    context 'when the sms_number is NOT present' do
      it 'responds with valid and creates a new sms notification' do
        params = {
          mobile_hub_id: sms_mobile_hub.reload.uuid,
          sms_number: '',
          user_id: user.id,
          sms_type: 'standard_delivery',
          sms_content: long_sms_content,
          sms_customer_reference_id: sms_customer_reference_id
        }
        service = described_class.new(params)
        result = service.perform_creation!
        error_msg = "There are some validation errors: sms_number - can't be blank"
        expect(result[:error_message]).to eq error_msg
        expect(service.valid_creation?).to be_falsey
      end
    end

    context 'when the sms_type is not present' do
      it 'responds with valid and creates a new sms notification' do
        params = {
          mobile_hub_id: sms_mobile_hub.reload.uuid,
          sms_number: sms_number,
          user_id: user.id,
          sms_type: '',
          sms_content: long_sms_content,
          sms_customer_reference_id: sms_customer_reference_id
        }
        service = described_class.new(params)
        result = service.perform_creation!
        expect(result[:status]).to eq 'enqueued'
        expect(result[:api_version]).to eq 'V2'
        expect(service.valid_creation?).to be_truthy
        expect(result.keys).to eq expected_keys
      end
    end

    context 'when the user already reached the minute limit' do
      before do
        25.times do
          params = {
            mobile_hub_id: sms_mobile_hub.reload.uuid,
            sms_number: sms_number,
            user_id: user.id,
            sms_type: '',
            sms_content: long_sms_content,
            sms_customer_reference_id: sms_customer_reference_id
          }
          service = described_class.new(params)
          result = service.perform_creation!
          expect(result[:status]).to eq 'enqueued'
        end
      end

      it 'responds with valid and creates a new sms notification' do
        params = {
          mobile_hub_id: sms_mobile_hub.reload.uuid,
          sms_number: sms_number,
          user_id: user.id,
          sms_type: '',
          sms_content: long_sms_content,
          sms_customer_reference_id: sms_customer_reference_id
        }
        service = described_class.new(params)
        result = service.perform_creation!
        expect(result[:status]).to eq 'failed'
        expect(result[:error_message]).to match('The number of requests per minute was reached')
      end
    end
  end
end
