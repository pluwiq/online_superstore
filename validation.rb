# frozen_string_literal: true

class Validation
  def self.validate_name(name)
    unless name.match?(/\A[a-zA-Z]+\z/)
      raise ArgumentError, 'Name must only contain letters'
    end
  end

  def self.validate_email(email)
    unless email.length >= 9 && email.match?(/\A[^@\s]+@[^@\s]+\z/)
      raise ArgumentError, 'Email must be at least 9 characters long and follow the format @.com'
    end
  end

  def self.validate_phone(phone)
    unless phone.match?(/\A\d{6,}\z/)
      raise ArgumentError, 'Phone number must only contain digits and be at least 6 digits long'
    end
  end
end
