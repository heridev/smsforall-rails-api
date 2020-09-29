class SmsContentCleanerService
  attr_reader :text

  def initialize(text)
    @text = text
  end

  def clean_content!
    content = take_text_based_on_sms_content_limit
    remove_accents_from(content)
  end

  private

  def remove_accents_from(message)
    I18n.transliterate(message)
  end

  SMS_CONTENT_LIMIT = 500

  def sms_content_limit
    ENV.fetch(
      'SMS_CONTENT_LIMIT',
      SMS_CONTENT_LIMIT
    ).to_i
  end

  def find_sms_content_limit
    sms_content_limit - 1
  end

  def take_text_based_on_sms_content_limit
    if text.present?
      text[0..find_sms_content_limit]
    else
      ''
    end
  end
end
