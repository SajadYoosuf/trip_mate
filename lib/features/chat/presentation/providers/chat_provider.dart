import 'package:flutter/material.dart';
import 'package:temporal_zodiac/features/chat/domain/entities/chat_message.dart';
import 'package:temporal_zodiac/features/chat/domain/repositories/chat_repository.dart';
import 'package:uuid/uuid.dart';

class ChatProvider extends ChangeNotifier {
  final ChatRepository repository;

  ChatProvider({required this.repository});
  
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = ChatMessage(
      id: const Uuid().v4(),
      text: text,
      role: MessageRole.user,
      timestamp: DateTime.now(),
    );

    _messages.insert(0, userMsg); // Add to start for reverse list
    _isLoading = true;
    notifyListeners();

    try {
      final responseText = await repository.sendMessage(text);
      final aiMsg = ChatMessage(
        id: const Uuid().v4(),
        text: responseText,
        role: MessageRole.ai,
        timestamp: DateTime.now(),
      );
      _messages.insert(0, aiMsg);
    } catch (e) {
       final errorMsg = ChatMessage(
        id: const Uuid().v4(),
        text: "Sorry, I couldn't reach the server.",
        role: MessageRole.ai,
        timestamp: DateTime.now(),
      );
      _messages.insert(0, errorMsg);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
