enum Team { SPAEHER, AMEISLI }

enum Unit {
  STUECK,
  KISTE,
  KARTON,
  PAAR,
  SACK,
  TISCH,
  HOLZ,
  GUSS,
  ALU,
  METALL,
  SET,
  TEXTIL,
  BUND,
  PLASTIK,
  PAPIER,
  GELTEN,
  SCHUESSEL,
  PACK,
  TOPF,
  FARBEN,
}

class Article {
  final int id;
  final String name;
  final String location;
  final int quantity;
  final Unit unit;
  final String? size;
  final String category;
  final List<InventoryEntry> entries;

  Article({
    required this.id,
    required this.name,
    required this.location,
    required this.quantity,
    required this.unit,
    this.size,
    required this.category,
    this.entries = const [],
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] as int,
      name: json['artikel'] as String,
      location: json['lager'] as String,
      quantity: json['menge'] as int,
      unit: Unit.values.firstWhere(
        (e) => e.toString() == 'Unit.${json['einheit']}',
      ),
      size: json['groesse'] as String?,
      category: json['rubrik'] as String,
      entries:
          (json['entries'] as List<dynamic>?)
              ?.map((e) => InventoryEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class InventoryEntry {
  final int id;
  final DateTime startedAt;
  final DateTime? returnedAt;
  final Team teamName;
  final int typeId;
  final int amountOfItem;
  final Article type;

  InventoryEntry({
    required this.id,
    required this.startedAt,
    this.returnedAt,
    required this.teamName,
    required this.typeId,
    required this.amountOfItem,
    required this.type,
  });

  factory InventoryEntry.fromJson(Map<String, dynamic> json) {
    return InventoryEntry(
      id: json['id'] as int,
      startedAt: DateTime.parse(json['startedAt'] as String),
      returnedAt:
          json['returnedAt'] != null
              ? DateTime.parse(json['returnedAt'] as String)
              : null,
      teamName: Team.values.firstWhere(
        (t) => t.toString() == 'Team.${json['teamName']}',
      ),
      typeId: json['typeId'] as int,
      amountOfItem: json['amountOfItem'] as int,
      type: Article.fromJson(json['type'] as Map<String, dynamic>),
    );
  }
}
