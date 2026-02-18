import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/order.dart';

class IsarService {
  late final Isar isar;

  Future<void> init() async {
    final String dir;
    if (kIsWeb) {
      dir = '';
    } else {
      final appDir = await getApplicationDocumentsDirectory();
      dir = appDir.path;
    }
    isar = await Isar.open([CustomerOrderSchema], directory: dir);
  }
}
