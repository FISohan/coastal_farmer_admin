import 'dart:convert';

enum OrderStatus { pending, confirmed, delivered, cancelled }

enum OrderType { online, offline }

class OrderItem {
  String productId;
  String productName;
  double unitPrice;
  double quantity;

  OrderItem({
    this.productId = '',
    this.productName = '',
    this.unitPrice = 0,
    this.quantity = 0,
  });

  double get totalPrice => unitPrice * quantity;

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'productName': productName,
    'unitPrice': unitPrice,
    'quantity': quantity,
  };

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    productId: json['productId'] ?? '',
    productName: json['productName'] ?? '',
    unitPrice: (json['unitPrice'] ?? 0).toDouble(),
    quantity: (json['quantity'] ?? 0).toDouble(),
  );
}

class CustomerOrder {
  int id;
  OrderType orderType;
  String customerName;
  String customerPhone;
  String customerAddress;
  DateTime orderDate;
  List<OrderItem> items;
  double totalAmount;
  OrderStatus status;
  String notes;

  CustomerOrder({
    this.id = 0,
    this.orderType = OrderType.offline,
    this.customerName = '',
    this.customerPhone = '',
    this.customerAddress = '',
    DateTime? orderDate,
    List<OrderItem>? items,
    this.totalAmount = 0,
    this.status = OrderStatus.pending,
    this.notes = '',
  }) : orderDate = orderDate ?? DateTime.now(),
       items = items ?? [];

  Map<String, dynamic> toJson() => {
    'id': id,
    'orderType': orderType.index,
    'customerName': customerName,
    'customerPhone': customerPhone,
    'customerAddress': customerAddress,
    'orderDate': orderDate.toIso8601String(),
    'items': items.map((e) => e.toJson()).toList(),
    'totalAmount': totalAmount,
    'status': status.index,
    'notes': notes,
  };

  factory CustomerOrder.fromJson(Map<String, dynamic> json) => CustomerOrder(
    id: json['id'] ?? 0,
    orderType: OrderType.values[json['orderType'] ?? 1],
    customerName: json['customerName'] ?? '',
    customerPhone: json['customerPhone'] ?? '',
    customerAddress: json['customerAddress'] ?? '',
    orderDate: DateTime.parse(json['orderDate']),
    items: (json['items'] as List).map((e) => OrderItem.fromJson(e)).toList(),
    totalAmount: (json['totalAmount'] ?? 0).toDouble(),
    status: OrderStatus.values[json['status'] ?? 0],
    notes: json['notes'] ?? '',
  );

  String toJsonString() => jsonEncode(toJson());

  factory CustomerOrder.fromJsonString(String jsonStr) =>
      CustomerOrder.fromJson(jsonDecode(jsonStr));
}
