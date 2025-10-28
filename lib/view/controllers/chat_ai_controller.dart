import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kavana_app/common/constants.dart';
import 'package:kavana_app/common/logging.dart';
import 'package:kavana_app/data/models/item_chat_model.dart';

class ChatAIController extends GetxController {
  late final GenerativeModel _model;
  late final ChatSession _chatSession;

  final _list = <ItemChatModel>[].obs;
  List<ItemChatModel> get list => _list;

  final _loading = false.obs;
  bool get loading => _loading.value;

  final _image = XFile('').obs;
  XFile get image => _image.value;
  bool get noImage => image.path == '';

  pickImage() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedImage == null) return;

    _image.value = pickedImage;
  }

  setupModel() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: Constants.googleAIAPIkey,
    );
    _chatSession = _model.startChat();
  }

  Future<String?> sendMessage(String messageFromUser) async {
    _loading.value = true;

    try {
      Image? imageSelected = noImage
          ? null
          : Image.file(
              File(image.path),
              fit: BoxFit.fitHeight,
            );
      final itemChatUser = ItemChatModel(
        image: imageSelected,
        text: messageFromUser,
        fromUser: true,
      );
      _list.add(itemChatUser);

      final GenerateContentResponse responseAI;
      if (noImage) {
        final contentOnlyText = Content.text(messageFromUser);
        responseAI = await _chatSession.sendMessage(contentOnlyText);
      } else {
        Uint8List bytes = await image.readAsBytes();
        final contentWithImage = [
          Content.multi([
            TextPart(messageFromUser),
            DataPart(image.mimeType ?? 'image/jpeg', bytes),
          ])
        ];
        responseAI = await _model.generateContent(contentWithImage);
      }

      final messageFromAI = responseAI.text;
      final itemChatAI = ItemChatModel(
        image: null,
        text: messageFromAI,
        fromUser: false,
      );
      _list.add(itemChatAI);

      return messageFromAI;
    } catch (e) {
      fdLog.title(
        'Chat AI Controller - sendMessage',
        e.toString(),
      );
      return null;
    } finally {
      _loading.value = false;
      _image.value = XFile('');
    }
  }

  static delete() {
    Get.delete<ChatAIController>(force: true);
  }
}
