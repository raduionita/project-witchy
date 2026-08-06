import '../storage_service.dart';

/// Mixin that persists an in-memory list of models that expose `toJson()`.
///
/// Concrete repositories read a list of JSON maps, hydrate, cache in memory,
/// and write back the serialized list on mutation.
mixin PersistedListMixin<T> {
  StorageService get storage;

  String get key;

  T Function(Map<String, dynamic> json) get fromJson;

  List<T> _cache = <T>[];

  List<T> get items => List<T>.unmodifiable(_cache);

  /// Loads the persisted list (idempotent across calls).
  void load() {
    if (_cache.isNotEmpty) return;
    final List<dynamic> raw = storage.readList(key);
    _cache = raw
        .whereType<Map<String, dynamic>>()
        .map(fromJson)
        .toList(growable: true);
  }

  Future<void> _persist() =>
      storage.writeList(key, _cache.map((T item) => (item as dynamic).toJson()).toList());

  /// Adds [item] and persists.
  Future<void> add(T item) async {
    load();
    _cache.add(item);
    await _persist();
  }

  /// Updates an existing item (matched by identity) and persists.
  Future<void> update(T item) async {
    load();
    final int index = _cache.indexOf(item);
    if (index == -1) return;
    _cache[index] = item;
    await _persist();
  }

  /// Removes [item] and persists.
  Future<void> remove(T item) async {
    load();
    _cache.remove(item);
    await _persist();
  }

  /// Removes all items and persists an empty list.
  Future<void> clear() async {
    _cache = <T>[];
    await _persist();
  }
}