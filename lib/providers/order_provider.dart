import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/order.dart';

class OrderProvider extends ChangeNotifier {
  static const _storageKey = 'coastal_farmer_orders';

  List<CustomerOrder> _orders = [];
  bool _isLoading = false;
  int _nextId = 1;

  OrderProvider() {
    loadOrders();
  }

  List<CustomerOrder> get orders => _orders;
  bool get isLoading => _isLoading;

  int get totalOrders => _orders.length;

  double get totalRevenue => _orders
      .where((o) => o.status != OrderStatus.cancelled)
      .fold(0.0, (sum, o) => sum + o.totalAmount);

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _orders.map((o) => o.toJsonString()).toList();
    await prefs.setStringList(_storageKey, jsonList);
    await prefs.setInt('${_storageKey}_nextId', _nextId);
  }

  Future<void> loadOrders() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = prefs.getStringList(_storageKey) ?? [];
      _nextId = prefs.getInt('${_storageKey}_nextId') ?? 1;

      _orders = jsonList.map((s) => CustomerOrder.fromJsonString(s)).toList();
      // Sort by date descending
      _orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
    } catch (e) {
      debugPrint('Error loading orders: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addOrder(CustomerOrder order) async {
    try {
      order.id = _nextId++;
      _orders.insert(0, order);
      notifyListeners();
      await _saveToStorage();
      return true;
    } catch (e) {
      debugPrint('Error adding order: $e');
      return false;
    }
  }

  Future<bool> updateOrderStatus(int id, OrderStatus status) async {
    try {
      final index = _orders.indexWhere((o) => o.id == id);
      if (index == -1) return false;

      _orders[index].status = status;
      notifyListeners();
      await _saveToStorage();
      return true;
    } catch (e) {
      debugPrint('Error updating order status: $e');
      return false;
    }
  }

  Future<bool> deleteOrder(int id) async {
    try {
      _orders.removeWhere((o) => o.id == id);
      notifyListeners();
      await _saveToStorage();
      return true;
    } catch (e) {
      debugPrint('Error deleting order: $e');
      return false;
    }
  }
}
