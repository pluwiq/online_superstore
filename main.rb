# frozen_string_literal: true

require_relative 'online_store'

store = OnlineStore.new

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
    puts 'Enter customer ID:'
    customer_id = gets.chomp.to_i
    customer = store.customers.find { |c| c.id == customer_id }
    if customer
      order = store.create_order(customer:)
      puts "Order created with total sum: #{order.total_sum}"
    else
      puts 'Customer not found.'
    end
  when 4
    store.list_orders
  when 5
    puts 'Enter customer ID:'
    customer_id = gets.chomp.to_i
    customer = store.customers.find { |c| c.id == customer_id }
    if customer
      puts 'Enter order ID to pay:'
      order_id = gets.chomp.to_i
      if customer.orders.any? { |o| o.id == order_id }
        customer.pay_order(order_id:)
        store.order_source.update_order(order: customer.orders.find { |o| o.id == order_id })
      else
        puts 'Order ID not found for this customer.'
      end
    else
      puts 'Customer not found.'
    end
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
