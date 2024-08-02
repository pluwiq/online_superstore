# Online Superstore

## Short Description

Console application, which is an online store that has orders, merchandise (books, clothes, products)
and customers, promo code, order payment by buyer.

## Estimation (h)

32
д
## Topics

* Classes
* CSV
* [PostgreSQL](https://www.postgresql.org/) or [MySQL](https://www.mysql.com/)
* Single Responsibility Principle
* Open-Closed Principle
* Interface Segregation Principle
* Dependency Inversion Principle

## Requirements

1. Create a class: `Item`. For this main parent class the following fields are required:
   product name, description, price. For child classes create 2-3 additional fields based on the class object itself
   (for example, for the `Book` class: author, number of pages, genre).
   Then according to the `Interface Segregation Principle` divide it into the following classes:
   * `Item`
   * `Book`
   * `Game`, required field: `age limit` (for children, teenagers, adults)
   * `BoardGame`
   * `ComputerGame`, required field: `platform` (PC, Xbox, PS, smartphone)
2. Properly implemented class `Order` (`OrderRepository`, `OrderViewer`), which will serve you as a shopping cart
   for your purchases, and methods with `Single Responsibility Principle`:
   * work with the order itself:
     1. `add_item`
     2. `delete_item`
     3. `get_items`
     4. `get_items_count`
     5. `calculate_total_sum`
   * display the order
     1. `export_order` (return `.csv` file)
     2. `show_order` (return a list of your purchases in console)
   * work with the data warehouse
     1. `load`
     2. `save`
     3. `update`
     4. `delete`
3. For the `OrderRepository` class, our storage is a database.
   We add the ability to load our order data, for example, through `.csv` files.
   To fulfill the `Open-Closed Principle` it's better to apply the following solution - create the `OrderSource` class,
   which will be implemented by corresponding classes `MySQLOrderSource`, `CsvOrderSource`.
4. Implement the class `Customer` with the following fields: name, email address, phone number, address;
   also, each client has the ability to create multiple orders, as well as pay for them and receive a check for payment;
   with `Dependency Inversion Principle` that depends only on the abstraction,
   and the concrete implementation, i.e., the details, are not that important to it.
