import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:kavana_app/common/app_color.dart';

class CurrencyConverterPage extends StatefulWidget {
  const CurrencyConverterPage({super.key});

  static const routeName = '/currency-converter';

  @override
  State<CurrencyConverterPage> createState() => _CurrencyConverterPageState();
}

class _CurrencyConverterPageState extends State<CurrencyConverterPage> {
  late double totalSavings;
  String selectedCurrency = 'USD';

  // Exchange rates (you can update these with real API)
  final Map<String, Map<String, dynamic>> exchangeRates = {
    'USD': {'rate': 0.000063, 'symbol': '\$', 'flag': '🇺🇸', 'name': 'US Dollar'},
    'EUR': {'rate': 0.000059, 'symbol': '€', 'flag': '🇪🇺', 'name': 'Euro'},
    'GBP': {'rate': 0.000051, 'symbol': '£', 'flag': '🇬🇧', 'name': 'Pound Sterling'},
  };

  double getConvertedAmount() {
    return totalSavings * exchangeRates[selectedCurrency]!['rate'];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    totalSavings = ModalRoute.of(context)!.settings.arguments as double;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Gap(50),
          buildHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Gap(20),
                buildSourceAmount(),
                const Gap(30),
                buildConversionIcon(),
                const Gap(30),
                buildConvertedAmount(),
                const Gap(40),
                buildCurrencyList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const ImageIcon(
              AssetImage('assets/icons/arrow_back.png'),
              size: 24,
              color: AppColor.primary,
            ),
          ),
          const Text(
            'Currency Converter',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColor.primary,
            ),
          ),
          const IconButton(
            onPressed: null,
            icon: ImageIcon(
              AssetImage('assets/icons/add_circle.png'),
              size: 24,
              color: Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSourceAmount() {
    final formattedAmount = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(totalSavings);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [AppColor.primary, AppColor.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '🇮🇩',
                style: TextStyle(fontSize: 32),
              ),
              const Gap(12),
              const Text(
                'Indonesian Rupiah',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const Gap(16),
          Text(
            formattedAmount,
            style: const TextStyle(
              fontSize: 32,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildConversionIcon() {
    return const Center(
      child: Icon(
        Icons.swap_vert,
        size: 48,
        color: AppColor.primary,
      ),
    );
  }

  Widget buildConvertedAmount() {
    final convertedAmount = getConvertedAmount();
    final currencyData = exchangeRates[selectedCurrency]!;
    final symbol = currencyData['symbol'];
    final flag = currencyData['flag'];
    final name = currencyData['name'];

    final formattedAmount = NumberFormat.currency(
      locale: 'en_US',
      symbol: '$symbol ',
      decimalDigits: 2,
    ).format(convertedAmount);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        border: Border.all(color: AppColor.success, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                flag,
                style: const TextStyle(fontSize: 32),
              ),
              const Gap(12),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColor.textBody,
                ),
              ),
            ],
          ),
          const Gap(16),
          Text(
            formattedAmount,
            style: const TextStyle(
              fontSize: 32,
              color: AppColor.success,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCurrencyList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Currency',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColor.textTitle,
          ),
        ),
        const Gap(16),
        ...exchangeRates.entries.map((entry) {
          final currency = entry.key;
          final data = entry.value;
          final isSelected = selectedCurrency == currency;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCurrency = currency;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: isSelected
                    ? AppColor.primary.withOpacity(0.1)
                    : Colors.white,
                border: Border.all(
                  color: isSelected ? AppColor.primary : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Text(
                    data['flag'],
                    style: const TextStyle(fontSize: 32),
                  ),
                  const Gap(16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currency,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? AppColor.primary
                                : AppColor.textTitle,
                          ),
                        ),
                        Text(
                          data['name'],
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColor.textBody,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      Icons.check_circle,
                      color: AppColor.primary,
                      size: 24,
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}