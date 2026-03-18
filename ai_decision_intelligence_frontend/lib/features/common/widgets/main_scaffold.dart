import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/utils/responsive_helper.dart';
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
        context
            .read<DashboardBloc>()
            .add(GetSuggestedQuestions(state.lastFilePath!));
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
      ChatPage(onBack: () => _onNavigate(0)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsiveHelper.isMobile(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          if (!isMobile)
            NavigationRail(
              selectedIndex: _currentIndex,
              onDestinationSelected: _onNavigate,
              labelType: NavigationRailLabelType.all,
              backgroundColor: Colors.white,
              selectedIconTheme: const IconThemeData(color: Color(0xFF3B82F6)),
              unselectedIconTheme: IconThemeData(color: Colors.grey[400]),
              selectedLabelTextStyle: const TextStyle(
                color: Color(0xFF3B82F6),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              unselectedLabelTextStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
              ),
              leading: Column(
                children: [
                  const SizedBox(height: 20),
                  Image.asset(
                    'assets/images/logo.png',
                    height: 40,
                    width: 40,
                    errorBuilder: (context, error, stackTrace) => Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(LucideIcons.brainCircuit,
                          color: Color(0xFF3B82F6), size: 32),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSideFab(),
                  const SizedBox(height: 20),
                ],
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(LucideIcons.layoutDashboard),
                  label: Text('Dashboard'),
                ),
                NavigationRailDestination(
                  icon: Icon(LucideIcons.fileText),
                  label: Text('Summary'),
                ),
                NavigationRailDestination(
                  icon: Icon(LucideIcons.barChart2),
                  label: Text('Correlation'),
                ),
                NavigationRailDestination(
                  icon: Icon(LucideIcons.bot),
                  label: Text('AI Chat'),
                ),
              ],
            ),
          if (!isMobile) VerticalDivider(thickness: 1, width: 1, color: Colors.grey[100]),
          Expanded(
            child: AnimatedSwitcher(
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
          ),
        ],
      ),
      floatingActionButton: (isMobile && _currentIndex != 3) ? _buildBottomFab() : null,
      floatingActionButtonLocation: isMobile ? FloatingActionButtonLocation.centerDocked : null,
      bottomNavigationBar: (isMobile && _currentIndex != 3)
          ? AppBottomNavBar(
              currentIndex: _currentIndex,
              onTap: _onNavigate,
            )
          : null,
    );
  }

  Widget _buildBottomFab() {
    return Container(
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
        onPressed: _onFabPressed,
        backgroundColor: const Color(0xFF3B82F6),
        elevation: 0,
        shape: const CircleBorder(),
        child: const Icon(LucideIcons.plus, color: Colors.white, size: 36),
      ),
    );
  }

  Widget _buildSideFab() {
    return Tooltip(
      message: 'Upload New Dataset',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _onFabPressed,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3B82F6).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(LucideIcons.plus, color: Colors.white, size: 24),
          ),
        ),
      ),
    );
  }

  Future<void> _onFabPressed() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'xlsx', 'xls'],
      withData: true,
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
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not read file data. Please try again.')),
        );
      }
    }
  }
}
