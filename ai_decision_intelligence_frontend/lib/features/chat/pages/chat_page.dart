import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../dashboard/bloc/dashboard_bloc.dart';

class ChatPage extends StatefulWidget {
  final VoidCallback? onBack;
  const ChatPage({super.key, this.onBack});

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
            boxShadow: AppTheme.softShadow,
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: false,
            toolbarHeight: 70,
            title: Row(
              children: [
                if (widget.onBack != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: IconButton(
                      onPressed: widget.onBack,
                      icon: const Icon(LucideIcons.arrowLeft, color: AppTheme.textMain),
                    ),
                  ),
                if (ResponsiveHelper.isMobile(context) && widget.onBack == null) ...[
                  Image.asset(
                    'assets/images/logo.png',
                    height: 32,
                    errorBuilder: (context, e, s) => const Icon(
                      LucideIcons.bot,
                      color: AppTheme.primaryBlue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Data Assistant',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        letterSpacing: -0.5,
                        color: AppTheme.textMain,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppTheme.successGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Online & Ready',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              _buildAppBarAction(
                LucideIcons.history,
                AppTheme.primaryBlue,
                'History',
                () async {
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
              ),
              _buildAppBarAction(
                LucideIcons.trash2,
                AppTheme.errorRed,
                'Clear',
                () => context.read<DashboardBloc>().add(ClearChat()),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: AppTheme.backgroundLight,
        ),
        child: BlocConsumer<DashboardBloc, DashboardState>(
          listener: (context, state) {
            if (state.chatHistory.isNotEmpty) {
              _scrollToBottom();
            }
          },
          builder: (context, state) {
            return ResponsiveHelper.constrainedContent(
              Column(
                children: [
                  Expanded(
                    child: state.chatHistory.isEmpty &&
                            state.suggestedQuestions.isEmpty
                        ? _buildEmptyChatView()
                        : _buildChatView(state),
                  ),
                  _buildInputArea(context, state),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppBarAction(
      IconData icon, Color color, String tooltip, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.1)),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
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
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 20.0),
      itemCount: (state.suggestedQuestions.isNotEmpty ? 1 : 0) + state.chatHistory.length,
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
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'Suggested Questions',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: AppTheme.textMain,
                letterSpacing: -0.3,
              ),
            ),
          ),
          ...questions.map((q) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              onTap: () => context.read<DashboardBloc>().add(AskChatbot(q)),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.1)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6).withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(LucideIcons.sparkles, size: 14, color: Color(0xFF3B82F6)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        q,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppTheme.textMain.withOpacity(0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Icon(LucideIcons.chevronRight, size: 16, color: Colors.grey[400]),
                  ],
                ),
              ),
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildChatMessage(BuildContext context, String sender, String message) {
    final isUser = sender == 'user';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isUser) ...[
                _buildAssistantAvatar(),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    color: isUser ? AppTheme.primaryBlue : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isUser ? 20 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isUser ? 0.1 : 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: isUser ? null : Border.all(color: Colors.grey[100]!),
                  ),
                  child: SelectableText(
                    message,
                    style: GoogleFonts.inter(
                      color: isUser ? Colors.white : AppTheme.textMain,
                      fontSize: 14,
                      height: 1.5,
                      fontWeight: isUser ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
              if (isUser) ...[
                const SizedBox(width: 8),
                _buildUserAvatar(),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: EdgeInsets.only(
              left: isUser ? 0 : 48,
              right: isUser ? 48 : 0,
            ),
            child: Text(
              isUser ? 'You' : 'AI Assistant',
              style: GoogleFonts.inter(
                fontSize: 10,
                color: Colors.grey[400],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssistantAvatar() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF3B82F6),
            const Color(0xFF3B82F6).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(LucideIcons.bot, color: Colors.white, size: 14),
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(LucideIcons.user, color: Color(0xFF3B82F6), size: 14),
    );
  }

  Widget _buildInputArea(BuildContext context, DashboardState state) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                LucideIcons.lightbulb,
                size: 20,
                color: _isStrategyMode ? const Color(0xFF3B82F6) : Colors.grey[400],
              ),
              onPressed: () {
                setState(() {
                  _isStrategyMode = !_isStrategyMode;
                });
              },
            ),
            Expanded(
              child: TextField(
                controller: _textController,
                style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textMain),
                decoration: InputDecoration(
                  hintText: _isStrategyMode ? 'Strategy mode...' : 'Ask your data...',
                  hintStyle: GoogleFonts.inter(color: Colors.grey[400], fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ),
            if (state.isLoading)
              const Padding(
                padding: EdgeInsets.all(12.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF3B82F6)),
                ),
              )
            else
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFF3B82F6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.send, color: Colors.white, size: 16),
                ),
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
      ),
    );
  }
}
