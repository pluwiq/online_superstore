module DBLoader
  def load_items(conn:)
    items = []
    items_from_db = conn.exec('SELECT * FROM items')
    items_from_db.each do |row|
      begin
        item = case row['type']
               when 'Book'
                 Book.from_db(row:)
               when 'Game'
                 Game.from_db(row:)
               when 'BoardGame'
                 BoardGame.from_db(row:)
               when 'ComputerGame'
                 ComputerGame.from_db(row:)
               else
                 nil
               end
        items << item if item
      rescue => e
        puts "Error loading item with id=#{row['id']}: #{e.message}"
      end
    end
    items.compact
  end

  def load_customers(conn:)
    customers = []
    customers_from_db = conn.exec('SELECT * FROM customers')
    customers_from_db.each do |row|
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
