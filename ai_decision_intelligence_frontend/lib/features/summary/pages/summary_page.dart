import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../dashboard/bloc/dashboard_bloc.dart';

class SummaryPage extends StatelessWidget {
  final VoidCallback? onNavigateToCorrelation;
  const SummaryPage({super.key, this.onNavigateToCorrelation});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Data Summary',
          style: GoogleFonts.ibmPlexSans(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        actions: [
          if (context.watch<DashboardBloc>().state.activeSummary != null)
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: const Icon(LucideIcons.refreshCw, color: Color(0xFF3B82F6), size: 20),
                onPressed: () {
                  context.read<DashboardBloc>().add(ClearSummary());
                },
                tooltip: 'Clear Results',
              ),
            ),
        ],
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
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6)));
            }

            if (state.activeSummary != null) {
              return _buildSummaryView(context, state.activeSummary!, state.lastFilePath);
            }

            return _buildEmptyState();
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(LucideIcons.fileText, size: 64, color: Colors.grey[300]),
          ),
          const SizedBox(height: 24),
          Text(
            'No analysis loaded',
            style: GoogleFonts.ibmPlexSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Go to Dashboard and click "Analyze"\non a dataset to see results.',
            textAlign: TextAlign.center,
            style: GoogleFonts.ibmPlexSans(
              color: Colors.grey[500],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Analysis Insights 📊',
          style: GoogleFonts.ibmPlexSans(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF3B82F6).withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.1)),
          ),
          child: Row(
            children: [
              const Icon(LucideIcons.info, color: Color(0xFF3B82F6), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'This summary provides a comprehensive look at your dataset, including row/column counts, missing value alerts, and key statistical markers like mean, min, and max for each column.',
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryView(BuildContext context, Map<String, dynamic> summary, String? filePath) {
    final descriptiveStats = summary['descriptive_statistics'] as Map<String, dynamic>;
    final missingValues = summary['missing_values'] as Map<String, dynamic>;
    final columnNames = summary['column_names'] as List<dynamic>;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAnalysisOverview(),
          const SizedBox(height: 24),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: _buildQuickStats(summary),
          ),
          const SizedBox(height: 24),
          if (filePath != null) 
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.scale(
                    scale: 0.95 + (0.05 * value),
                    child: child,
                  ),
                );
              },
              child: _buildCorrelationAction(),
            ),
          const SizedBox(height: 32),
          Text(
            'Column Details',
            style: GoogleFonts.ibmPlexSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ...columnNames.asMap().entries.map((entry) {
            final index = entry.key;
            final columnName = entry.value as String;
            final stats = descriptiveStats[columnName] as Map<String, dynamic>?;
            final missing = missingValues[columnName] as int? ?? 0;
            
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 400 + (index * 100).clamp(0, 600)),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 30 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: _buildColumnDetailCard(columnName, stats, missing),
              ),
            );
          }),
          const SizedBox(height: 80), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildCorrelationAction() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onNavigateToCorrelation,
        icon: const Icon(LucideIcons.barChart2, size: 20),
        label: Text(
          'Analyze Correlation',
          style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3B82F6),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildColumnDetailCard(String columnName, Map<String, dynamic>? stats, int missing) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          title: Text(
            columnName,
            style: GoogleFonts.ibmPlexSans(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(LucideIcons.table, color: Color(0xFF3B82F6), size: 20),
          ),
          subtitle: Row(
            children: [
              Icon(
                missing > 0 ? LucideIcons.alertCircle : LucideIcons.checkCircle2,
                size: 14,
                color: missing > 0 ? Colors.orange : Colors.green,
              ),
              const SizedBox(width: 6),
              Text(
                missing > 0 ? 'Missing: $missing' : 'Complete Data',
                style: GoogleFonts.ibmPlexSans(
                  color: missing > 0 ? Colors.orange[700] : Colors.green[700],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          children: [
            if (stats != null)
              Container(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  children: [
                    const Divider(height: 1),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: stats.entries.map((entry) => _buildStatBadge(entry.key, entry.value)).toList(),
                    ),
                  ],
                ),
              )
            else
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text('No statistical data available for this column.'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBadge(String key, dynamic value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$key: ',
            style: GoogleFonts.ibmPlexSans(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value?.toString() ?? 'N/A',
            style: GoogleFonts.ibmPlexSans(
              fontSize: 12,
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(Map<String, dynamic> summary) {
    return Row(
      children: [
        _statCard('Total Rows', summary['rows'].toString(), LucideIcons.database, const Color(0xFF3B82F6)),
        const SizedBox(width: 16),
        _statCard('Total Columns', summary['columns'].toString(), LucideIcons.columns, const Color(0xFF10B981)),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: color.withOpacity(0.05), width: 1),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.12),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.2), color.withOpacity(0.05)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 22, color: color),
              ),
              const SizedBox(height: 16),
              TweenAnimationBuilder<int>(
                tween: IntTween(begin: 0, end: int.tryParse(value) ?? 0),
                duration: const Duration(seconds: 1),
                builder: (context, val, child) {
                  return Text(
                    val.toString(),
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      letterSpacing: -0.5,
                    ),
                  );
                },
              ),
              Text(
                label,
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 13,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
