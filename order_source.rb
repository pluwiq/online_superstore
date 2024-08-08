# frozen_string_literal: true

class OrderSource
  def load_orders
    raise NotImplementedError, 'Subclasses must override this method'
  end

  def save_order(order:)
    raise NotImplementedError, 'Subclasses must override this method'
  end

  def update_order(order:)
    raise NotImplementedError, 'Subclasses must override this method'
  end

  def delete_order(order_id:)
    raise NotImplementedError, 'Subclasses must override this method'
  end
end
