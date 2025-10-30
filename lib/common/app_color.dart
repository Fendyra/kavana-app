import 'package:flutter/material.dart';

class AppColor {
  // Core Colors (Berdasarkan tema kartu)
  static const primary = Color(0xFF5D8BCE); // Biru medium yang tenang
  static const secondary = Color(0xFFFFE57F); // Kuning cerah (dari smiley face)

  // Backgrounds/Surfaces
  static const surface = Color(0xFFF7F7F7); // Latar belakang kartu (abu-abu sangat muda)
  static const surfaceContainer = Color(0xFFFFFFFF); // Putih solid
  static const surfaceLightYellow = Color(0xFFFFFBE5); // Kuning pucat (dari pattern)
  static const surfaceLightBlue = Color(0xFFEAF1FA); // Biru sangat muda (tint dari primary)

  // Status Colors (Disimpan sebagai warna standar)
  static const error = Color(0xFFFF4D4D); // Merah cerah
  static const success = Color(0xFF34C759); // Hijau cerah
  static const warning = Color(0xFFFFE57F); // Kuning (sama dengan secondary)

  // Text Colors
  static const textTitle = Color(0xFF3A4B6A); // Biru tua/charcoal (untuk judul/teks utama)
  static const textBody = Color(0xFF5D8BCE); // Biru primary (untuk sub-teks/ikon)
  static const textHint = Color(0xFFB0C4DE); // Biru-abu muda (untuk teks petunjuk)
}

