import 'dart:convert';

class Order {
  final String customerId;
  final String branchId;
  final String orderType;
  final String orderStatus;
  final String totalPrice;
  final String paymentMethod;
  final List<OrderItem> orderItems;
  final String additionalDiscount;
  final String creditCardNumber;
  final String creditCardExpireMonth;
  final String creditCardExpireDay;
  final String nameOnCard;
  final String tableId;
  final String addressId;
  final String customerPhoneId;

  Order({
    required this.customerId,
    required this.branchId,
    required this.orderType,
    required this.orderStatus,
    required this.totalPrice,
    required this.paymentMethod,
    required this.orderItems,
    required this.additionalDiscount,
    required this.creditCardNumber,
    required this.creditCardExpireMonth,
    required this.creditCardExpireDay,
    required this.nameOnCard,
    required this.tableId,
    required this.addressId,
    required this.customerPhoneId,
  });

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'branchId': branchId,
      'orderType': orderType,
      'orderStatus': orderStatus,
      'totalPrice': double.parse(totalPrice),
      'paymentMethod': paymentMethod,
      'orderItems':
          jsonEncode(orderItems.map((item) => item.toJson()).toList()),
      'additionalDiscount': additionalDiscount,
      'creditCardNumber': creditCardNumber,
      'creditCardExpireMonth': creditCardExpireMonth,
      'creditCardExpireDay': creditCardExpireDay,
      'nameOnCard': nameOnCard,
      'tableId': tableId,
      'addressId': addressId,
      'customerPhoneId': customerPhoneId,
    };
  }
}

class OrderItem {
  final int itemId;
  final int quantity;
  final double quotePrice;

  OrderItem({
    required this.itemId,
    required this.quantity,
    required this.quotePrice,
  });

  Map<String, dynamic> toJson() {
    return {
      'item_id': itemId,
      'quantity': quantity,
      'quote_price': quotePrice,
    };
  }
}
