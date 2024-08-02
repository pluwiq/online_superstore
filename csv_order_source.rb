# frozen_string_literal: true

require 'csv'
require_relative 'order'
require_relative 'item'

class CsvOrderSource < OrderSource
  def initialize(file_path:)
    @file_path = file_path
  end

  def load_orders
    orders_hash = {}
    return orders_hash.values unless File.exist?(@file_path)

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
    CSV.open(@file_path, "a+") do |csv|
      order.items.each do |order_item|
        csv << [order.id,
                order.customer_id,
                order_item[:item].id,
                order_item[:item].name,
                order_item[:item].description,
                order_item[:item].price,
                order_item[:quantity]]
      end
    end
  end

  def update_order(order:)
    orders = load_orders
    orders.reject! { |o| o.id == order.id }
    orders << order

    CSV.open(@file_path, "wb") do |csv|
      csv << %w[order_id customer_id item_id name description price quantity]
      orders.each do |o|
        o.items.each do |order_item|
          csv << [o.id,
                  o.customer_id,
                  order_item[:item].id,
                  order_item[:item].name,
                  order_item[:item].description,
                  order_item[:item].price,
                  order_item[:quantity]]
        end
      end
    end
  end

  def delete_order(order_id:)
    orders = load_orders
    orders.reject! { |o| o.id == order_id }

    CSV.open(@file_path, "wb") do |csv|
      csv << %w[order_id customer_id item_id name description price quantity]
      orders.each do |o|
        o.items.each do |order_item|
          csv << [o.id,
                  o.customer_id,
                  order_item[:item].id,
                  order_item[:item].name,
                  order_item[:item].description,
                  order_item[:item].price,
                  order_item[:quantity]]
        end
      end
    end
  end
end
