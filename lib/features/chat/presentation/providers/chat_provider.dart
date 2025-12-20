import 'package:flutter/material.dart';
import 'package:temporal_zodiac/core/services/preferences_service.dart';
import 'package:temporal_zodiac/features/chat/domain/entities/chat_message.dart';
import 'package:temporal_zodiac/features/chat/domain/repositories/chat_repository.dart';
import 'package:uuid/uuid.dart';

class ChatProvider extends ChangeNotifier {
  final ChatRepository repository;
  final PreferencesService preferencesService;

  ChatProvider({
    required this.repository,
    required this.preferencesService,
  }) {
    _loadChatHistory();
  }
  
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;

  Future<void> _loadChatHistory() async {
    _isLoading = true;
    notifyListeners();
    try {
      final history = await preferencesService.getChatMessages();
      _messages.clear();
      _messages.addAll(history.map((json) => ChatMessage.fromJson(json)).toList());
      // Sort if needed, assuming saved in order but display is reversed.
      // If saved as a list, and we want newest first in UI:
      // If we save [_messages] which is reversed (newest first), then just loading it back is fine.
    } catch (e) {
      debugPrint("Error loading chat history: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveChatHistory() async {
    final history = _messages.map((msg) => msg.toJson()).toList();
    await preferencesService.saveChatMessages(history);
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = ChatMessage(
      id: const Uuid().v4(),
      text: text,
      role: MessageRole.user,
      timestamp: DateTime.now(),
    );

    _messages.insert(0, userMsg); // Add to start for reverse list
    _saveChatHistory(); // Save after user message
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
      _saveChatHistory(); // Save after AI response
    } catch (e) {
       final errorMsg = ChatMessage(
        id: const Uuid().v4(),
        text: "Sorry, I couldn't reach the server.",
        role: MessageRole.ai,
        timestamp: DateTime.now(),
      );
      _messages.insert(0, errorMsg);
      _saveChatHistory(); // Save error message too
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
