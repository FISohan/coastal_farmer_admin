import 'package:isar/isar.dart';

part 'order.g.dart';

@embedded
class OrderItem {
  String? productId;
  String? productName;
  double? unitPrice;
  double? quantity;

  double get totalPrice => (unitPrice ?? 0) * (quantity ?? 0);
}

@collection
class CustomerOrder {
  Id id = Isar.autoIncrement;

  String customerName = '';
  String customerPhone = '';
  String customerAddress = '';

  DateTime orderDate = DateTime.now();

  List<OrderItem> items = [];

  double totalAmount = 0;

  @enumerated
  OrderStatus status = OrderStatus.pending;

  String notes = '';
}

enum OrderStatus { pending, confirmed, delivered, cancelled }
