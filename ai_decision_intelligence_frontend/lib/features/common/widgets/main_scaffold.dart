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
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      floatingActionButton: FloatingActionButton(
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
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(LucideIcons.plus, color: Colors.white, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavigate,
      ),
    );
  }
}
