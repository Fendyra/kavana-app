class ShopItemModel {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final int price;
  final ShopItemType type;
  final ShopItemCategory category;
  final Map<String, int> effects;

  ShopItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.price,
    required this.type,
    required this.category,
    required this.effects,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'emoji': emoji,
      'price': price,
      'type': type.toString().split('.').last,
      'category': category.toString().split('.').last,
      'effects': effects,
    };
  }

  factory ShopItemModel.fromJson(Map<String, dynamic> json) {
    return ShopItemModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      emoji: json['emoji'],
      price: json['price'],
      type: ShopItemType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      category: ShopItemCategory.values.firstWhere(
        (e) => e.toString().split('.').last == json['category'],
      ),
      effects: Map<String, int>.from(json['effects']),
    );
  }
}

enum ShopItemType {
  food,
  accessory,
  medicine,
  toy,
}

enum ShopItemCategory {
  consumable,
  permanent,
}

extension ShopItemTypeExtension on ShopItemType {
  String get displayName {
    switch (this) {
      case ShopItemType.food:
        return 'Makanan';
      case ShopItemType.accessory:
        return 'Aksesoris';
      case ShopItemType.medicine:
        return 'Obat';
      case ShopItemType.toy:
        return 'Mainan';
    }
  }
}

// Predefined shop items
class ShopItems {
  static final List<ShopItemModel> allItems = [
    // Food Items
    ShopItemModel(
      id: 'food_1',
      name: 'Makanan Dasar',
      description: 'Makanan sederhana untuk mengisi perut',
      emoji: '🍖',
      price: 10,
      type: ShopItemType.food,
      category: ShopItemCategory.consumable,
      effects: {'hunger': 20, 'health': 5},
    ),
    ShopItemModel(
      id: 'food_2',
      name: 'Makanan Premium',
      description: 'Makanan berkualitas tinggi',
      emoji: '🍗',
      price: 25,
      type: ShopItemType.food,
      category: ShopItemCategory.consumable,
      effects: {'hunger': 40, 'health': 15, 'happiness': 10},
    ),
    ShopItemModel(
      id: 'food_3',
      name: 'Makanan Super',
      description: 'Makanan terbaik untuk hewan kesayangan',
      emoji: '🥩',
      price: 50,
      type: ShopItemType.food,
      category: ShopItemCategory.consumable,
      effects: {'hunger': 60, 'health': 25, 'happiness': 20},
    ),
    ShopItemModel(
      id: 'food_4',
      name: 'Buah Segar',
      description: 'Buah-buahan segar dan sehat',
      emoji: '🍎',
      price: 15,
      type: ShopItemType.food,
      category: ShopItemCategory.consumable,
      effects: {'hunger': 15, 'health': 20},
    ),
    ShopItemModel(
      id: 'food_5',
      name: 'Kue Spesial',
      description: 'Kue lezat untuk hewan peliharaan',
      emoji: '🍰',
      price: 30,
      type: ShopItemType.food,
      category: ShopItemCategory.consumable,
      effects: {'hunger': 25, 'happiness': 30},
    ),

    // Medicine Items
    ShopItemModel(
      id: 'medicine_1',
      name: 'Obat Dasar',
      description: 'Obat untuk meningkatkan kesehatan',
      emoji: '💊',
      price: 20,
      type: ShopItemType.medicine,
      category: ShopItemCategory.consumable,
      effects: {'health': 30},
    ),
    ShopItemModel(
      id: 'medicine_2',
      name: 'Vitamin',
      description: 'Vitamin untuk kebugaran',
      emoji: '💉',
      price: 35,
      type: ShopItemType.medicine,
      category: ShopItemCategory.consumable,
      effects: {'health': 50, 'hunger': 10},
    ),

    // Toy Items
    ShopItemModel(
      id: 'toy_1',
      name: 'Bola Mainan',
      description: 'Bola untuk bermain',
      emoji: '⚽',
      price: 15,
      type: ShopItemType.toy,
      category: ShopItemCategory.consumable,
      effects: {'happiness': 25},
    ),
    ShopItemModel(
      id: 'toy_2',
      name: 'Boneka',
      description: 'Boneka lucu untuk teman bermain',
      emoji: '🧸',
      price: 25,
      type: ShopItemType.toy,
      category: ShopItemCategory.consumable,
      effects: {'happiness': 40, 'health': 5},
    ),

    // Accessory Items (Permanent)
    ShopItemModel(
      id: 'accessory_1',
      name: 'Topi Keren',
      description: 'Topi yang membuat hewan terlihat keren',
      emoji: '🎩',
      price: 100,
      type: ShopItemType.accessory,
      category: ShopItemCategory.permanent,
      effects: {'happiness': 10},
    ),
    ShopItemModel(
      id: 'accessory_2',
      name: 'Kacamata',
      description: 'Kacamata stylish',
      emoji: '🕶️',
      price: 80,
      type: ShopItemType.accessory,
      category: ShopItemCategory.permanent,
      effects: {'happiness': 8},
    ),
    ShopItemModel(
      id: 'accessory_3',
      name: 'Kalung',
      description: 'Kalung cantik',
      emoji: '📿',
      price: 120,
      type: ShopItemType.accessory,
      category: ShopItemCategory.permanent,
      effects: {'happiness': 12},
    ),
    ShopItemModel(
      id: 'accessory_4',
      name: 'Pita',
      description: 'Pita lucu untuk hewan',
      emoji: '🎀',
      price: 60,
      type: ShopItemType.accessory,
      category: ShopItemCategory.permanent,
      effects: {'happiness': 7},
    ),
    ShopItemModel(
      id: 'accessory_5',
      name: 'Mahkota',
      description: 'Mahkota untuk raja hewan peliharaan',
      emoji: '👑',
      price: 200,
      type: ShopItemType.accessory,
      category: ShopItemCategory.permanent,
      effects: {'happiness': 20},
    ),
  ];

  static List<ShopItemModel> getItemsByType(ShopItemType type) {
    return allItems.where((item) => item.type == type).toList();
  }

  static List<ShopItemModel> getItemsByCategory(ShopItemCategory category) {
    return allItems.where((item) => item.category == category).toList();
  }

  static ShopItemModel? getItemById(String id) {
    try {
      return allItems.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }
}
