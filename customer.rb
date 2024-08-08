# frozen_string_literal: true

class Customer
  attr_accessor :id, :name, :email, :phone, :address, :orders

  def initialize(id:, name:, email:, phone:, address:)
    @id = id
    @name = name
    @address = address
    @email = email
    @phone = phone
    @orders = []
  end

  def create_order(order:)
    @orders << order
  end

  def pay_order(order_id:)
    order = @orders.find { |o| o.id == order_id }
    order ? (puts "Order ##{order_id} paid. Total sum: #{order.total_sum}") : (puts 'Order not found for this customer.')
  end
end
