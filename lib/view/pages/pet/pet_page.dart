import 'package:flutter/material.dart';
import 'package:kavana_app/common/app_color.dart';
import 'package:kavana_app/data/models/pet_model.dart';
import 'package:kavana_app/data/models/shop_item_model.dart';
import 'package:kavana_app/services/pet_service.dart';
import 'package:kavana_app/view/pages/pet/pet_shop_page.dart';
import 'package:kavana_app/view/pages/pet/create_pet_page.dart';

class PetPage extends StatefulWidget {
  const PetPage({super.key});

  static const String routeName = '/pet';

  @override
  State<PetPage> createState() => _PetPageState();
}

class _PetPageState extends State<PetPage> with TickerProviderStateMixin {
  final PetService _petService = PetService();
  PetModel? _pet;
  int _currency = 0;
  bool _isLoading = true;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadPet();
  }

  void _initAnimations() {
    // Bounce animation
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    
    _bounceAnimation = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
  }

  Future<void> _loadPet() async {
    setState(() => _isLoading = true);
    
    final hasPet = await _petService.hasPet();
    if (!hasPet) {
      setState(() => _isLoading = false);
      return;
    }

    final pet = await _petService.getPet();
    final currency = await _petService.getCurrency();
    
    setState(() {
      _pet = pet;
      _currency = currency;
      _isLoading = false;
    });
  }

  Future<void> _feedPet() async {
    if (_pet == null) return;

    // Show food selection dialog
    final selectedFood = await _showFoodSelectionDialog();
    if (selectedFood == null) return;

    // Check if can afford
    if (_currency < selectedFood.price) {
      _showMessage('Koin tidak cukup!');
      return;
    }

    // Purchase and feed
    final success = await _petService.purchaseItem(_pet!, selectedFood);
    if (success) {
      await _loadPet();
      _showMessage('${_pet!.name} makan ${selectedFood.name}! 😋');
    } else {
      _showMessage('Gagal memberi makan');
    }
  }

  Future<ShopItemModel?> _showFoodSelectionDialog() async {
    final foods = ShopItems.getItemsByType(ShopItemType.food);
    
    return await showDialog<ShopItemModel>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Makanan'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: foods.length,
            itemBuilder: (context, index) {
              final food = foods[index];
              final canAfford = _currency >= food.price;
              
              return ListTile(
                leading: Text(food.emoji, style: const TextStyle(fontSize: 30)),
                title: Text(food.name),
                subtitle: Text('${food.price} koin - ${food.description}'),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: canAfford ? AppColor.primary : Colors.grey,
                ),
                enabled: canAfford,
                onTap: canAfford ? () => Navigator.pop(context, food) : null,
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
        ],
      ),
    );
  }

  Future<void> _playWithPet() async {
    if (_pet == null) return;

    final updatedPet = await _petService.playWithPet(_pet!);
    setState(() => _pet = updatedPet);
    _showMessage('Bermain dengan ${_pet!.name}! +5 XP 🎮');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_pet == null) {
      return CreatePetPage(onPetCreated: _loadPet);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('🐾 ${_pet!.name}'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Row(
                children: [
                  const Icon(Icons.monetization_on, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    '$_currency',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadPet,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Pet Status Card
                _buildStatusCard(),
                const SizedBox(height: 20),
                
                // Pet Display
                _buildPetDisplay(),
                const SizedBox(height: 20),
                
                // Stats
                _buildStatsSection(),
                const SizedBox(height: 20),
                
                // Action Buttons
                _buildActionButtons(),
                const SizedBox(height: 20),
                
                // Info Card
                _buildInfoCard(),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PetShopPage()),
          );
          _loadPet();
        },
        icon: const Icon(Icons.store),
        label: const Text('Toko'),
        backgroundColor: AppColor.primary,
      ),
    );
  }

  Widget _buildStatusCard() {
    final condition = _pet!.condition;
    final stage = _pet!.evolutionStage;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Level ${_pet!.level}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      stage.displayName,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColor.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getConditionColor(condition).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _getConditionColor(condition)),
                  ),
                  child: Text(
                    _getConditionText(condition),
                    style: TextStyle(
                      color: _getConditionColor(condition),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Experience bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Experience', style: TextStyle(fontSize: 12)),
                    Text(
                      '${_pet!.experience}/${_pet!.experienceToNextLevel}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: _pet!.experience / _pet!.experienceToNextLevel,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(AppColor.primary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPetDisplay() {
    final moodExpression = _petService.getPetMoodExpression(_pet!);
    
    return AnimatedBuilder(
      animation: _bounceAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _bounceAnimation.value),
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColor.primary.withOpacity(0.1),
              boxShadow: [
                BoxShadow(
                  color: AppColor.primary.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Pet emoji
                Text(
                  _pet!.type.emoji,
                  style: const TextStyle(fontSize: 100),
                ),
                // Mood expression
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      moodExpression,
                      style: const TextStyle(fontSize: 30),
                    ),
                  ),
                ),
                // Accessories
                if (_pet!.accessories.isNotEmpty)
                  ..._buildAccessories(),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildAccessories() {
    final accessories = _pet!.accessories
        .map((id) => ShopItems.getItemById(id))
        .whereType<ShopItemModel>()
        .toList();

    return accessories.asMap().entries.map((entry) {
      final index = entry.key;
      final accessory = entry.value;
      
      return Positioned(
        top: 10 + (index * 30.0),
        right: 10,
        child: Text(accessory.emoji, style: const TextStyle(fontSize: 25)),
      );
    }).toList();
  }

  Widget _buildStatsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildStatBar('Lapar', _pet!.hunger, Colors.orange, Icons.restaurant),
            const SizedBox(height: 8),
            _buildStatBar('Bahagia', _pet!.happiness, Colors.pink, Icons.favorite),
            const SizedBox(height: 8),
            _buildStatBar('Kesehatan', _pet!.health, Colors.green, Icons.favorite_border),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBar(String label, int value, Color color, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(label),
            const Spacer(),
            Text('$value/100', style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: value / 100,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _feedPet,
            icon: const Icon(Icons.restaurant),
            label: const Text('Beri Makan'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _playWithPet,
            icon: const Icon(Icons.sports_esports),
            label: const Text('Bermain'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    final lastFedDuration = DateTime.now().difference(_pet!.lastFed);
    final lastInteractionDuration = DateTime.now().difference(_pet!.lastInteraction);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informasi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Jenis', _pet!.type.displayName),
            _buildInfoRow('Tahap Evolusi', _pet!.evolutionStage.displayName),
            _buildInfoRow('Terakhir diberi makan', _formatDuration(lastFedDuration)),
            _buildInfoRow('Terakhir bermain', _formatDuration(lastInteractionDuration)),
            _buildInfoRow('Aksesoris', '${_pet!.accessories.length} item'),
            const SizedBox(height: 8),
            Text(
              _pet!.evolutionStage.description,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Color _getConditionColor(PetCondition condition) {
    switch (condition) {
      case PetCondition.excellent:
        return Colors.green;
      case PetCondition.good:
        return Colors.lightGreen;
      case PetCondition.okay:
        return Colors.orange;
      case PetCondition.poor:
        return Colors.deepOrange;
      case PetCondition.critical:
        return Colors.red;
    }
  }

  String _getConditionText(PetCondition condition) {
    switch (condition) {
      case PetCondition.excellent:
        return 'Sempurna';
      case PetCondition.good:
        return 'Baik';
      case PetCondition.okay:
        return 'Cukup';
      case PetCondition.poor:
        return 'Buruk';
      case PetCondition.critical:
        return 'Kritis';
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) return '${duration.inDays} hari lalu';
    if (duration.inHours > 0) return '${duration.inHours} jam lalu';
    if (duration.inMinutes > 0) return '${duration.inMinutes} menit lalu';
    return 'Baru saja';
  }
}
