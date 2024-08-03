# frozen_string_literal: true

module CustomerInput
  def prompt_for_name
    loop do
      puts "Enter your name (only letters):"
      name = gets.chomp
      return name if validate_input { Validation.validate_name(name) }
    end
  end

  def prompt_for_email
    loop do
      puts "Enter your email (at least 9 characters, format @.com):"
      email = gets.chomp
      return email if validate_input { Validation.validate_email(email) }
    end
  end

  def prompt_for_phone
    loop do
      puts "Enter your phone number (only digits, at least 6 digits):"
      phone = gets.chomp
      return phone if validate_input { Validation.validate_phone(phone) }
    end
  end

  def prompt_for_address
    puts 'Enter your address:'
    gets.chomp
  end

  private

  def validate_input
    yield
    true
  rescue ArgumentError => e
    puts e.message
    false
  end
end
