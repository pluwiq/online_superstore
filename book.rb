# frozen_string_literal: true

require_relative 'item'

class Book < Item
  attr_accessor :author, :publisher, :isbn

  def initialize(id:, name:, description:, price:, author: nil, publisher: nil, isbn: nil)
    super(id:, name:, description:, price:)
    @author = author
    @publisher = publisher
    @isbn = isbn
    validate_isbn_uniqueness
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

  def validate_isbn_uniqueness
    existing_book = self.class.find_by_isbn(isbn:)
    raise 'ISBN must be unique' if existing_book && existing_book.id != @id
  end

  def self.find_by_isbn(isbn:)
    conn = PG.connect(dbname: ENV.fetch('DB_NAME'), user: ENV.fetch('DB_USER'), password: ENV.fetch('DB_PASSWORD'))
    result = conn.exec_params('SELECT * FROM items WHERE isbn = $1 LIMIT 1', [isbn])
    return nil unless result.any?

    row = result.first
    from_db(row:)
  ensure
    conn.close if conn
  end
end
