import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:kavana_app/common/app_color.dart';
import 'package:kavana_app/common/info.dart';
import 'package:kavana_app/data/models/item_chat_model.dart';
import 'package:kavana_app/view/controllers/chat_ai_controller.dart';
import 'package:kavana_app/view/widget/custom_input.dart';

class ChatAIPage extends StatefulWidget {
  const ChatAIPage({super.key});

  static const routeName = '/chat-ai';

  @override
  State<ChatAIPage> createState() => _ChatAIPageState();
}

class _ChatAIPageState extends State<ChatAIPage> {
  final chatAIController = Get.put(ChatAIController());
  final promptController = TextEditingController();
  final scrollController = ScrollController();

  get curve => null;

  void scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOutCirc,
      );
    });
  }

  sendMessage() async {
    final messageFromUser = promptController.text;
    if (messageFromUser == '') {
      Info.failed('Prompt must be filled');
      return;
    }

    final responseAI = await chatAIController.sendMessage(messageFromUser);
    if (responseAI == null) {
      Info.failed('AI Not response. Check your API key and internet connection.');
    }

    promptController.clear();
    scrollDown();
  }

  @override
  void initState() {
    chatAIController.setupModel();
    super.initState();
  }

  @override
  void dispose() {
    ChatAIController.delete();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Gap(40),
          buildHeader(),
          Expanded(
            child: buildList(),
          ),
          buildInputChat(),
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
            'Chat AI',
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

  Widget buildList() {
    return Obx(() {
      final list = chatAIController.list;
      return ListView.builder(
        controller: scrollController,
        itemCount: list.length,
        padding: const EdgeInsets.all(10),
        itemBuilder: (context, index) {
          final itemChat = list[index];
          return buildItemChat(itemChat);
        },
      );
    });
  }

  Widget buildItemChat(ItemChatModel itemChat) {
    bool fromUser = itemChat.fromUser;
    Image? image = itemChat.image;
    String? text = itemChat.text;
    final maxWidth = MediaQuery.sizeOf(context).width * 0.8;
    return Column(
      crossAxisAlignment:
          fromUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if (image != null)
          Container(
            constraints: BoxConstraints(
              maxWidth: maxWidth,
              maxHeight: 300,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(width: 6, color: AppColor.secondary),
            ),
            margin: const EdgeInsets.only(bottom: 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: image,
            ),
          ),
        if (text != null)
          Container(
            constraints: BoxConstraints(maxWidth: maxWidth),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: fromUser ? AppColor.secondary : Colors.white,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            child: fromUser
                ? Text(
                    text,
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: AppColor.textTitle,
                    ),
                  )
                : MarkdownBody(data: text),
          ),
        const Gap(20),
      ],
    );
  }

  Widget buildInputChat() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        color: Colors.white,
      ),
      child: Obx(() {
        if (chatAIController.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        final xFile = chatAIController.image;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!chatAIController.noImage)
              Padding(
                padding: const EdgeInsets.all(8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(xFile.path),
                    fit: BoxFit.fitHeight,
                    height: 120,
                  ),
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: CustomInput(
                    controller: promptController,
                    hint: 'Input prompt...',
                    suffixIcon: 'assets/icons/image.png',
                    suffixOnTap: () => chatAIController.pickImage(),
                    maxLines: 1,
                  ),
                ),
                const Gap(16),
                FloatingActionButton(
                  onPressed: sendMessage,
                  backgroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(width: 2, color: AppColor.primary),
                  ),
                  child: const ImageIcon(
                    AssetImage('assets/icons/send.png'),
                    size: 24,
                    color: AppColor.primary,
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }
}