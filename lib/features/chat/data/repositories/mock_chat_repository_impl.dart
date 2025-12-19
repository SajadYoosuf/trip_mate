import 'package:temporal_zodiac/features/chat/domain/repositories/chat_repository.dart';

class MockChatRepositoryImpl implements ChatRepository {
  @override
  Future<String> sendMessage(String message) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network latency
    
    // Stateless LLM simulation: Basic keyword matching
    final lowerMsg = message.toLowerCase();
    
    if (lowerMsg.contains('places') || lowerMsg.contains('near')) {
      return "Here are some popular places nearby:\n1. Central Park\n2. The Daily Grind\n3. Ocean Beach\n\nWould you like more details on any of these?";
    } else if (lowerMsg.contains('chennai')) {
      return "In Chennai, you can visit Marina Beach, Kapaleeshwarar Temple, and Fort St. George. It's a vibrant city!";
    } else if (lowerMsg.contains('hello') || lowerMsg.contains('hi')) {
       return "Hello! I am Travel Mate. How can I assist you with your travel plans today?";
    } else {
      return "That sounds interesting! I can suggest places, itineraries, or travel tips. Just ask!";
    }
  }
}
