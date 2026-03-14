import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../chat/pages/chat_page.dart';
import '../../correlation/pages/correlation_page.dart';
import '../../dashboard/bloc/dashboard_bloc.dart';
import '../../dashboard/pages/dashboard_page.dart';
import '../../summary/pages/summary_page.dart';
import '../widgets/app_bottom_nav_bar.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  void _onNavigate(int index) {
    final state = context.read<DashboardBloc>().state;
    
    // Trigger suggested questions when entering the Chat tab, but ONLY if they haven't been loaded yet
    if (index == 3) {
      if (state.lastFilePath != null && 
          state.suggestedQuestions.isEmpty && 
          !state.isLoading) {
        context.read<DashboardBloc>().add(GetSuggestedQuestions(state.lastFilePath!));
      }
    }
    
    // Trigger correlation analysis when entering the Correlation tab, but ONLY if it hasn't been loaded yet
    if (index == 2) {
      if (state.lastFilePath != null && 
          state.activeCorrelation == null && 
          !state.isLoading) {
        context.read<DashboardBloc>().add(GetCorrelation(state.lastFilePath!));
      }
    }
    
    setState(() {
      _currentIndex = index;
    });
  }

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      DashboardPage(onNavigateToSummary: _onNavigate),
      SummaryPage(onNavigateToCorrelation: () => _onNavigate(2)),
      CorrelationPage(onNavigateToChat: () => _onNavigate(3)),
      const ChatPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: KeyedSubtree(
          key: ValueKey<int>(_currentIndex),
          child: _screens[_currentIndex],
        ),
      ),
      floatingActionButton: Container(
        height: 72,
        width: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3B82F6).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () async {
            FilePickerResult? result = await FilePicker.platform.pickFiles(
              type: FileType.custom,
              allowedExtensions: ['csv'],
            );

            if (result != null) {
              final file = result.files.first;
              if (file.bytes != null && mounted) {
                context.read<DashboardBloc>().add(
                  UploadDataset(file.bytes!, file.name),
                );
                if (_currentIndex != 0) {
                  _onNavigate(0);
                }
              }
            }
          },
          backgroundColor: const Color(0xFF3B82F6),
          elevation: 0, // Elevation handled by Container shadow
          shape: const CircleBorder(),
          child: const Icon(LucideIcons.plus, color: Colors.white, size: 36),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavigate,
      ),
    );
  }
}
