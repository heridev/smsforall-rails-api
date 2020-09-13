# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SmsContentCleanerService do
  describe '#clean_content!' do
    let(:text_content) do
      'Hola ' * 300
    end

    it 'responds with the right content limit' do
      service = described_class.new(text_content)
      result = service.clean_content!
      expect(result.size).to eq 1000
      expect(text_content.size).to eq 1500
    end
  end
end
