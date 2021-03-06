require 'csv'
require_relative 'customer.rb'
require 'pry'

class Order
  attr_reader :id
  attr_accessor :products, :products, :customer, :fulfillment_status

  @@orders = []

  def initialize(id, products, customer, fulfillment_status = :pending)
    @id = id
    @products = products #hash {item: cost}
    @customer = customer
    valid_statuses = [:pending, :paid, :processing, :shipped, :complete]
    raise ArgumentError, "Invalid fulfillment status" unless valid_statuses.include? fulfillment_status
    @fulfillment_status = fulfillment_status
  end

  def self.load_data(filename) #take file name and returns data from file in array of hashes
    data = CSV.open(filename,'r', headers:false).map do |line|
    line.to_a
    end
    return data
  end

  def self.parse_product_array(string)#try regex /:|;/
    products_hash = {}
    products_array = string.split(';') #[lobster:17, annato seed:58]
    products_array.each do |product|
      single_item_array = product.split(':')
      products_hash[single_item_array[0]]= single_item_array[1].to_f
    end
    return products_hash #hash {item:price}
  end

  def self.format_data(data)
      data.each do |individual|
        id = individual[0].to_i
        products = parse_product_array(individual[1])
        customer = Customer.find(individual[2].to_i)
        fulfillment_status = individual[3].to_sym
        @@orders << self.new(id, products, customer, fulfillment_status)
      end
    return @@orders
  end

  def total
    order_total = @products.values.reduce(0.0){ |total, price| total + price}
    order_total_with_tax = order_total * 1.075
    return order_total_with_tax.round(2)
  end

  def add_product(product_name, price)
    raise ArgumentError, "Repeated Item" if @products.keys.include? product_name
    @products[product_name] = price
  end

  def remove_product(product_name)
    raise ArgumentError, "Item not found in order" unless @products.keys.include? product_name
    @products.delete_if {|key, value| key == product_name}
  end


  def self.all
    return @@orders#collection of Customer instances - all of the ifno from csv file
  end

  def self.find(id)
    @@orders.each do |order|
      if id.to_i == order.id.to_i
        return order
      end
    end
    return nil
  end

  def self.find_by_customer(customer_id_number)#need to rewrite test for 
    customer_orders = []
    @@orders.each do |order| #consider raising argument for customers with no order
      if customer_id_number.to_i == order.customer.id.to_i
        customer_orders << order
      end
    end
    return customer_orders
  end
end

Order.format_data(Order.load_data('../data/orders.csv'))
p Order.find_by_customer(1)
