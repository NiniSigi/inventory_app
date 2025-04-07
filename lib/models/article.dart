class Article {
  final int id;
  final String artikel;
  final String rubrik;
  final String lager;
  final int menge;
  final String? groesse;

  Article({
    required this.id,
    required this.artikel,
    required this.rubrik,
    required this.lager,
    required this.menge,
    this.groesse,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] as int,
      artikel: json['artikel'] as String,
      rubrik: json['rubrik'] as String,
      lager: json['lager'] as String,
      menge: json['menge'] as int,
      groesse: json['groesse'] as String?,
    );
  }
}
