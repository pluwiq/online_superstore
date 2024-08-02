# frozen_string_literal: true

require_relative 'item'

class Book < Item
  attr_accessor :author, :publisher, :isbn

  def initialize(id:, name:, description:, price:, author: nil, publisher: nil, isbn: nil)
    super(id:, name:, description:, price:)
    @author = author
    @publisher = publisher
    @isbn = isbn
  end

  def self.from_db(row:)
    new(
      id: row['id'].to_i,
      name: row['name'],
      description: row['description'],
      price: row['price'].to_f,
      author: row['author'],
      publisher: row['publisher'],
      isbn: row['isbn']
    )
  end
end
