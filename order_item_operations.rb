# frozen_string_literal: true

module OrderItemOperations
  def insert_order_items(order:, conn:)
    values = order.items.map { |item| "(#{order.id}, #{item[:item].id}, #{item[:quantity]})" }.join(',')
    conn.exec("INSERT INTO order_items (order_id, item_id, quantity) VALUES #{values}")
  end

  def delete_order_items(order_id:, items_to_delete:, conn:)
    unless items_to_delete.empty?
      delete_ids = items_to_delete.join(',')
      conn.exec_params("DELETE FROM order_items WHERE order_id = $1 AND item_id IN (#{delete_ids})", [order_id])
    end
  end

  def update_existing_order_items(order_id:, items_to_update:, new_items_hash:, current_items_hash:, conn:)
    items_to_update.each do |item_id|
      if new_items_hash[item_id] != current_items_hash[item_id]
        conn.exec_params(
          'UPDATE order_items SET quantity = $1 WHERE order_id = $2 AND item_id = $3',
          [new_items_hash[item_id], order_id, item_id]
        )
      end
    end
  end

  def insert_new_order_items(order_id:, items_to_add:, new_items_hash:, conn:)
    return if items_to_add.empty?

    values = items_to_add.map { |item_id| "(#{order_id}, #{item_id}, #{new_items_hash[item_id]})" }.join(',')
    conn.exec("INSERT INTO order_items (order_id, item_id, quantity) VALUES #{values}")
  end

  def update_order_items(order:, conn:)
    current_items_hash = fetch_current_items(order_id: order.id, conn:)
    new_items_hash = order.items.map { |item| [item[:item].id, item[:quantity]] }.to_h

    items_to_delete = current_items_hash.keys - new_items_hash.keys
    items_to_update = new_items_hash.keys & current_items_hash.keys
    items_to_add = new_items_hash.keys - current_items_hash.keys

    delete_order_items(order_id: order.id, items_to_delete:, conn:)
    update_existing_order_items(order_id: order.id, items_to_update:, new_items_hash:, current_items_hash:, conn:)
    insert_new_order_items(order_id: order.id, items_to_add:, new_items_hash:, conn:)
  end

  private

  def fetch_current_items(order_id:, conn:)
    conn.exec_params('SELECT item_id, quantity FROM order_items WHERE order_id = $1', [order_id])
        .map { |row| [row['item_id'].to_i, row['quantity'].to_i] }
        .to_h
  end
end
