import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kavana_app/common/constants.dart';
import 'package:kavana_app/common/logging.dart';
import 'package:kavana_app/core/api.dart';
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

  Future<void> validateApiKey() async {
    try {
      final testModel = GenerativeModel(
        model: API.geminiModel,
        apiKey: Constants.googleAIAPIKey,
      );
      
      // Try a simple test message
      final content = [Content.text('Test connection')];
      await testModel.generateContent(content);
      
      fdLog.title('Chat AI - validateApiKey', 'API key is valid and working');
      return;
    } catch (e) {
      fdLog.title('Chat AI - validateApiKey', 'Error validating API key: $e');
      throw Exception('API key validation failed: $e');
    }
  }

  setupModel() async {
    try {
      fdLog.title('Chat AI Controller - setupModel', 'Initializing with API key: ${Constants.googleAIAPIKey.substring(0, 10)}...');
      
      // Validate API key first
      await validateApiKey();
      
      // Initialize model based on whether we're using vision features
      _model = GenerativeModel(
        model: API.geminiModel,
        apiKey: Constants.googleAIAPIKey,
      );
      _chatSession = _model.startChat();
      
      fdLog.title('Chat AI Controller - setupModel', 'Model initialized successfully');
    } catch (e, stackTrace) {
      fdLog.title('Chat AI Controller - setupModel Error', 'Error: $e\nStack trace: $stackTrace');
      // Add error to chat list so user can see it
      _list.add(ItemChatModel(
        image: null,
        text: 'Terjadi error saat inisialisasi: $e\n\nSilakan cek API key dan pastikan sudah diaktifkan di Google Cloud Console.',
        fromUser: false,
      ));
      rethrow;
    }
  }

  Future<String?> sendMessage(String messageFromUser) async {
    _loading.value = true;

    try {
      fdLog.title('Chat AI - sendMessage', 'Starting with message: $messageFromUser');
      
      // Add user message to chat
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

      // Prepare AI response
      final GenerateContentResponse responseAI;
      if (noImage) {
        fdLog.title('Chat AI - sendMessage', 'Sending text-only message');
        final contentOnlyText = Content.text(messageFromUser);
        responseAI = await _chatSession.sendMessage(contentOnlyText);
      } else {
        fdLog.title('Chat AI - sendMessage', 'Sending message with image');
        // Image chat requires gemini-pro-vision
        final visionModel = GenerativeModel(
          model: API.geminiVisionModel,
          apiKey: Constants.googleAIAPIKey,
        );
        
        Uint8List bytes = await image.readAsBytes();
        fdLog.title('Chat AI - sendMessage', 'Image loaded, size: ${bytes.length} bytes');
        
        final contentWithImage = [
          Content.multi([
            TextPart(messageFromUser),
            DataPart('image/jpeg', bytes),
          ])
        ];
        responseAI = await visionModel.generateContent(contentWithImage);
      }

      // Process AI response
      final messageFromAI = responseAI.text;
      if (messageFromAI != null) {
        fdLog.title('Chat AI - sendMessage', 'Received response: ${messageFromAI.substring(0, math.min(50, messageFromAI.length))}...');
      } else {
        fdLog.title('Chat AI - sendMessage', 'Warning: Received null response from AI');
      }
      
      final itemChatAI = ItemChatModel(
        image: null,
        text: messageFromAI ?? "Maaf, tidak ada respons dari AI",
        fromUser: false,
      );
      _list.add(itemChatAI);

      return messageFromAI;
    } catch (e, stackTrace) {
      fdLog.title(
        'Chat AI Controller - sendMessage Error',
        'Error: $e\nStack trace: $stackTrace',
      );
      
      // Add error message to chat
      final itemChatError = ItemChatModel(
        image: null,
        text: "Maaf, terjadi error: ${e.toString()}",
        fromUser: false,
      );
      _list.add(itemChatError);
      
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
