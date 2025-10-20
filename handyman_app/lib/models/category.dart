class Category {
  final int id;
  final String name;
  final String nameAr;
  final String icon;
  final String? description;
  final String? descriptionAr;
  final bool isActive;

  Category({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.icon,
    this.description,
    this.descriptionAr,
    required this.isActive,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      nameAr: json['name_ar'],
      icon: json['icon'],
      description: json['description'],
      descriptionAr: json['description_ar'],
      isActive: json['is_active'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_ar': nameAr,
      'icon': icon,
      'description': description,
      'description_ar': descriptionAr,
      'is_active': isActive,
    };
  }

  @override
  String toString() {
    return 'Category{id: $id, name: $name, nameAr: $nameAr, icon: $icon, isActive: $isActive}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
