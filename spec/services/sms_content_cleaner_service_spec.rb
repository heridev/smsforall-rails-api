# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SmsContentCleanerService do
  describe '#clean_content!' do
    let(:text_content) do
      'Hola ' * 300
    end
    let(:text_content_with_accents) do
      'Que tenga un gran día :)'
    end

    it 'responds with the right content limit' do
      service = described_class.new(text_content)
      result = service.clean_content!
      expect(result.size).to eq 500
      expect(text_content.size).to eq 1500
    end

    it 'removes any accents in the content' do
      service = described_class.new(text_content_with_accents)
      result = service.clean_content!
      expect(result).to eq 'Que tenga un gran dia :)'
    end
  end
end
