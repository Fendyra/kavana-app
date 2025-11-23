import 'package:kavana_app/data/models/mood_model.dart';
import 'package:kavana_app/services/pet_service.dart';

class PetIntegrationHelper {
  static final PetService _petService = PetService();

  /// Update pet happiness based on mood
  /// Call this after user selects their mood
  static Future<void> updatePetFromMood(MoodModel mood) async {
    final hasPet = await _petService.hasPet();
    if (!hasPet) return;

    final pet = await _petService.getPet();
    if (pet == null) return;

    await _petService.updateFromMood(pet, mood);
  }

  /// Update pet currency from total savings
  /// Call this after user adds savings
  static Future<void> updateCurrencyFromSavings(double totalSavings) async {
    await _petService.updateCurrencyFromSavings(totalSavings);
  }

  /// Add experience to pet when user completes tasks
  /// Call this when agenda is marked as complete
  static Future<void> rewardPetExperience(int experience) async {
    final hasPet = await _petService.hasPet();
    if (!hasPet) return;

    final pet = await _petService.getPet();
    if (pet == null) return;

    await _petService.addExperience(pet, experience);
  }

  /// Add currency to pet when user completes tasks
  /// Call this as additional reward for productivity
  static Future<void> rewardPetCurrency(int coins) async {
    await _petService.addCurrency(coins);
  }

  /// Reward pet for daily login or streak
  static Future<void> rewardDailyBonus() async {
    final hasPet = await _petService.hasPet();
    if (!hasPet) return;

    final pet = await _petService.getPet();
    if (pet == null) return;

    // Give daily bonus
    await _petService.addExperience(pet, 10);
    await _petService.addCurrency(5);
  }

  /// Check if pet needs attention (low stats)
  static Future<bool> doesPetNeedAttention() async {
    final hasPet = await _petService.hasPet();
    if (!hasPet) return false;

    final pet = await _petService.getPet();
    if (pet == null) return false;

    return pet.needsAttention;
  }
}
