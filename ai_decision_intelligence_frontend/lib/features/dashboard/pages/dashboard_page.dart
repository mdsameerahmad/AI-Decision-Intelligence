import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../data/models/app_models.dart';
import '../../auth/pages/profile_page.dart';
import '../bloc/dashboard_bloc.dart';

class DashboardPage extends StatelessWidget {
  final Function(int) onNavigateToSummary;

  const DashboardPage({super.key, required this.onNavigateToSummary});

  Future<void> _pickAndUploadFile(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'xlsx', 'xls'],
      withData: true,
    );

    if (result != null) {
      final file = result.files.first;
      if (file.bytes != null) {
        context.read<DashboardBloc>().add(
              UploadDataset(file.bytes!, file.name),
            );
      } else {
        // Fallback for mobile if bytes are still null (shouldn't happen with withData: true)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not read file data. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsiveHelper.isMobile(context);

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
                if (isMobile) ...[
                  Image.asset(
                    'assets/images/logo.png',
                    height: 32,
                    width: 32,
                    errorBuilder: (context, error, stackTrace) => Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(LucideIcons.brainCircuit,
                          color: Color(0xFF3B82F6), size: 24),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Data Analysts',
                      style: GoogleFonts.ibmPlexSans(
                        fontWeight: FontWeight.bold,
                        fontSize: isMobile ? 18 : 22,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'Smart Data Insights',
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: isMobile ? 12 : 14,
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
                padding: const EdgeInsets.only(right: 16),
                child: Tooltip(
                  message: 'Profile',
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ProfilePage()),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6).withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: const Color(0xFF3B82F6).withOpacity(0.1)),
                      ),
                      child: const Icon(
                        LucideIcons.user,
                        color: Color(0xFF3B82F6),
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: BlocConsumer<DashboardBloc, DashboardState>(
        listenWhen: (previous, current) =>
            previous.activeSummary != current.activeSummary ||
            previous.errorMessage != current.errorMessage,
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: AppTheme.errorRed),
            );
          }
          if (state.activeSummary != null) {
            onNavigateToSummary(1);
          }
        },
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<DashboardBloc>().add(LoadDatasets());
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24),
              child: ResponsiveHelper.constrainedContent(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPremiumWelcome(state),
                    const SizedBox(height: 24),
                    if (!isMobile)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 2, child: _buildUploadSection(context)),
                          const SizedBox(width: 32),
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildDatasetSectionHeader(context, state),
                                const SizedBox(height: 20),
                                _buildMainContent(context, state),
                              ],
                            ),
                          ),
                        ],
                      )
                    else ...[
                      _buildUploadSection(context),
                      const SizedBox(height: 32),
                      _buildDatasetSectionHeader(context, state),
                      const SizedBox(height: 20),
                      _buildMainContent(context, state),
                    ],
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPremiumWelcome(DashboardState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.sparkles,
                    color: Colors.white, size: 16),
              ),
              const SizedBox(width: 10),
              Text(
                'AI Analysis Ready',
                style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Hello! 👋\nLet\'s uncover your data story.',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 22,
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          if (state.datasets.isNotEmpty)
            Text(
              '${state.datasets.length} datasets ready for analysis.',
              style: GoogleFonts.inter(
                color: Colors.white.withOpacity(0.8),
                fontSize: 13,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back! 👋',
          style: GoogleFonts.ibmPlexSans(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Let\'s analyze some data today.',
          style: GoogleFonts.ibmPlexSans(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildUploadSection(BuildContext context) {
    return GestureDetector(
      onTap: () => _pickAndUploadFile(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.6), // Glassmorphism base
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFF3B82F6).withOpacity(0.15),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3B82F6).withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF3B82F6).withOpacity(0.1),
                    const Color(0xFF3B82F6).withOpacity(0.05),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.uploadCloud,
                color: Color(0xFF3B82F6),
                size: 36,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Analyze New Dataset',
              style: GoogleFonts.ibmPlexSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tap to upload or drag & drop files',
              style: GoogleFonts.ibmPlexSans(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Supports CSV, Excel, and Google Sheets',
              style: GoogleFonts.ibmPlexSans(
                fontSize: 12,
                color: const Color(0xFF3B82F6).withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildActionButton(
                  icon: LucideIcons.filePlus,
                  label: 'Browse Files',
                  onTap: () => _pickAndUploadFile(context),
                ),
                const SizedBox(width: 12),
                _buildActionButton(
                  icon: LucideIcons.sheet,
                  label: 'Google Sheets',
                  onTap: () => _showGoogleSheetDialog(context),
                  isSecondary: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isSecondary = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSecondary ? Colors.white : const Color(0xFF3B82F6),
          borderRadius: BorderRadius.circular(30),
          border: isSecondary 
            ? Border.all(color: const Color(0xFF3B82F6).withOpacity(0.3))
            : null,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3B82F6).withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isSecondary ? const Color(0xFF3B82F6) : Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.ibmPlexSans(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isSecondary ? const Color(0xFF3B82F6) : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGoogleSheetDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Import Google Sheet', style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Paste the link to a public Google Sheet below:',
              style: GoogleFonts.ibmPlexSans(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'https://docs.google.com/spreadsheets/d/...',
                hintStyle: GoogleFonts.ibmPlexSans(fontSize: 13),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.ibmPlexSans(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                context.read<DashboardBloc>().add(ImportGoogleSheet(controller.text));
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Import', style: GoogleFonts.ibmPlexSans(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildDatasetSectionHeader(BuildContext context, DashboardState state) {
    final hasSelection = state.selectedDatasetIds.isNotEmpty;
    final isAllSelected = state.datasets.isNotEmpty &&
        state.selectedDatasetIds.length == state.datasets.length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Your Datasets',
          style: GoogleFonts.ibmPlexSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        if (state.datasets.isNotEmpty)
          Row(
            children: [
              if (hasSelection)
                IconButton(
                  onPressed: () => _showBulkDeleteConfirmation(context, state),
                  icon: const Icon(LucideIcons.trash2, size: 20, color: Colors.redAccent),
                  tooltip: 'Delete Selected',
                ),
              const SizedBox(width: 8),
              Text(
                'Select All',
                style: GoogleFonts.ibmPlexSans(fontSize: 12, color: Colors.grey[600]),
              ),
              Transform.scale(
                scale: 0.8,
                child: Checkbox(
                  value: isAllSelected,
                  activeColor: const Color(0xFF3B82F6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  onChanged: (value) {
                    context
                        .read<DashboardBloc>()
                        .add(SelectAllDatasets(value ?? false));
                  },
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildMainContent(BuildContext context, DashboardState state) {
    if (state.isLoading && state.datasets.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 40.0),
        child: Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6))),
      );
    }

    if (state.datasets.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 40),
        width: double.infinity,
        child: Column(
          children: [
            Icon(LucideIcons.folderOpen, size: 48, color: Colors.grey[200]),
            const SizedBox(height: 16),
            Text(
              'No datasets found',
              style: GoogleFonts.ibmPlexSans(color: Colors.grey[400]),
            ),
          ],
        ),
      );
    }

    final bool isMobile = ResponsiveHelper.isMobile(context);

    if (!isMobile) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 400,
          mainAxisExtent: 100,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: state.datasets.length,
        itemBuilder: (context, index) {
          final dataset = state.datasets[index];
          final isSelected = state.selectedDatasetIds.contains(dataset.id);
          return _buildDatasetItem(context, dataset, isSelected);
        },
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: state.datasets.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final dataset = state.datasets[index];
        final isSelected = state.selectedDatasetIds.contains(dataset.id);
        return _buildDatasetItem(context, dataset, isSelected);
      },
    );
  }

  Widget _buildDatasetItem(BuildContext context, DatasetModel dataset, bool isSelected) {
    final bool isMobile = ResponsiveHelper.isMobile(context);
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? const Color(0xFF3B82F6) : Colors.white,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected 
                ? const Color(0xFF3B82F6).withOpacity(0.1) 
                : Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              context.read<DashboardBloc>().add(ToggleDatasetSelection(dataset.id));
            },
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 16, 
                vertical: 14,
              ),
              child: Row(
                children: [
                  // 1. Selection Checkbox
                  Transform.scale(
                    scale: isMobile ? 0.8 : 0.9,
                    child: Checkbox(
                      value: isSelected,
                      activeColor: const Color(0xFF3B82F6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      onChanged: (value) {
                        context.read<DashboardBloc>().add(ToggleDatasetSelection(dataset.id));
                      },
                    ),
                  ),
                  SizedBox(width: isMobile ? 4 : 8),

                  // 2. Icon Container (Hidden on very small screens to save space)
                  if (!isMobile || MediaQuery.of(context).size.width > 350) ...[
                    Container(
                      padding: EdgeInsets.all(isMobile ? 8 : 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF3B82F6).withOpacity(0.12),
                            const Color(0xFF3B82F6).withOpacity(0.06),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        LucideIcons.fileSpreadsheet,
                        color: const Color(0xFF3B82F6), 
                        size: isMobile ? 20 : 24,
                      ),
                    ),
                    SizedBox(width: isMobile ? 10 : 16),
                  ],

                  // 3. Name and Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          dataset.fileName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.ibmPlexSans(
                            fontWeight: FontWeight.bold,
                            fontSize: isMobile ? 14 : 16,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(LucideIcons.calendar, size: 10, color: Colors.grey[400]),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                dataset.uploadedAt,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.ibmPlexSans(
                                  fontSize: 10,
                                  color: Colors.grey[500],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: isMobile ? 8 : 12),

                  // 4. Action Buttons
                  _buildActionButtons(context, dataset),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, DatasetModel dataset) {
    final bool isMobile = ResponsiveHelper.isMobile(context);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Analyze Button
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              context.read<DashboardBloc>().add(GetSummary(dataset.filePath));
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 10 : 14, 
                vertical: isMobile ? 6 : 8,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF3B82F6).withOpacity(0.85),
                    const Color(0xFF3B82F6).withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Text(
                'Analyze',
                style: GoogleFonts.ibmPlexSans(
                  fontSize: isMobile ? 11 : 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: isMobile ? 2 : 6),
        // Delete Icon
        _actionIconButton(
          onPressed: () {
            _showDeleteConfirmation(context, dataset);
          },
          icon: LucideIcons.trash2,
          color: Colors.redAccent.withOpacity(0.7),
          tooltip: 'Delete',
          size: isMobile ? 18 : 22,
        ),
      ],
    );
  }

  Widget _actionIconButton({
    required VoidCallback onPressed,
    required IconData icon,
    required Color color,
    required String tooltip,
    double size = 22,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Icon(icon, color: color, size: size),
          ),
        ),
      ),
    );
  }

  void _showBulkDeleteConfirmation(BuildContext context, DashboardState state) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Multiple Datasets',
          style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete ${state.selectedDatasetIds.length} selected datasets? This action cannot be undone.',
          style: GoogleFonts.ibmPlexSans(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.ibmPlexSans(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<DashboardBloc>().add(DeleteSelectedDatasets());
              Navigator.pop(context);
            },
            child: Text(
              'Delete All',
              style: GoogleFonts.ibmPlexSans(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, DatasetModel dataset) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Dataset',
          style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete "${dataset.fileName}"? This action cannot be undone.',
          style: GoogleFonts.ibmPlexSans(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.ibmPlexSans(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<DashboardBloc>().add(DeleteDataset(dataset.id));
              Navigator.pop(context);
            },
            child: Text(
              'Delete',
              style: GoogleFonts.ibmPlexSans(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}
