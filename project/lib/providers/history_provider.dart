// lib/providers/history_provider.dart
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/history_item.dart';

class HistoryProvider extends ChangeNotifier {
  final Box _box;

  HistoryProvider(this._box) {
    _loadFromBox();
  }

  final List<HistoryItem> _items = [];

  List<HistoryItem> get items => List.unmodifiable(_items);

  void _loadFromBox() {
    _items.clear();
    // box.values contains HistoryItem objects (written via adapter)
    for (final dynamic v in _box.values) {
      if (v is HistoryItem) {
        _items.add(v);
      }
    }
    // Отображаем новые элементы первым в списке (по дате)
    _items.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  Future<void> addItem(HistoryItem item) async {
    // записываем в коробку (ключ не важен, используем auto-increment)
    await _box.add(item);
    // локально вставляем в начало
    _items.insert(0, item);
    notifyListeners();
  }

  Future<void> clearAll() async {
    await _box.clear();
    _items.clear();
    notifyListeners();
  }

  Future<void> deleteAt(int index) async {
    // удалим и в box (ищем соответствующий key)
    if (index < 0 || index >= _items.length) return;
    final item = _items[index];

    // ищем ключ по value — не самое быстрое, но ок для MVP
    final key = _box.keys.firstWhere(
      (k) {
        final v = _box.get(k);
        return v is HistoryItem && v.id == item.id;
      },
      orElse: () => null,
    );

    if (key != null) {
      await _box.delete(key);
    }
    _items.removeAt(index);
    notifyListeners();
  }
}
