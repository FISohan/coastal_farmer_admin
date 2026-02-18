import 'package:flutter/material.dart';
import '../models/order.dart';
import '../services/isar_service.dart';
import 'package:isar/isar.dart';

class OrderProvider extends ChangeNotifier {
  final IsarService _isarService;

  List<CustomerOrder> _orders = [];
  bool _isLoading = false;

  OrderProvider(this._isarService) {
    loadOrders();
  }

  List<CustomerOrder> get orders => _orders;
  bool get isLoading => _isLoading;

  int get totalOrders => _orders.length;

  double get totalRevenue => _orders
      .where((o) => o.status != OrderStatus.cancelled)
      .fold(0.0, (sum, o) => sum + o.totalAmount);

  Future<void> loadOrders() async {
    _isLoading = true;
    notifyListeners();

    try {
      _orders = await _isarService.isar.customerOrders
          .where()
          .sortByOrderDateDesc()
          .findAll();
    } catch (e) {
      debugPrint('Error loading orders: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addOrder(CustomerOrder order) async {
    try {
      await _isarService.isar.writeTxn(() async {
        await _isarService.isar.customerOrders.put(order);
      });
      await loadOrders();
      return true;
    } catch (e) {
      debugPrint('Error adding order: $e');
      return false;
    }
  }

  Future<bool> updateOrderStatus(int id, OrderStatus status) async {
    try {
      final order = await _isarService.isar.customerOrders.get(id);
      if (order == null) return false;

      order.status = status;
      await _isarService.isar.writeTxn(() async {
        await _isarService.isar.customerOrders.put(order);
      });
      await loadOrders();
      return true;
    } catch (e) {
      debugPrint('Error updating order status: $e');
      return false;
    }
  }

  Future<bool> deleteOrder(int id) async {
    try {
      await _isarService.isar.writeTxn(() async {
        await _isarService.isar.customerOrders.delete(id);
      });
      await loadOrders();
      return true;
    } catch (e) {
      debugPrint('Error deleting order: $e');
      return false;
    }
  }
}
