# frozen_string_literal: true

require_relative 'item'

class Game < Item
  attr_accessor :age_restriction

  def initialize(id:, name:, description:, price:, age_restriction:)
    super(id:, name:, description:, price:)
    @age_restriction = age_restriction
  end

  def self.from_db(row:)
    new(
      id: row['id'].to_i,
      name: row['name'],
      description: row['description'],
      price: row['price'].to_f,
      age_restriction: row['age_restriction']
    )
  end
end
