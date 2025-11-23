import 'package:flutter/material.dart';
import 'package:kavana_app/common/app_color.dart';
import 'package:kavana_app/data/models/shop_item_model.dart';
import 'package:kavana_app/data/models/pet_model.dart';
import 'package:kavana_app/services/pet_service.dart';

class PetShopPage extends StatefulWidget {
  const PetShopPage({super.key});

  @override
  State<PetShopPage> createState() => _PetShopPageState();
}

class _PetShopPageState extends State<PetShopPage>
    with SingleTickerProviderStateMixin {
  final PetService _petService = PetService();
  late TabController _tabController;
  int _currency = 0;
  PetModel? _pet;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final currency = await _petService.getCurrency();
    final pet = await _petService.getPet();
    setState(() {
      _currency = currency;
      _pet = pet;
      _isLoading = false;
    });
  }

  Future<void> _purchaseItem(ShopItemModel item) async {
    if (_pet == null) {
      _showMessage('Hewan peliharaan tidak ditemukan');
      return;
    }

    // Confirm purchase
    final confirm = await _showConfirmDialog(item);
    if (!confirm) return;

    // Check if already owned (for accessories)
    if (item.type == ShopItemType.accessory) {
      if (_pet!.accessories.contains(item.id)) {
        _showMessage('Aksesoris sudah dimiliki!');
        return;
      }
    }

    // Check currency
    if (_currency < item.price) {
      _showMessage('Koin tidak cukup!');
      return;
    }

    // Purchase
    final success = await _petService.purchaseItem(_pet!, item);
    if (success) {
      await _loadData();
      _showMessage('${item.name} berhasil dibeli! ${item.emoji}');
      
      // Return to pet page if consumable item
      if (item.category == ShopItemCategory.consumable && mounted) {
        Navigator.pop(context);
      }
    } else {
      _showMessage('Gagal membeli item');
    }
  }

  Future<bool> _showConfirmDialog(ShopItemModel item) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Beli ${item.name}?'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(item.emoji, style: const TextStyle(fontSize: 50)),
                ),
                const SizedBox(height: 16),
                Text(item.description),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                _buildEffectsList(item.effects),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Harga:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.monetization_on,
                            color: Colors.amber, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          '${item.price}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Beli'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Widget _buildEffectsList(Map<String, int> effects) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Efek:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        const SizedBox(height: 4),
        ...effects.entries.map((entry) {
          final icon = _getEffectIcon(entry.key);
          final label = _getEffectLabel(entry.key);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Icon(icon, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '$label +${entry.value}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  IconData _getEffectIcon(String effect) {
    switch (effect) {
      case 'hunger':
        return Icons.restaurant;
      case 'happiness':
        return Icons.favorite;
      case 'health':
        return Icons.favorite_border;
      default:
        return Icons.star;
    }
  }

  String _getEffectLabel(String effect) {
    switch (effect) {
      case 'hunger':
        return 'Lapar';
      case 'happiness':
        return 'Bahagia';
      case 'health':
        return 'Kesehatan';
      default:
        return effect;
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Toko Hewan'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Makanan'),
            Tab(text: 'Obat'),
            Tab(text: 'Mainan'),
            Tab(text: 'Aksesoris'),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.amber),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.monetization_on,
                        color: Colors.amber, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      '$_currency',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildItemGrid(ShopItems.getItemsByType(ShopItemType.food)),
                _buildItemGrid(ShopItems.getItemsByType(ShopItemType.medicine)),
                _buildItemGrid(ShopItems.getItemsByType(ShopItemType.toy)),
                _buildItemGrid(ShopItems.getItemsByType(ShopItemType.accessory)),
              ],
            ),
    );
  }

  Widget _buildItemGrid(List<ShopItemModel> items) {
    if (items.isEmpty) {
      return const Center(
        child: Text('Tidak ada item'),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => _buildItemCard(items[index]),
    );
  }

  Widget _buildItemCard(ShopItemModel item) {
    final canAfford = _currency >= item.price;
    final isOwned = _pet?.accessories.contains(item.id) ?? false;

    return GestureDetector(
      onTap: isOwned ? null : () => _purchaseItem(item),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isOwned
                ? Colors.green
                : canAfford
                    ? AppColor.primary.withOpacity(0.3)
                    : Colors.grey[300]!,
            width: isOwned ? 2 : 1,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: isOwned
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.green.withOpacity(0.1),
                      Colors.green.withOpacity(0.05),
                    ],
                  )
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Emoji
                Text(
                  item.emoji,
                  style: const TextStyle(fontSize: 50),
                ),
                const SizedBox(height: 8),

                // Name
                Text(
                  item.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // Description
                Text(
                  item.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Effects
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  alignment: WrapAlignment.center,
                  children: item.effects.entries.take(2).map((entry) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${_getEffectLabel(entry.key)} +${entry.value}',
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  }).toList(),
                ),
                const Spacer(),

                // Price / Status
                if (isOwned)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Dimiliki',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: canAfford
                          ? AppColor.primary
                          : Colors.grey[400],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.monetization_on,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${item.price}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
