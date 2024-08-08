# frozen_string_literal: true

require_relative 'db_connection'
require_relative 'item'

class Book < Item
  attr_accessor :author, :publisher, :isbn

  def initialize(id:, name:, description:, price:, author: nil, publisher: nil, isbn: nil)
    super(id:, name:, description:, price:)
    @isbn = validate_isbn_uniqueness(isbn:, current_id: id)
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

  def validate_isbn_uniqueness(isbn:, current_id:)
    existing_books = self.class.find_all_by_isbn(isbn:)
    if existing_books.any? { |book| book.id != current_id }
      puts "ISBN conflict for ISBN=#{isbn}: existing_books=#{existing_books.map(&:id)}, current_id=#{current_id}"
      raise 'ISBN must be unique'
    end

    isbn
  end

  def self.find_all_by_isbn(isbn:)
    DBConnection.with_connection do |conn|
      result = conn.exec_params('SELECT * FROM items WHERE isbn = $1', [isbn])
      result.map { |row| from_db(row:) }
    end
  end
end
