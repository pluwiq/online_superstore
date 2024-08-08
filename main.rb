# frozen_string_literal: true

require_relative 'online_store'
require_relative 'order_helpers'
require_relative 'db_validator'

DBValidator.new.validate_items

store = OnlineStore.new
include OrderHelpers

puts 'Welcome to the Online Store!'
loop do
  puts "1. Create a new customer\n" \
         "2. List customers\n" \
         "3. Create a new order\n" \
         "4. List orders\n" \
         "5. Pay for an order\n" \
         "6. Delete an order\n" \
         "7. Exit"
  input = gets.chomp.to_i
  case input
  when 1
    customer = store.create_customer
    puts "Customer created: #{customer.name}"
  when 2
    store.list_customers
  when 3
    handle_create_order(store:)
  when 4
    store.list_orders
  when 5
    handle_pay_order(store:)
  when 6
    puts 'Enter order ID to delete:'
    order_id = gets.chomp.to_i
    store.delete_order(order_id:)
  when 7
    break
  else
    puts 'Invalid option.'
  end
end
