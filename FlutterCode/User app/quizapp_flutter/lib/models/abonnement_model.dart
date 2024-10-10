class AbonnementModel {
  String name;
  double price;
  String? id;
  String? imageUrl;
  String? description;
  int numbreJours;
  DateTime? createdAt;
  DateTime? updatedAt;

  AbonnementModel({
    required this.name,
    required this.price,
    required this.numbreJours,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.id,
    this.imageUrl,
  });

  factory AbonnementModel.fromJson(Map<String, dynamic> json) {
    return AbonnementModel(
      name: json['name'],
      price: json['price'],
      description: json['description'],
      numbreJours: json['numbreJours'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      id: json['id'],
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'description': description,
      'numbreJours': numbreJours,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'id': id,
      'imageUrl': imageUrl,
    };
  }

  List<AbonnementModel> listAbonnementFromFirestore(
      List<Map<String, dynamic>> list) {
    List<AbonnementModel> abonnements = [];
    list.forEach((element) {
      abonnements.add(AbonnementModel.fromJson(element));
    });
    return abonnements;
  }

  // end of the class
}
