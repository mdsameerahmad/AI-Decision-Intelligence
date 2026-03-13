import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../data/models/app_models.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../bloc/dashboard_bloc.dart';

class DashboardPage extends StatelessWidget {
  final Function(int) onNavigateToSummary;

  const DashboardPage({super.key, required this.onNavigateToSummary});

  Future<void> _pickAndUploadFile(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      final file = result.files.first;
      if (file.bytes != null) {
        context.read<DashboardBloc>().add(
              UploadDataset(file.bytes!, file.name),
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'AI Decision Intelligence',
          style: GoogleFonts.ibmPlexSans(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: const Icon(LucideIcons.logOut, color: Colors.black54),
              onPressed: () {
                context.read<AuthBloc>().add(LogoutEvent());
              },
              tooltip: 'Logout',
            ),
          ),
        ],
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
                  backgroundColor: Colors.red),
            );
          }
          if (state.activeSummary != null) {
            onNavigateToSummary(1);
          }
        },
        builder: (context, state) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF3B82F6).withOpacity(0.08), // Soft Blue
                  Colors.white, // Fade to White
                ],
              ),
            ),
            child: RefreshIndicator(
              onRefresh: () async {
                context.read<DashboardBloc>().add(LoadDatasets());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeSection(),
                    const SizedBox(height: 24),
                    _buildUploadSection(context),
                    const SizedBox(height: 32),
                    _buildDatasetSectionHeader(context, state),
                    const SizedBox(height: 16),
                    _buildMainContent(context, state),
                    const SizedBox(height: 80), // Space for FAB/BottomBar
                  ],
                ),
              ),
            ),
          );
        },
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
              'Tap to upload or drag & drop CSV files',
              style: GoogleFonts.ibmPlexSans(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                'Browse Files',
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Transform.scale(
                    scale: 0.9,
                    child: Checkbox(
                      value: isSelected,
                      activeColor: const Color(0xFF3B82F6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      onChanged: (value) {
                        context.read<DashboardBloc>().add(ToggleDatasetSelection(dataset.id));
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF3B82F6).withOpacity(0.12),
                          const Color(0xFF3B82F6).withOpacity(0.06),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(LucideIcons.fileSpreadsheet,
                        color: Color(0xFF3B82F6), size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dataset.fileName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.ibmPlexSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(LucideIcons.calendar, size: 12, color: Colors.grey[400]),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                dataset.uploadedAt,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.ibmPlexSans(
                                  fontSize: 11,
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Glassmorphism Analyze Button
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              context.read<DashboardBloc>().add(GetSummary(dataset.filePath));
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF3B82F6).withOpacity(0.85),
                    const Color(0xFF3B82F6).withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                'Analyze',
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        _actionIconButton(
          onPressed: () {
            _showDeleteConfirmation(context, dataset);
          },
          icon: LucideIcons.trash2,
          color: Colors.redAccent.withOpacity(0.7),
          tooltip: 'Delete',
        ),
      ],
    );
  }

  Widget _actionIconButton({
    required VoidCallback onPressed,
    required IconData icon,
    required Color color,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: color, size: 22),
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
