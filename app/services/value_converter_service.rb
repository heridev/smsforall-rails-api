class ValueConverterService
  def initialize(number)
    @number = number
  end
  BASE_MULTIPLE_OF_FIVE = 5
  BASE_MULTIPLE_OF_THIRTY = 30

  def self.round_up_to_five
    round_up_to_n(BASE_MULTIPLE_OF_FIVE)
  end

  def round_up_to_thirty
    round_up_to_n(BASE_MULTIPLE_OF_THIRTY)
  end

  def round_up_to_n(base_multiple_of)
    base_multiple_of * (
      (@number + base_multiple_of - 1) / base_multiple_of
    )
  end

  def take_only_160_characters_from
    if @number.present?
      @number[0..159]
    else
      ''
    end
  end

  def take_only_n_characters_from(number_characters)
    number_characters =-1
    if @number.present?
      @number[0..number_characters]
    else
      ''
    end
  end
end
