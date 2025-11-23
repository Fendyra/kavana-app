class PetModel {
  final int? id;
  final int userId;
  final String name;
  final PetType type;
  final int level;
  final int experience;
  final int hunger;
  final int happiness;
  final int health;
  final DateTime lastFed;
  final DateTime lastInteraction;
  final DateTime createdAt;
  final List<String> accessories;

  PetModel({
    this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.level,
    required this.experience,
    required this.hunger,
    required this.happiness,
    required this.health,
    required this.lastFed,
    required this.lastInteraction,
    required this.createdAt,
    this.accessories = const [],
  });

  // Experience needed for next level
  int get experienceToNextLevel => level * 100;

  // Get evolution stage based on level
  PetEvolutionStage get evolutionStage {
    if (level >= 20) return PetEvolutionStage.master;
    if (level >= 15) return PetEvolutionStage.ultimate;
    if (level >= 10) return PetEvolutionStage.champion;
    if (level >= 5) return PetEvolutionStage.rookie;
    return PetEvolutionStage.baby;
  }

  // Check if pet needs attention
  bool get needsAttention => hunger < 30 || happiness < 30 || health < 30;

  // Get pet condition
  PetCondition get condition {
    final avgStats = (hunger + happiness + health) / 3;
    if (avgStats >= 80) return PetCondition.excellent;
    if (avgStats >= 60) return PetCondition.good;
    if (avgStats >= 40) return PetCondition.okay;
    if (avgStats >= 20) return PetCondition.poor;
    return PetCondition.critical;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'type': type.toString().split('.').last,
      'level': level,
      'experience': experience,
      'hunger': hunger,
      'happiness': happiness,
      'health': health,
      'last_fed': lastFed.toIso8601String(),
      'last_interaction': lastInteraction.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'accessories': accessories,
    };
  }

  factory PetModel.fromJson(Map<String, dynamic> json) {
    return PetModel(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      type: PetType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => PetType.cat,
      ),
      level: json['level'],
      experience: json['experience'],
      hunger: json['hunger'],
      happiness: json['happiness'],
      health: json['health'],
      lastFed: DateTime.parse(json['last_fed']),
      lastInteraction: DateTime.parse(json['last_interaction']),
      createdAt: DateTime.parse(json['created_at']),
      accessories: json['accessories'] != null
          ? List<String>.from(json['accessories'])
          : [],
    );
  }

  PetModel copyWith({
    int? id,
    int? userId,
    String? name,
    PetType? type,
    int? level,
    int? experience,
    int? hunger,
    int? happiness,
    int? health,
    DateTime? lastFed,
    DateTime? lastInteraction,
    DateTime? createdAt,
    List<String>? accessories,
  }) {
    return PetModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      level: level ?? this.level,
      experience: experience ?? this.experience,
      hunger: hunger ?? this.hunger,
      happiness: happiness ?? this.happiness,
      health: health ?? this.health,
      lastFed: lastFed ?? this.lastFed,
      lastInteraction: lastInteraction ?? this.lastInteraction,
      createdAt: createdAt ?? this.createdAt,
      accessories: accessories ?? this.accessories,
    );
  }
}

enum PetType {
  cat,
  dog,
  bird,
  rabbit,
  hamster,
}

enum PetEvolutionStage {
  baby,
  rookie,
  champion,
  ultimate,
  master,
}

enum PetCondition {
  critical,
  poor,
  okay,
  good,
  excellent,
}

extension PetTypeExtension on PetType {
  String get displayName {
    switch (this) {
      case PetType.cat:
        return '🐱 Kucing';
      case PetType.dog:
        return '🐶 Anjing';
      case PetType.bird:
        return '🐦 Burung';
      case PetType.rabbit:
        return '🐰 Kelinci';
      case PetType.hamster:
        return '🐹 Hamster';
    }
  }

  String get emoji {
    switch (this) {
      case PetType.cat:
        return '🐱';
      case PetType.dog:
        return '🐶';
      case PetType.bird:
        return '🐦';
      case PetType.rabbit:
        return '🐰';
      case PetType.hamster:
        return '🐹';
    }
  }
}

extension PetEvolutionStageExtension on PetEvolutionStage {
  String get displayName {
    switch (this) {
      case PetEvolutionStage.baby:
        return 'Baby';
      case PetEvolutionStage.rookie:
        return 'Rookie';
      case PetEvolutionStage.champion:
        return 'Champion';
      case PetEvolutionStage.ultimate:
        return 'Ultimate';
      case PetEvolutionStage.master:
        return 'Master';
    }
  }

  String get description {
    switch (this) {
      case PetEvolutionStage.baby:
        return 'Hewan peliharaan baru lahir, butuh perhatian ekstra';
      case PetEvolutionStage.rookie:
        return 'Mulai tumbuh dan belajar';
      case PetEvolutionStage.champion:
        return 'Hewan yang kuat dan sehat';
      case PetEvolutionStage.ultimate:
        return 'Hewan yang sangat berkembang';
      case PetEvolutionStage.master:
        return 'Tingkat evolusi tertinggi!';
    }
  }
}
