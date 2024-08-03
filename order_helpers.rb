# frozen_string_literal: true

module OrderHelpers
  def find_customer(store:)
    puts 'Enter customer ID:'
    customer_id = gets.chomp.to_i
    customer = store.customers.find { |c| c.id == customer_id }
    puts 'Customer not found.' unless customer
    customer
  end

  def handle_create_order(store:)
    customer = find_customer(store:)
    return unless customer

    order = store.create_order(customer:)
    puts "Order created with total sum: #{order.total_sum}"
  end

  def handle_pay_order(store:)
    return unless (customer = find_customer(store:))

    puts 'Enter order ID to pay:'
    order_id = gets.chomp.to_i
    order = customer.orders.find { |o| o.id == order_id }

    puts('Order ID not found for this customer.') && return unless order

    customer.pay_order(order_id:)
    store.order_source.update_order(order:)
  end
end
