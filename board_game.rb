# frozen_string_literal: true

require_relative 'game'

class BoardGame < Game
  attr_accessor :number_of_players

  def initialize(id:, name:, description:, price:, age_restriction:, number_of_players:)
    super(id:, name:, description:, price:, age_restriction:)
    @number_of_players = number_of_players
  end

  def self.from_db(row:)
    new(
      id: row['id'].to_i,
      name: row['name'],
      description: row['description'],
      price: row['price'].to_f,
      age_restriction: row['age_restriction'],
      number_of_players: row['number_of_players'].to_i
    )
  end
end
