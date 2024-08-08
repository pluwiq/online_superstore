# frozen_string_literal: true

require_relative 'game'

class ComputerGame < Game
  attr_accessor :platform

  def initialize(id:, name:, description:, price:, age_restriction:, platform:)
    super(id:, name:, description:, price:, age_restriction:)
    @platform = platform
  end

  def self.from_db(row:)
    new(
      id: row['id'].to_i,
      name: row['name'],
      description: row['description'],
      price: row['price'].to_f,
      age_restriction: row['age_restriction'],
      platform: row['platform']
    )
  end
end
