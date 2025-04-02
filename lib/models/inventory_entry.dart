class InventoryType {
  final String artikel;

  InventoryType({required this.artikel});

  factory InventoryType.fromJson(Map<String, dynamic> json) {
    return InventoryType(artikel: json['artikel'] as String);
  }
}

class InventoryEntry {
  final InventoryType type;

  InventoryEntry({required this.type});

  factory InventoryEntry.fromJson(Map<String, dynamic> json) {
    return InventoryEntry(type: InventoryType.fromJson(json['type']));
  }
}
