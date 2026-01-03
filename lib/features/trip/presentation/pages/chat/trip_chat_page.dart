import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:temporal_zodiac/features/trip/domain/entities/trip.dart';
import 'package:temporal_zodiac/features/trip/presentation/providers/trip_provider.dart';
import 'package:temporal_zodiac/features/auth/presentation/providers/auth_provider.dart';

class TripChatPage extends StatefulWidget {
  final Trip trip;
  const TripChatPage({super.key, required this.trip});

  @override
  State<TripChatPage> createState() => _TripChatPageState();
}

class _TripChatPageState extends State<TripChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TripProvider>().listenToMessages(widget.trip.id);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    // context.read<TripProvider>().stopListeningToMessages(); // Can cause issues if context invalid
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthProvider>().currentUser;
    // Ensure we are listening if coming back? (InitState handles it)

    return Scaffold(
      appBar: AppBar(title: Text(widget.trip.name)),
      body: Column(
        children: [
          Expanded(
            child: Consumer<TripProvider>(
              builder: (context, provider, child) {
                final messages = provider.tripMessages;
                
                if (messages.isEmpty) {
                   return const Center(child: Text("No messages yet. Start the conversation!"));
                }
                
                return ListView.builder(
                  reverse: true,
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                     final msg = messages[index];
                     final isMe = msg.senderId == currentUser?.id;
                     
                     return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                           constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                           margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                           padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                           decoration: BoxDecoration(
                              color: isMe ? Theme.of(context).colorScheme.primary : Colors.grey[200],
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(16),
                                topRight: const Radius.circular(16),
                                bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
                                bottomRight: isMe ? Radius.zero : const Radius.circular(16),
                              ),
                           ),
                           child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                 if (!isMe) 
                                   Padding(
                                     padding: const EdgeInsets.only(bottom: 2.0),
                                     child: Text(msg.senderName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Theme.of(context).colorScheme.primary)),
                                   ),
                                 Text(msg.message, style: TextStyle(color: isMe ? Colors.white : Colors.black87)),
                                 const SizedBox(height: 2),
                                 Align(
                                   alignment: Alignment.bottomRight,
                                   child: Text(
                                     "${msg.timestamp.hour}:${msg.timestamp.minute.toString().padLeft(2, '0')}", 
                                     style: TextStyle(fontSize: 9, color: isMe ? Colors.white70 : Colors.black54)
                                   ),
                                 ),
                              ]
                           ),
                        ),
                     );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            color: Theme.of(context).cardColor,
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton(
                    heroTag: "trip_chat_send_fab",
                    mini: true,
                    elevation: 0,
                    child: const Icon(Icons.send),
                    onPressed: () {
                      final text = _messageController.text;
                      if (text.trim().isNotEmpty) {
                          context.read<TripProvider>().sendMessage(widget.trip.id, text, currentUser?.name ?? 'User');
                          _messageController.clear();
                      }
                    },
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
