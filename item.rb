# frozen_string_literal: true

class Item
  attr_accessor :id, :name, :description, :price

  def initialize(id:, name:, description:, price:)
    @id = id
    @name = name
    @description = description
    @price = price
  end

  def self.from_db(row:)
    new(
      id: row['id'].to_i,
      name: row['name'],
      description: row['description'],
      price: row['price'].to_f
    )
  end
end
