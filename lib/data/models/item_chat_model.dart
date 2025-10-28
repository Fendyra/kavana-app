import 'package:flutter/material.dart';

class ItemChatModel {
  final Image? image;
  final String? text;
  final bool fromUser;

  ItemChatModel({
    required this.image,
    required this.text,
    required this.fromUser,
  });
}
