# frozen_string_literal: true

require 'csv'
require_relative 'order'
require_relative 'item'
require_relative 'db_connection'

class CsvOrderSource < OrderSource
  def initialize(file_path:)
    @file_path = file_path
  end

  def load_orders
    return [] unless File.exist?(@file_path)

    orders_hash = {}

    CSV.foreach(@file_path, headers: true, header_converters: :symbol) do |row|
      order_id = row[:order_id].to_i
      orders_hash[order_id] ||= Order.new(id: order_id, customer_id: row[:customer_id].to_i)

      item = Item.new(
        id: row[:item_id].to_i,
        name: row[:name],
        description: row[:description],
        price: row[:price].to_f
      )
      orders_hash[order_id].add_item(item:, quantity: row[:quantity].to_i)
    end

    orders_hash.values
  end

  def save_order(order:)
    DBConnection.with_connection do |conn|
      query = %(
        SELECT
          oi.order_id,
          o.customer_id,
          i.id AS item_id,
          i.name,
          i.description,
          i.price,
          oi.quantity
        FROM order_items oi
        JOIN items i ON oi.item_id = i.id
        JOIN orders o ON oi.order_id = o.id
        WHERE oi.order_id = $1
      )

      result = conn.exec_params(query, [order.id])

      CSV.open(@file_path, 'a+') do |csv|
        result.each do |row|
          csv << [
            row['order_id'],
            row['customer_id'],
            row['item_id'],
            row['name'],
            row['description'],
            row['price'],
            row['quantity']
          ]
        end
      end
    end
  end

  def update_order(order:)
    orders = load_orders
    orders.reject! { |o| o.id == order.id }
    orders << order

    write_orders_to_csv(orders:)
  end

  def delete_order(order_id:)
    orders = load_orders
    orders.reject! { |o| o.id == order_id }

    write_orders_to_csv(orders:)
  end

  private

  def write_orders_to_csv(orders:)
    return if orders.empty?

    DBConnection.with_connection do |conn|
      order_ids = orders.map(&:id).join(',')
      query = %(
        SELECT
          oi.order_id,
          o.customer_id,
          i.id AS item_id,
          i.name,
          i.description,
          i.price,
          oi.quantity
        FROM orders o
        JOIN order_items oi ON o.id = oi.order_id
        JOIN items i ON oi.item_id = i.id
        WHERE o.id IN (#{order_ids})
      )

      result = conn.exec(query)

      CSV.open(@file_path, 'wb') do |csv|
        csv << %w[order_id customer_id item_id name description price quantity]
        result.each do |row|
          csv << [
            row['order_id'],
            row['customer_id'],
            row['item_id'],
            row['name'],
            row['description'],
            row['price'],
            row['quantity']
          ]
        end
      end
    end
  end
end
