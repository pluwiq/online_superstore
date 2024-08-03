# frozen_string_literal: true

module Validation
  def self.validate_name(name)
    raise ArgumentError, 'Name must only contain letters' unless
      name.match?(/\A[a-zA-Z]+\z/)
  end

  def self.validate_email(email)
    raise ArgumentError, 'Email must be at least 9 characters long and follow the format @.com' unless
      email.length >= 9 && email.match?(/\A[^@\s]+@[^@\s]+\z/)
  end

  def self.validate_phone(phone)
    raise ArgumentError, 'Phone number must only contain digits and be at least 6 digits long' unless
      phone.match?(/\A\d{6,}\z/)
  end
end