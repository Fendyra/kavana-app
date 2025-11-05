import 'package:kavana_app/common/constants.dart';
import 'package:flutter/material.dart';
import 'package:kavana_app/common/logging.dart';

class ChatAIPage extends StatefulWidget {
  const ChatAIPage({super.key});

  static const routeName = '/chat-ai';

  @override
  State<ChatAIPage> createState() => _ChatAIPageState();
}

class _ChatAIPageState extends State<ChatAIPage> {
  @override
  void initState() {
    fdLog.title('AI API KEY', Constants.googleAIAPIKey,);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}