import 'package:uuid/uuid.dart';

import '../../services/storage_service.dart';
import 'models/couple_link.dart';

/// Local placeholder service for couples mode.
///
/// **Design note (real backend deferred):** pairing requires a server to
/// exchange share codes between two devices. Until a backend exists this
/// service only generates and stores a local link — nothing is transmitted.
/// The persisted key holds no PII beyond an opaque code.
class CoupleService {
  CoupleService(this._storage);

  static const String _kLinkKey = 'couple.link';

  final StorageService _storage;

  /// Restores the local link, or null when never created.
  CoupleLink? load() {
    final dynamic raw = _storage.read(_kLinkKey);
    if (raw is! Map<String, dynamic>) return null;
    try {
      return CoupleLink.fromJson(raw);
    } on Object {
      return null;
    }
  }

  /// Generates and persists a fresh local share link.
  Future<CoupleLink> createLink() async {
    final CoupleLink link = CoupleLink(
      code: formatCoupleCode(const Uuid().v4()),
      createdAt: DateTime.now(),
    );
    await _storage.write(_kLinkKey, link.toJson());
    return link;
  }

  /// Clears the local link.
  Future<void> clear() => _storage.remove(_kLinkKey);
}
