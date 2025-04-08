class Article {
  final int id;
  final String name;
  final String category;
  final String location;
  final int quantity;
  final String? size;

  Article({
    required this.id,
    required this.name,
    required this.category,
    required this.location,
    required this.quantity,
    this.size,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] as int,
      name: json['artikel'] as String,
      category: json['rubrik'] as String,
      location: json['lager'] as String,
      quantity: json['menge'] as int,
      size: json['groesse'] as String?,
    );
  }
}
