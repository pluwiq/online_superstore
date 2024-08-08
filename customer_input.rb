# frozen_string_literal: true

module CustomerInput
  def prompt_for(field:)
    loop do
      puts INPUT_PROMPTS[field][:message]
      input = gets.chomp
      return input if validate_input { INPUT_PROMPTS[field][:validation].call(input) }
    end
  end

  private

  INPUT_PROMPTS = {
    name: {
      message: 'Enter your name (only letters):',
      validation: ->(input) { Validation.validate_name(input) }
    },
    email: {
      message: 'Enter your email (at least 9 characters, format @.com):',
      validation: ->(input) { Validation.validate_email(input) }
    },
    phone: {
      message: 'Enter your phone number (only digits, at least 6 digits):',
      validation: ->(input) { Validation.validate_phone(input) }
    },
    address: {
      message: 'Enter your address:',
      validation: ->(_) { true }
    }
  }.freeze

  def validate_input
    yield
    true
  rescue ArgumentError => e
    puts e.message
    false
  end
end
