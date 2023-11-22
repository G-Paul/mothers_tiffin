import 'package:flutter/foundation.dart';

class CartProvider extends ChangeNotifier {
  final Map<String, dynamic> _selectedItems = {};
  bool get isCartEmpty => _selectedItems.isEmpty;
  Map<String, dynamic> get selectedItems => _selectedItems;

  void changeCart({
    required String id,
    required String title,
    required String imageUrl,
    required num price,
    int inc = 0,
  }) {
    if (_selectedItems.containsKey(id)) {
      _selectedItems[id]!['quantity'] += inc;
    } else {
      _selectedItems[id] = {
        'quantity': 1,
        'price': price,
        'title': title,
        'imageUrl': imageUrl,
      };
    }
    if (_selectedItems[id]!['quantity'] == 0) {
      _selectedItems.remove(id);
    }
    notifyListeners();
  }
}
