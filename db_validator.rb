# frozen_string_literal: true

require 'pg'
require_relative 'item'
require_relative 'db_connection'

class DBValidator
  def validate_items
    DBConnection.with_connection do |conn|
      existing_items = fetch_existing_items(conn:)
      REQUIRED_ITEMS.each do |item|
        add_item_to_db(conn, item:) unless item_exists?(item:, existing_items:)
      end
    end
  end

  private

  REQUIRED_ITEMS = [
    { name: 'The Great Gatsby', description: 'A classic novel', price: 10.99, type: 'Book', age_restriction: nil, platform: nil },
    { name: 'Cyberpunk 2077', description: 'Futuristic RPG', price: 59.99, type: 'ComputerGame', age_restriction: 'Adults', platform: 'PC' },
    { name: 'Catan', description: 'A popular board game', price: 34.99, type: 'BoardGame', age_restriction: 'Everyone', platform: nil },
    { name: 'Moby Dick', description: 'A novel about a whale', price: 12.99, type: 'Book', age_restriction: nil, platform: nil },
    { name: 'The Witcher 3', description: 'Fantasy RPG', price: 49.99, type: 'ComputerGame', age_restriction: 'Adults', platform: 'PC' },
    { name: 'Monopoly', description: 'Classic board game', price: 19.99, type: 'BoardGame', age_restriction: 'Everyone', platform: nil },
    { name: 'FIFA 21', description: 'Soccer video game', price: 59.99, type: 'ComputerGame', age_restriction: 'Everyone', platform: 'Xbox' },
    { name: 'Settlers of Catan', description: 'Popular strategy board game', price: 29.99, type: 'BoardGame', age_restriction: 'Everyone', platform: nil }
  ].freeze

  def fetch_existing_items(conn:)
    items_from_db = conn.exec('SELECT name, description, price, type, age_restriction, platform FROM items')
    items_from_db.map do |row|
      {
        name: row['name'],
        description: row['description'],
        price: row['price'].to_f,
        type: row['type'],
        age_restriction: row['age_restriction'],
        platform: row['platform']
      }
    end
  end

  def item_exists?(item:, existing_items:)
    existing_items.any? do |existing_item|
      existing_item[:name] == item[:name] &&
        existing_item[:description] == item[:description] &&
        existing_item[:price] == item[:price] &&
        existing_item[:type] == item[:type] &&
        existing_item[:age_restriction] == item[:age_restriction] &&
        existing_item[:platform] == item[:platform]
    end
  end

  def add_item_to_db(conn, item:)
    conn.exec_params('INSERT INTO items (name, description, price, type, age_restriction, platform) VALUES ($1, $2, $3, $4, $5, $6)',
                     [item[:name], item[:description], item[:price], item[:type], item[:age_restriction], item[:platform]])
  end
end
