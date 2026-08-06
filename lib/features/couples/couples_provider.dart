import 'package:flutter/foundation.dart';

import 'couples_service.dart';
import 'models/couple_link.dart';

/// Reactive facade over [CoupleService].
class CouplesProvider extends ChangeNotifier {
  CouplesProvider(this._service);

  final CoupleService _service;

  CoupleLink? _link;

  /// Current local link, or null when not created.
  CoupleLink? get link => _link;

  /// Restores the stored link, if any.
  void load() {
    _link = _service.load();
    notifyListeners();
  }

  /// Generates a new local share link.
  Future<CoupleLink> createLink() async {
    _link = await _service.createLink();
    notifyListeners();
    return _link!;
  }

  /// Clears the local link.
  Future<void> clear() async {
    await _service.clear();
    _link = null;
    notifyListeners();
  }
}