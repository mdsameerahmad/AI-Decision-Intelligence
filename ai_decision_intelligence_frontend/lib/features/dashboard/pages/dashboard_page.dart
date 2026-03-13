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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'AI Decision Intelligence',
          style: GoogleFonts.ibmPlexSans(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.logOut, color: Colors.black54),
            onPressed: () {
              context.read<AuthBloc>().add(LogoutEvent());
            },
            tooltip: 'Logout',
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
            // Navigate to Summary tab (index 1) when summary is loaded
            onNavigateToSummary(1);
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildDatasetSectionHeader(context, state),
                const SizedBox(height: 16),
                Expanded(
                  child: _buildMainContent(context, state),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDatasetSectionHeader(BuildContext context, DashboardState state) {
    final hasSelection = state.selectedDatasetIds.isNotEmpty;
    final isAllSelected = state.datasets.isNotEmpty &&
        state.selectedDatasetIds.length == state.datasets.length;

    return Row(
      children: [
        if (state.datasets.isNotEmpty) ...[
          Checkbox(
            value: isAllSelected,
            activeColor: const Color(0xFF3B82F6),
            onChanged: (value) {
              context
                  .read<DashboardBloc>()
                  .add(SelectAllDatasets(value ?? false));
            },
          ),
          Text(
            'Select All',
            style: GoogleFonts.ibmPlexSans(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ],
        const Spacer(),
        if (hasSelection)
          ElevatedButton.icon(
            onPressed: () => _showBulkDeleteConfirmation(context, state),
            icon: const Icon(LucideIcons.trash2, size: 16, color: Colors.white),
            label: Text('Delete (${state.selectedDatasetIds.length})'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          )
        else
          Text(
            'Your Datasets',
            style: GoogleFonts.ibmPlexSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dashboard',
          style: GoogleFonts.ibmPlexSans(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Manage your data and get AI insights.',
          style: GoogleFonts.ibmPlexSans(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildMainContent(BuildContext context, DashboardState state) {
    if (state.isLoading && state.datasets.isEmpty) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFF3B82F6)));
    }

    if (state.datasets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.folderOpen, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No datasets found',
              style: GoogleFonts.ibmPlexSans(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? const Color(0xFF3B82F6) : Colors.grey[100]!,
          width: isSelected ? 2 : 1,
        ),
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
          Checkbox(
            value: isSelected,
            activeColor: const Color(0xFF3B82F6),
            onChanged: (value) {
              context
                  .read<DashboardBloc>()
                  .add(ToggleDatasetSelection(dataset.id));
            },
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(LucideIcons.database,
                color: Color(0xFF3B82F6), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dataset.fileName,
                  style: GoogleFonts.ibmPlexSans(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Uploaded at: ${dataset.uploadedAt}',
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<DashboardBloc>().add(GetSummary(dataset.filePath));
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF3B82F6),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: const Text('Summary'),
          ),
          IconButton(
            icon: const Icon(LucideIcons.trash2, color: Colors.redAccent, size: 20),
            onPressed: () {
              _showDeleteConfirmation(context, dataset);
            },
            tooltip: 'Delete Dataset',
          ),
        ],
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
