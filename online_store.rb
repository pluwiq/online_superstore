# frozen_string_literal: true

require_relative 'item'
require_relative 'book'
require_relative 'game'
require_relative 'board_game'
require_relative 'computer_game'
require_relative 'order'
require_relative 'customer'
require_relative 'order_source'
require_relative 'csv_order_source'
require_relative 'validation'
require_relative 'customer_input'
require_relative 'db_loader'
require_relative 'db_connection'

class OnlineStore
  include CustomerInput
  include DBLoader

  attr_reader :customers, :orders, :order_source, :items

  FILE_NAME = 'orders.csv'.freeze

  def initialize
    @db_conn = DBConnection.new
    @customers = load_customers(conn: @db_conn.conn)
    @orders = []
    @items = load_items(conn: @db_conn.conn)
    @order_source = CsvOrderSource.new(file_path: FILE_NAME)
    load_orders
  end

  def load_orders
    @orders = @order_source.load_orders
  end

  def list_items
    puts "Available Items:"
    @items.each_with_index do |item, index|
      puts "#{index + 1}. #{item.name} - #{item.price} (#{item.class.name})"
    end
  end

  def find_item_by_index(index:)
    result = @db_conn.conn.exec_params("SELECT * FROM items WHERE id = $1 LIMIT 1", [index])
    row = result.first
    return unless row

    case row['type']
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
  end

  def create_customer
    customer = Customer.new(
      id: @customers.size + 1,
      name: prompt_for_name,
      email: prompt_for_email,
      phone: prompt_for_phone,
      address: prompt_for_address
    )
    @customers << customer
    save_customer_to_db(customer:)
    customer
  end

  def save_customer_to_db(customer:)
    query = "INSERT INTO customers (name, email, phone, address) VALUES ($1, $2, $3, $4)"
    params = [customer.name, customer.email, customer.phone, customer.address]
    @db_conn.conn.exec_params(query, params)
  end

  def create_order(customer:)
    order = Order.new(id: @orders.size + 1, customer_id: customer.id)
    add_items_to_order(order:)
    @orders << order
    customer.create_order(order:)
    @order_source.save_order(order:)
    order
  end

  def add_items_to_order(order:)
    loop do
      list_items
      puts "Select an item number to add to your order, or type 'done' to finish:"
      input = gets.chomp
      break if input.downcase == 'done'

      item_index = input.to_i
      item = find_item_by_index(index: item_index)

      item or (puts 'Invalid item number.'; next)

      puts 'Enter quantity:'
      quantity = gets.chomp.to_i
      order.add_item(item:, quantity:)
    end
  end

  def delete_order(order_id:)
    order = @orders.find { |o| o.id == order_id }
    order or (puts 'Order not found.'; return)

    @orders.delete(order)
    @order_source.delete_order(order_id:)
    puts "Order ##{order_id} has been deleted."
  end

  def list_customers
    puts 'Customers:'
    @customers.each do |customer|
      puts "ID: #{customer.id}, Name: #{customer.name}, Email: #{customer.email}"
    end
  end

  def list_orders
    puts 'Orders:'
    @orders.each do |order|
      puts "Order ID: #{order.id}, Customer ID: #{order.customer_id}, Total Sum: #{order.total_sum}"
      order.show_order
    end
  end
end
