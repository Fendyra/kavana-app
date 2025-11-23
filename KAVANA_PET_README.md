# Kavana Pet - Dokumentasi Integrasi

## Deskripsi Fitur
Kavana Pet adalah sistem gamifikasi virtual companion yang terintegrasi dengan produktivitas pengguna. Hewan peliharaan akan tumbuh, berevolusi, dan bereaksi berdasarkan aktivitas pengguna dalam aplikasi.

## Struktur File

### Models
- `lib/data/models/pet_model.dart` - Model data untuk pet dengan stats, evolution, dan kondisi
- `lib/data/models/shop_item_model.dart` - Model untuk item shop (makanan, obat, mainan, aksesoris)

### Services
- `lib/services/pet_service.dart` - Service utama untuk mengelola pet logic
- `lib/services/pet_integration_helper.dart` - Helper untuk integrasi dengan fitur lain

### Pages
- `lib/view/pages/pet/pet_page.dart` - Halaman utama pet dengan animasi dan interaksi
- `lib/view/pages/pet/create_pet_page.dart` - Halaman membuat pet baru
- `lib/view/pages/pet/pet_shop_page.dart` - Halaman toko untuk membeli item

### Widgets
- `lib/view/widget/pet_mini_widget.dart` - Widget mini pet untuk ditampilkan di home

## Fitur Utama

### 1. Pet Stats System
Pet memiliki 3 stat utama yang menurun seiring waktu:
- **Hunger (Lapar)**: Menurun 3 poin per jam
- **Happiness (Bahagia)**: Menurun 2 poin per jam  
- **Health (Kesehatan)**: Menurun jika Hunger atau Happiness < 20

### 2. Evolution System
Pet berevolusi berdasarkan level:
- Level 1-4: **Baby** - Baru lahir
- Level 5-9: **Rookie** - Mulai tumbuh
- Level 10-14: **Champion** - Kuat dan sehat
- Level 15-19: **Ultimate** - Sangat berkembang
- Level 20+: **Master** - Tingkat tertinggi

### 3. Currency System
- Currency (koin) didapat dari tabungan: 1000 tabungan = 1 koin
- Digunakan untuk membeli item di shop
- Bisa ditambahkan sebagai reward dari menyelesaikan task

### 4. Shop System
**Makanan:**
- Makanan Dasar (10 koin): +20 Hunger, +5 Health
- Makanan Premium (25 koin): +40 Hunger, +15 Health, +10 Happiness
- Makanan Super (50 koin): +60 Hunger, +25 Health, +20 Happiness
- Buah Segar (15 koin): +15 Hunger, +20 Health
- Kue Spesial (30 koin): +25 Hunger, +30 Happiness

**Obat:**
- Obat Dasar (20 koin): +30 Health
- Vitamin (35 koin): +50 Health, +10 Hunger

**Mainan:**
- Bola Mainan (15 koin): +25 Happiness
- Boneka (25 koin): +40 Happiness, +5 Health

**Aksesoris (Permanent):**
- Topi Keren (100 koin): +10 Happiness
- Kacamata (80 koin): +8 Happiness
- Kalung (120 koin): +12 Happiness
- Pita (60 koin): +7 Happiness
- Mahkota (200 koin): +20 Happiness

## Integrasi dengan Sistem Lain

### 1. Integrasi dengan Mood System

Mood pengguna mempengaruhi happiness pet. Sudah terintegrasi di:
- `lib/view/pages/mood/choose_mood_page.dart`

```dart
// Contoh yang sudah diimplementasikan
final mood = MoodModel(
  level: chooseMoodController.level,
  createdAt: DateTime.now(),
);
PetIntegrationHelper.updatePetFromMood(mood);
```

Mapping mood ke happiness:
- Mood 5 (Very Happy): +20 Happiness
- Mood 4 (Happy): +10 Happiness
- Mood 3 (Neutral): +5 Happiness
- Mood 2 (Sad): -5 Happiness
- Mood 1 (Very Sad): -10 Happiness

### 2. Integrasi dengan Savings System

Total tabungan dikonversi menjadi koin pet. Sudah terintegrasi di:
- `lib/view/pages/finance/add_savings_page.dart`

```dart
// Contoh yang sudah diimplementasikan
final financeController = Get.find<FinanceController>();
if (financeController.state.totalSavings > 0) {
  PetIntegrationHelper.updateCurrencyFromSavings(
    financeController.state.totalSavings,
  );
}
```

### 3. Integrasi dengan Agenda System (PERLU DITAMBAHKAN)

Untuk memberikan reward ketika agenda selesai, tambahkan kode berikut di tempat agenda di-complete:

```dart
// Tambahkan di bagian dimana agenda berhasil di-complete
import 'package:kavana_app/services/pet_integration_helper.dart';

// Setelah agenda berhasil di-complete:
PetIntegrationHelper.rewardPetExperience(20); // +20 XP
PetIntegrationHelper.rewardPetCurrency(5);    // +5 koin
```

**Saran reward:**
- Agenda biasa: 20 XP, 5 koin
- Agenda penting: 30 XP, 10 koin
- Agenda mendesak: 50 XP, 15 koin

### 4. Daily Bonus (OPTIONAL - PERLU DITAMBAHKAN)

Tambahkan di login atau splash page untuk memberikan bonus harian:

```dart
import 'package:kavana_app/services/pet_integration_helper.dart';

// Saat user login atau buka app
PetIntegrationHelper.rewardDailyBonus(); // +10 XP, +5 koin
```

## Cara Mengakses Pet Page

### 1. Melalui Home Fragment
Pet mini widget sudah ditambahkan di `lib/view/pages/fragments/home_fragment.dart`
User bisa tap widget untuk masuk ke Pet Page.

### 2. Direct Navigation
```dart
Navigator.pushNamed(context, PetPage.routeName);
// atau
Navigator.pushNamed(context, '/pet');
```

## API Helper Methods

### PetIntegrationHelper Methods

```dart
// Update pet happiness berdasarkan mood
await PetIntegrationHelper.updatePetFromMood(MoodModel mood);

// Update currency dari total savings
await PetIntegrationHelper.updateCurrencyFromSavings(double totalSavings);

// Berikan experience reward
await PetIntegrationHelper.rewardPetExperience(int experience);

// Berikan currency reward
await PetIntegrationHelper.rewardPetCurrency(int coins);

// Bonus harian
await PetIntegrationHelper.rewardDailyBonus();

// Cek apakah pet butuh perhatian
bool needsAttention = await PetIntegrationHelper.doesPetNeedAttention();
```

## Penyimpanan Data

Data pet disimpan menggunakan SharedPreferences dengan key:
- `user_pet` - Data pet
- `pet_currency` - Jumlah koin
- `pet_last_update` - Timestamp terakhir update stats

## Tips untuk Pengembangan Lebih Lanjut

1. **Notifikasi**: Tambahkan notifikasi ketika pet butuh perhatian
2. **Leaderboard**: Buat leaderboard untuk level pet tertinggi
3. **Animasi**: Tambahkan lebih banyak animasi interaktif
4. **Sound Effects**: Tambahkan sound ketika memberi makan atau bermain
5. **Multiple Pets**: Izinkan user memiliki lebih dari satu pet
6. **Pet Customization**: Tambahkan warna atau pattern untuk pet
7. **Mini Games**: Tambahkan mini game untuk interaksi dengan pet
8. **Social Features**: Biarkan user berbagi pet mereka
9. **Seasonal Events**: Event khusus dengan item terbatas
10. **Achievement System**: Badge untuk milestone tertentu

## Dependencies yang Digunakan

- `shared_preferences` - Untuk penyimpanan lokal
- `flutter/material.dart` - UI components
- Tidak ada dependency eksternal tambahan yang diperlukan

## Troubleshooting

### Pet tidak muncul
- Pastikan user sudah membuat pet melalui CreatePetPage
- Cek apakah SharedPreferences berfungsi dengan baik

### Currency tidak update
- Pastikan FinanceController sudah di-initialize
- Cek konversi: 1000 tabungan = 1 koin

### Stats menurun terlalu cepat
- Stats menurun setiap jam: Hunger -3, Happiness -2
- Adjust nilai di `PetService._updatePetStats()` jika perlu

## Contoh Flow Lengkap

1. User membuka app → PetMiniWidget muncul di home
2. User tap PetMiniWidget → Navigasi ke PetPage
3. Jika belum ada pet → Tampilkan CreatePetPage
4. User membuat pet → Pet disimpan dan ditampilkan
5. User pilih mood → Pet happiness update
6. User menabung → Pet currency update  
7. User complete agenda → Pet dapat XP dan koin
8. User beli item di shop → Pet stats meningkat
9. Pet level up → Evolusi ke stage berikutnya
10. Pet butuh perhatian → Indikator merah muncul

## Kesimpulan

Sistem Kavana Pet memberikan gamifikasi yang menyenangkan untuk meningkatkan engagement dan produktivitas pengguna. Sistem ini dirancang modular sehingga mudah untuk dikembangkan dan diintegrasikan dengan fitur-fitur baru.
