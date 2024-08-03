# frozen_string_literal: true

module DBLoader
  def load_items(conn:)
    items = []
    result = conn.exec('SELECT * FROM items')
    result.each do |row|
      items << case row['type']
               when 'Book'
                 Book.from_db(row:)
               when 'Game'
                 Game.from_db(row:)
               when 'BoardGame'
                 BoardGame.from_db(row:)
               when 'ComputerGame'
                 ComputerGame.from_db(row:)
               end
    end
    items
  end

  def load_customers(conn:)
    customers = []
    result = conn.exec('SELECT * FROM customers')
    result.each do |row|
      customers << Customer.new(
        id: row['id'].to_i,
        name: row['name'],
        email: row['email'],
        phone: row['phone'],
        address: row['address']
      )
    end
    customers
  end
end
