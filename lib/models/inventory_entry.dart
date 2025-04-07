enum Team { SPAEHER, AMEISLI }

enum Einheit {
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

class Artikel {
  final int id;
  final String artikel;
  final String lager;
  final int menge;
  final Einheit einheit;
  final String? groesse;
  final String rubrik;
  final List<InventoryEntry> entries;

  Artikel({
    required this.id,
    required this.artikel,
    required this.lager,
    required this.menge,
    required this.einheit,
    this.groesse,
    required this.rubrik,
    this.entries = const [],
  });

  factory Artikel.fromJson(Map<String, dynamic> json) {
    return Artikel(
      id: json['id'] as int,
      artikel: json['artikel'] as String,
      lager: json['lager'] as String,
      menge: json['menge'] as int,
      einheit: Einheit.values.firstWhere(
        (e) => e.toString() == 'Einheit.${json['einheit']}',
      ),
      groesse: json['groesse'] as String?,
      rubrik: json['rubrik'] as String,
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
  final Artikel type;

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
      type: Artikel.fromJson(json['type'] as Map<String, dynamic>),
    );
  }
}
