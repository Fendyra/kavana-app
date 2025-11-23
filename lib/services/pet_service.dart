import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kavana_app/data/models/pet_model.dart';
import 'package:kavana_app/data/models/shop_item_model.dart';
import 'package:kavana_app/data/models/mood_model.dart';

class PetService {
  static const String _petKey = 'user_pet';
  static const String _currencyKey = 'pet_currency';
  static const String _lastUpdateKey = 'pet_last_update';

  // Get user's pet
  Future<PetModel?> getPet() async {
    final prefs = await SharedPreferences.getInstance();
    final petJson = prefs.getString(_petKey);
    if (petJson == null) return null;
    
    final pet = PetModel.fromJson(jsonDecode(petJson));
    return _updatePetStats(pet);
  }

  // Create a new pet
  Future<PetModel> createPet({
    required int userId,
    required String name,
    required PetType type,
  }) async {
    final now = DateTime.now();
    final pet = PetModel(
      userId: userId,
      name: name,
      type: type,
      level: 1,
      experience: 0,
      hunger: 100,
      happiness: 100,
      health: 100,
      lastFed: now,
      lastInteraction: now,
      createdAt: now,
      accessories: [],
    );
    
    await _savePet(pet);
    await _updateLastUpdate();
    return pet;
  }

  // Update pet stats based on time passed
  Future<PetModel> _updatePetStats(PetModel pet) async {
    final prefs = await SharedPreferences.getInstance();
    final lastUpdateString = prefs.getString(_lastUpdateKey);
    
    if (lastUpdateString == null) {
      await _updateLastUpdate();
      return pet;
    }

    final lastUpdate = DateTime.parse(lastUpdateString);
    final now = DateTime.now();
    final hoursPassed = now.difference(lastUpdate).inHours;

    if (hoursPassed == 0) return pet;

    // Decrease stats over time (every hour)
    int newHunger = (pet.hunger - (hoursPassed * 3)).clamp(0, 100);
    int newHappiness = (pet.happiness - (hoursPassed * 2)).clamp(0, 100);
    int newHealth = pet.health;

    // Health decreases if hunger or happiness is too low
    if (newHunger < 20 || newHappiness < 20) {
      newHealth = (pet.health - (hoursPassed * 2)).clamp(0, 100);
    }

    final updatedPet = pet.copyWith(
      hunger: newHunger,
      happiness: newHappiness,
      health: newHealth,
    );

    await _savePet(updatedPet);
    await _updateLastUpdate();
    
    return updatedPet;
  }

  // Feed the pet
  Future<PetModel> feedPet(PetModel pet, ShopItemModel food) async {
    if (food.type != ShopItemType.food) {
      throw Exception('Item ini bukan makanan');
    }

    int newHunger = (pet.hunger + (food.effects['hunger'] ?? 0)).clamp(0, 100);
    int newHealth = (pet.health + (food.effects['health'] ?? 0)).clamp(0, 100);
    int newHappiness = (pet.happiness + (food.effects['happiness'] ?? 0)).clamp(0, 100);

    final updatedPet = pet.copyWith(
      hunger: newHunger,
      health: newHealth,
      happiness: newHappiness,
      lastFed: DateTime.now(),
    );

    await _savePet(updatedPet);
    return updatedPet;
  }

  // Use item on pet
  Future<PetModel> useItem(PetModel pet, ShopItemModel item) async {
    int newHunger = (pet.hunger + (item.effects['hunger'] ?? 0)).clamp(0, 100);
    int newHealth = (pet.health + (item.effects['health'] ?? 0)).clamp(0, 100);
    int newHappiness = (pet.happiness + (item.effects['happiness'] ?? 0)).clamp(0, 100);

    final updatedPet = pet.copyWith(
      hunger: newHunger,
      health: newHealth,
      happiness: newHappiness,
      lastInteraction: DateTime.now(),
    );

    await _savePet(updatedPet);
    return updatedPet;
  }

  // Add accessory to pet
  Future<PetModel> addAccessory(PetModel pet, ShopItemModel accessory) async {
    if (accessory.type != ShopItemType.accessory) {
      throw Exception('Item ini bukan aksesoris');
    }

    if (pet.accessories.contains(accessory.id)) {
      throw Exception('Aksesoris sudah dimiliki');
    }

    final newAccessories = List<String>.from(pet.accessories)..add(accessory.id);
    int newHappiness = (pet.happiness + (accessory.effects['happiness'] ?? 0)).clamp(0, 100);

    final updatedPet = pet.copyWith(
      accessories: newAccessories,
      happiness: newHappiness,
    );

    await _savePet(updatedPet);
    return updatedPet;
  }

  // Add experience to pet (called when user completes tasks)
  Future<PetModel> addExperience(PetModel pet, int exp) async {
    int newExp = pet.experience + exp;
    int newLevel = pet.level;
    
    // Level up if experience is enough
    while (newExp >= newLevel * 100) {
      newExp -= newLevel * 100;
      newLevel++;
    }

    final updatedPet = pet.copyWith(
      experience: newExp,
      level: newLevel,
    );

    await _savePet(updatedPet);
    return updatedPet;
  }

  // Update pet based on user's mood
  Future<PetModel> updateFromMood(PetModel pet, MoodModel mood) async {
    // Mood level affects pet's happiness
    // Mood scale: 1 (very sad) to 5 (very happy)
    int happinessBonus = 0;
    
    switch (mood.level) {
      case 5:
        happinessBonus = 20;
        break;
      case 4:
        happinessBonus = 10;
        break;
      case 3:
        happinessBonus = 5;
        break;
      case 2:
        happinessBonus = -5;
        break;
      case 1:
        happinessBonus = -10;
        break;
    }

    int newHappiness = (pet.happiness + happinessBonus).clamp(0, 100);

    final updatedPet = pet.copyWith(
      happiness: newHappiness,
    );

    await _savePet(updatedPet);
    return updatedPet;
  }

  // Get pet's mood expression based on stats
  String getPetMoodExpression(PetModel pet) {
    final avgStats = (pet.hunger + pet.happiness + pet.health) / 3;
    
    if (avgStats >= 80) return '😊';
    if (avgStats >= 60) return '🙂';
    if (avgStats >= 40) return '😐';
    if (avgStats >= 20) return '😟';
    return '😢';
  }

  // Get currency (from savings)
  Future<int> getCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_currencyKey) ?? 0;
  }

  // Update currency based on savings amount
  Future<void> updateCurrencyFromSavings(double savingsAmount) async {
    final prefs = await SharedPreferences.getInstance();
    // Convert savings to pet coins (1000 savings = 1 coin)
    final coins = (savingsAmount / 1000).floor();
    await prefs.setInt(_currencyKey, coins);
  }

  // Spend currency
  Future<bool> spendCurrency(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final currentCurrency = await getCurrency();
    
    if (currentCurrency < amount) {
      return false;
    }

    await prefs.setInt(_currencyKey, currentCurrency - amount);
    return true;
  }

  // Add currency (reward for completing tasks)
  Future<void> addCurrency(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final currentCurrency = await getCurrency();
    await prefs.setInt(_currencyKey, currentCurrency + amount);
  }

  // Purchase item from shop
  Future<bool> purchaseItem(PetModel pet, ShopItemModel item) async {
    // Check if user has enough currency
    final canAfford = await spendCurrency(item.price);
    if (!canAfford) {
      return false;
    }

    // Apply item effect
    if (item.category == ShopItemCategory.permanent) {
      await addAccessory(pet, item);
    } else {
      await useItem(pet, item);
    }

    return true;
  }

  // Play with pet (interaction)
  Future<PetModel> playWithPet(PetModel pet) async {
    int newHappiness = (pet.happiness + 15).clamp(0, 100);
    int newHealth = (pet.health + 5).clamp(0, 100);

    final updatedPet = pet.copyWith(
      happiness: newHappiness,
      health: newHealth,
      lastInteraction: DateTime.now(),
    );

    await _savePet(updatedPet);
    
    // Add small experience for interaction
    return await addExperience(updatedPet, 5);
  }

  // Delete pet
  Future<void> deletePet() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_petKey);
    await prefs.remove(_lastUpdateKey);
  }

  // Private helper methods
  Future<void> _savePet(PetModel pet) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_petKey, jsonEncode(pet.toJson()));
  }

  Future<void> _updateLastUpdate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastUpdateKey, DateTime.now().toIso8601String());
  }

  // Check if pet exists
  Future<bool> hasPet() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_petKey);
  }
}
