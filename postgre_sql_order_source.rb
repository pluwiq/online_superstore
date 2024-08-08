# frozen_string_literal: true

require 'pg'
require_relative 'order'
require_relative 'item'
require_relative 'db_connection'
require_relative 'order_item_operations'

class PostgreSQLOrderSource < OrderSource
  include OrderItemOperations

  def load_orders
    orders = []
    DBConnection.with_connection do |conn|
      result = conn.exec('SELECT * FROM orders')
      result.each do |row|
        order = build_order(row:, conn:)
        orders << order
      end
    end
    orders
  end

  def save_order(order:)
    DBConnection.with_connection do |conn|
      result = conn.exec_params('INSERT INTO orders (customer_id, total_sum) VALUES ($1, $2) RETURNING id',
                                [order.customer_id, order.total_sum])
      order.id = result.first['id'].to_i

      insert_order_items(order:, conn:)
    end
  end

  def update_order(order:)
    DBConnection.with_connection do |conn|
      conn.exec_params('UPDATE orders SET total_sum = $1 WHERE id = $2', [order.total_sum, order.id])
      update_order_items(order:, conn:)
    end
  end

  def delete_order(order_id:)
    DBConnection.with_connection do |conn|
      conn.exec_params('DELETE FROM order_items WHERE order_id = $1', [order_id])
      conn.exec_params('DELETE FROM orders WHERE id = $1', [order_id])
    end
  end

  private

  def build_order(row:, conn:)
    order = Order.new(id: row['id'].to_i, customer_id: row['customer_id'].to_i)
    order_items = conn.exec('SELECT * FROM order_items WHERE order_id = $1', [order.id])
    order_items.each do |item_row|
      item_data = conn.exec('SELECT * FROM items WHERE id = $1', [item_row['item_id'].to_i]).first
      order.add_item(item: Item.from_db(row: item_data), quantity: item_row['quantity'].to_i)
    end
    order
  end
end
