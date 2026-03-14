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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3B82F6).withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: false,
            toolbarHeight: 70,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(LucideIcons.bot,
                      color: Color(0xFF3B82F6), size: 24),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Chatbot',
                      style: GoogleFonts.ibmPlexSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'Smart AI Assistant',
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Tooltip(
                  message: 'Chat History',
                  child: InkWell(
                    onTap: () async {
                      final repo = context.read<DashboardBloc>().repository;
                      try {
                        final list = await repo.getChatHistory();
                        _showHistoryModalWithList(context, list);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to load history: $e')),
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6).withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.1)),
                      ),
                      child: const Icon(
                        LucideIcons.history,
                        color: Color(0xFF3B82F6),
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Tooltip(
                  message: 'Clear Chat',
                  child: InkWell(
                    onTap: () => context.read<DashboardBloc>().add(ClearChat()),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.redAccent.withOpacity(0.1)),
                      ),
                      child: const Icon(
                        LucideIcons.trash2,
                        color: Colors.redAccent,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF3B82F6).withOpacity(0.08),
              Colors.white,
            ],
          ),
        ),
        child: BlocConsumer<DashboardBloc, DashboardState>(
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

  void _showHistoryModalWithList(BuildContext context, List<dynamic> list) {
    // Build session list from history metadata (do not alter current chat view)
    final sessions = <Map<String, String>>[];
    for (final item in list) {
      final ds = item['dataset'] ?? '';
      final title = (item['session_title']?.toString() ?? '').trim();
      final datasetPath = (item['dataset_path']?.toString() ?? ds).trim();
      if (ds.isEmpty && title.isEmpty) continue;
      final key = '${datasetPath}|$title';
      if (!sessions.any((s) => s['key'] == key)) {
        sessions.add({
          'key': key,
          'dataset': datasetPath,
          'title': title.isEmpty ? 'Untitled Chat' : title,
        });
      }
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, controller) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Container(
                    height: 4,
                    width: 48,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.history, color: Color(0xFF3B82F6)),
                      const SizedBox(width: 8),
                      Text(
                        'Chat History',
                        style: GoogleFonts.ibmPlexSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    controller: controller,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    itemCount: sessions.length,
                    itemBuilder: (context, index) {
                      final item = sessions[index];
                      final datasetPath = item['dataset'] ?? '';
                      final datasetName = datasetPath.split('/').isNotEmpty ? datasetPath.split('/').last : datasetPath;
                      final title = item['title'] ?? 'Untitled Chat';
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: ListTile(
                          leading: const Icon(LucideIcons.folder, color: Color(0xFF3B82F6)),
                          title: Text(
                            title,
                            style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            datasetName.isEmpty ? 'General' : datasetName,
                            style: GoogleFonts.ibmPlexSans(color: Colors.grey[600]),
                          ),
                          trailing: const Icon(LucideIcons.chevronRight, color: Colors.grey),
                          onTap: () {
                            context.read<DashboardBloc>().add(
                              SelectChatSession(datasetPath: datasetPath.isEmpty ? null : datasetPath, sessionTitle: title),
                            );
                            Navigator.pop(context);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildChatView(DashboardState state) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 180.0),
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
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
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
                style: GoogleFonts.ibmPlexSans(fontSize: 15),
                decoration: InputDecoration(
                  hintText: _isStrategyMode ? 'Describe problem for strategy...' : 'Type your question...',
                  hintStyle: GoogleFonts.ibmPlexSans(color: Colors.grey[400], fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ),
            state.isLoading
                ? const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF3B82F6)),
                    ),
                  )
                : Container(
                    margin: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFF3B82F6),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(LucideIcons.send, color: Colors.white, size: 18),
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
                  ),
          ],
        ),
      ),
    );
  }
}
