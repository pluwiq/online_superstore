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
    @items.each do |item|
      puts "ID: #{item.id}, Name: #{item.name}, Price: #{item.price}, Type: #{item.class.name}"
    end
  end

  def find_item_by_id(id:)
    row = @db_conn.conn.exec_params('SELECT * FROM items WHERE id = $1 LIMIT 1', [id]).first
    return nil unless row

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
      name: prompt_for(field: :name),
      email: prompt_for(field: :email),
      phone: prompt_for(field: :phone),
      address: prompt_for(field: :address)
    )
    @customers << customer
    save_customer_to_db(customer:)
    customer
  end

  def save_customer_to_db(customer:)
    query = 'INSERT INTO customers (name, email, phone, address) VALUES ($1, $2, $3, $4)'
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
      print 'Select an item ID to add to your order, or type "done" to finish: '
      input = gets.chomp.downcase
      break if input == 'done'

      item = find_item_by_id(id: input.to_i)
      next (puts 'Invalid item ID.') unless item

      print 'Enter quantity: '
      order.add_item(item:, quantity: gets.chomp.to_i)
    end
  end

  def delete_order(order_id:)
    order = @orders.find { |o| o.id == order_id }
    return puts 'Order not found.' unless order

    @orders.delete(order)
    @order_source.delete_order(order_id:)
    puts "Order ##{order_id} has been deleted."
  end

  def list_customers
    puts 'Customers:'
    @customers.each { |customer| puts "ID: #{customer.id}, Name: #{customer.name}, Email: #{customer.email}" }
  end

  def list_orders
    puts 'Orders:'
    @orders.each do |order|
      puts "Order ID: #{order.id}, Customer ID: #{order.customer_id}, Total Sum: #{order.total_sum}"
      order.show_order
    end
  end

  private

  FILE_NAME = 'orders.csv'.freeze
end
