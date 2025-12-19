import 'package:equatable/equatable.dart';

enum MessageRole { user, ai }

class ChatMessage extends Equatable {
  final String id;
  final String text;
  final MessageRole role;
  final DateTime timestamp;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.role,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, text, role, timestamp];
}
