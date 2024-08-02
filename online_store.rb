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
require 'pg'

class OnlineStore
  attr_reader :customers, :orders, :order_source

  def initialize
    user = ENV['DB_USER']
    pass = ENV['DB_PASSWORD']
    @conn = PG.connect(dbname: 'online_store', user:, password: pass)
    @customers = []
    @orders = []
    @order_source = CsvOrderSource.new(file_path: 'orders.csv')
    load_items
    load_customers
    load_orders
  end

  def load_items
    @items = []
    result = @conn.exec("SELECT * FROM items")
    result.each do |row|
      case row['type']
      when 'Book'
        @items << Book.from_db(row:)
      when 'Game'
        @items << Game.from_db(row:)
      when 'BoardGame'
        @items << BoardGame.from_db(row:)
      when 'ComputerGame'
        @items << ComputerGame.from_db(row:)
      end
    end
  end

  def load_customers
    result = @conn.exec("SELECT * FROM customers")
    result.each do |row|
      customer = Customer.new(id: row['id'].to_i,
                              name: row['name'],
                              email: row['email'],
                              phone: row['phone'],
                              address: row['address'])
      @customers << customer
    end
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
    @items[index - 1] if index.between?(1, @items.length)
  end

  def create_customer
    name = prompt_for_name
    email = prompt_for_email
    phone = prompt_for_phone
    puts 'Enter your address:'
    address = gets.chomp
    customer = Customer.new(
      id: @customers.size + 1,
      name: name,
      email: email,
      phone: phone,
      address: address
    )
    @customers << customer
    save_customer_to_db(customer: customer)
    customer
  end

  def prompt_for_name
    loop do
      puts "Enter your name (only letters):"
      name = gets.chomp
      begin
        Validation.validate_name(name)
        return name
      rescue ArgumentError => e
        puts e.message
      end
    end
  end

  def prompt_for_email
    loop do
      puts "Enter your email (at least 9 characters, format @.com):"
      email = gets.chomp
      begin
        Validation.validate_email(email)
        return email
      rescue ArgumentError => e
        puts e.message
      end
    end
  end

  def prompt_for_phone
    loop do
      puts "Enter your phone number (only digits, at least 6 digits):"
      phone = gets.chomp
      begin
        Validation.validate_phone(phone)
        return phone
      rescue ArgumentError => e
        puts e.message
      end
    end
  end

  def save_customer_to_db(customer:)
    @conn.exec("INSERT INTO customers (name, email, phone, address) VALUES ($1, $2, $3, $4)",
               [customer.name, customer.email, customer.phone, customer.address])
  end

  def create_order(customer:)
    order = Order.new(id: @orders.size + 1, customer_id: customer.id)
    loop do
      list_items
      puts "Select an item number to add to your order, or type 'done' to finish:"
      input = gets.chomp
      break if input.downcase == 'done'
      item_index = input.to_i
      item = find_item_by_index(index: item_index)
      if item
        puts 'Enter quantity:'
        quantity = gets.chomp.to_i
        order.add_item(item:, quantity:)
      else
        puts 'Invalid item number.'
      end
    end
    @orders << order
    customer.create_order(order:)
    @order_source.save_order(order:)
    order
  end

  def delete_order(order_id:)
    order = @orders.find { |o| o.id == order_id }
    if order
      @orders.delete(order)
      @order_source.delete_order(order_id: order_id)
      puts "Order ##{order_id} has been deleted."
    else
      puts 'Order not found.'
    end
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
