# frozen_string_literal: true

require 'pg'
require_relative 'order'
require_relative 'item'

class PostgreSQLOrderSource < OrderSource
  def initialize
    @conn = PG.connect(dbname: 'online_store', user: ENV['DB_USER'], password: ENV['DB_PASSWORD'])
  end

  def load_orders
    orders = []
    result = @conn.exec("SELECT * FROM orders")
    result.each do |row|
      order = Order.new(id: row['id'].to_i, customer_id: row['customer_id'].to_i)
      order_items = @conn.exec("SELECT * FROM order_items WHERE order_id = $1", [order.id])
      order_items.each do |item_row|
        item_data = @conn.exec("SELECT * FROM items WHERE id = $1", [item_row['item_id'].to_i]).first
        item = Item.from_db(row: item_data)
        order.add_item(item:, quantity: item_row['quantity'].to_i)
      end
      orders << order
    end
    orders
  end

  def save_order(order:)
    result = @conn.exec("INSERT INTO orders (customer_id, total_sum) VALUES ($1, $2) RETURNING id",
                        [order.customer_id, order.total_sum])
    order_id = result.first['id'].to_i
    order.id = order_id
    order.items.each do |order_item|
      @conn.exec("INSERT INTO order_items (order_id, item_id, quantity) VALUES ($1, $2, $3)",
                 [order.id, order_item[:item].id, order_item[:quantity]])
    end
  end

  def update_order(order:)
    @conn.exec("UPDATE orders SET total_sum = $1 WHERE id = $2", [order.total_sum, order.id])
    @conn.exec("DELETE FROM order_items WHERE order_id = $1", [order.id])
    order.items.each do |order_item|
      @conn.exec("INSERT INTO order_items (order_id, item_id, quantity) VALUES ($1, $2, $3)",
                 [order.id, order_item[:item].id, order_item[:quantity]])
    end
  end

  def delete_order(order_id:)
    @conn.exec("DELETE FROM order_items WHERE order_id = $1", [order_id])
    @conn.exec("DELETE FROM orders WHERE id = $1", [order_id])
  end
end
