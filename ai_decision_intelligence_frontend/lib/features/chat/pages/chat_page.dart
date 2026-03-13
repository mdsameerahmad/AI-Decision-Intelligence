import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../dashboard/bloc/dashboard_bloc.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isStrategyMode = false;

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'AI Chatbot',
          style: GoogleFonts.ibmPlexSans(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.trash2, color: Color(0xFF3B82F6), size: 20),
            onPressed: () {
              context.read<DashboardBloc>().add(ClearChat());
            },
            tooltip: 'Clear Chat',
          ),
        ],
      ),
      body: BlocConsumer<DashboardBloc, DashboardState>(
        listener: (context, state) {
          if (state.chatHistory.isNotEmpty) {
            _scrollToBottom();
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              Expanded(
                child: state.chatHistory.isEmpty && state.suggestedQuestions.isEmpty
                    ? _buildEmptyChatView()
                    : _buildChatView(state),
              ),
              _buildInputArea(context, state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyChatView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.bot, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Ask me anything about your data',
            style: GoogleFonts.ibmPlexSans(fontSize: 18, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildChatView(DashboardState state) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16.0),
      itemCount: state.chatHistory.length + (state.suggestedQuestions.isNotEmpty ? 1 : 0),
      itemBuilder: (context, index) {
        if (state.suggestedQuestions.isNotEmpty && index == 0) {
          return _buildSuggestedQuestions(context, state.suggestedQuestions);
        }
        final chatIndex = state.suggestedQuestions.isNotEmpty ? index - 1 : index;
        final message = state.chatHistory[chatIndex];
        return _buildChatMessage(context, message['sender']!, message['message']!);
      },
    );
  }

  Widget _buildSuggestedQuestions(BuildContext context, List<String> questions) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Suggested Questions',
            style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: questions.map((q) => ActionChip(
              label: Text(q, style: const TextStyle(fontSize: 12)),
              onPressed: () {
                context.read<DashboardBloc>().add(AskChatbot(q));
              },
              backgroundColor: Colors.grey[100],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildChatMessage(BuildContext context, String sender, String message) {
    final isUser = sender == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isUser)
            IconButton(
              icon: Icon(LucideIcons.copy, size: 14, color: Colors.grey[400]),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: message));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Copied to clipboard')),
                );
              },
            ),
          Flexible(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? const Color(0xFF3B82F6) : Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: SelectableText(
                message,
                style: GoogleFonts.ibmPlexSans(
                  color: isUser ? Colors.white : Colors.black87,
                  height: 1.5,
                ),
              ),
            ),
          ),
          if (isUser)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(LucideIcons.copy, size: 14, color: Colors.grey[400]),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: message));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copied to clipboard')),
                    );
                  },
                  tooltip: 'Copy',
                ),
                IconButton(
                  icon: Icon(LucideIcons.rotateCw, size: 14, color: Colors.grey[400]),
                  onPressed: () {
                    // Determine if this was a strategy request or a regular chat question
                    // Simple heuristic: check if it starts with "Generate a strategic plan for:"
                    if (message.startsWith('Generate a strategic plan for: ')) {
                      final problem = message.replaceFirst('Generate a strategic plan for: ', '');
                      context.read<DashboardBloc>().add(GenerateActionPlan(problem));
                    } else {
                      context.read<DashboardBloc>().add(AskChatbot(message));
                    }
                  },
                  tooltip: 'Retry',
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildInputArea(BuildContext context, DashboardState state) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              LucideIcons.lightbulb,
              color: _isStrategyMode ? const Color(0xFF3B82F6) : Colors.grey[400],
            ),
            onPressed: () {
              setState(() {
                _isStrategyMode = !_isStrategyMode;
              });
            },
            tooltip: 'Strategy Planner Mode',
          ),
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: _isStrategyMode ? 'Describe your problem for a strategy plan...' : 'Type your question...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: _isStrategyMode 
                    ? const BorderSide(color: Color(0xFF3B82F6), width: 1)
                    : BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: _isStrategyMode 
                    ? const BorderSide(color: Color(0xFF3B82F6), width: 1)
                    : BorderSide.none,
                ),
                filled: true,
                fillColor: _isStrategyMode ? const Color(0xFF3B82F6).withOpacity(0.05) : Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          const SizedBox(width: 8),
          state.isLoading
              ? const CircularProgressIndicator(color: Color(0xFF3B82F6))
              : IconButton(
                  icon: const Icon(LucideIcons.send, color: Color(0xFF3B82F6)),
                  onPressed: () {
                    if (_textController.text.isNotEmpty) {
                      if (_isStrategyMode) {
                        context.read<DashboardBloc>().add(GenerateActionPlan(_textController.text));
                        setState(() {
                          _isStrategyMode = false;
                        });
                      } else {
                        context.read<DashboardBloc>().add(AskChatbot(_textController.text));
                      }
                      _textController.clear();
                    }
                  },
                ),
        ],
      ),
    );
  }
}
