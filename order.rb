# frozen_string_literal: true

require 'csv'

class Order
  attr_accessor :id, :customer_id, :items, :total_sum

  def initialize(id:, customer_id:)
    @id = id
    @customer_id = customer_id
    @items = []
    @total_sum = 0
  end

  def add_item(item:, quantity: 1)
    @items << { item:, quantity: }
    calculate_total_sum
  end

  def delete_item(item_id:)
    @items.reject! { |i| i[:item].id == item_id }
    calculate_total_sum
  end

  def get_items
    @items
  end

  def get_items_count
    @items.size
  end

  def calculate_total_sum
    @total_sum = @items.sum { |i| i[:item].price * i[:quantity] }
  end

  def export_order(file_path:)
    CSV.open(file_path, 'wb') do |csv|
      csv << ['Item ID', 'Item Name', 'Quantity', 'Price']
      items.each { |i| csv << [i[:item].id, i[:item].name, i[:quantity], i[:item].price]}
      end
    end

  def show_order
    return puts 'No items in this order.' if @items.empty?

    @items.each do |i|
      puts "Item: #{i[:item].name}, Quantity: #{i[:quantity]}, Price: #{i[:item].price}"
    end
  end
end
