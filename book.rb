# frozen_string_literal: true

require_relative 'db_connection'
require_relative 'item'

class Book < Item
  attr_accessor :author, :publisher, :isbn

  def initialize(id:, name:, description:, price:, author: nil, publisher: nil, isbn: nil)
    super(id:, name:, description:, price:)
    @isbn = validate_isbn_uniqueness(isbn:)
    @publisher = publisher
    @author = author
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

  private

  def validate_isbn_uniqueness(isbn:)
    existing_book = self.class.find_by_isbn(isbn:)
    raise 'ISBN must be unique' if existing_book && existing_book.id != @id

    isbn
  end

  def self.find_by_isbn(isbn:)
    DBConnection.with_connection do |conn|
      result = conn.exec_params('SELECT * FROM items WHERE isbn = $1 LIMIT 1', [isbn])
      return nil unless result.any?

      from_db(row: result.first)
    end
  end
end
