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
        title: Text(
          'Data Summary',
          style: GoogleFonts.ibmPlexSans(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          if (context.watch<DashboardBloc>().state.activeSummary != null)
            IconButton(
              icon: const Icon(LucideIcons.refreshCw, color: Color(0xFF3B82F6), size: 20),
              onPressed: () {
                context.read<DashboardBloc>().add(ClearSummary());
              },
              tooltip: 'Clear Results',
            ),
        ],
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6)));
          }

          if (state.activeSummary != null) {
            return _buildSummaryView(context, state.activeSummary!, state.lastFilePath);
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.fileText, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'No analysis loaded',
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 18,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Go to Dashboard and click "Summary"\non a dataset to see results.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.ibmPlexSans(
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryView(BuildContext context, Map<String, dynamic> summary, String? filePath) {
    final descriptiveStats = summary['descriptive_statistics'] as Map<String, dynamic>;
    final missingValues = summary['missing_values'] as Map<String, dynamic>;
    final columnNames = summary['column_names'] as List<dynamic>;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuickStats(summary),
          const SizedBox(height: 16),
          if (filePath != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onNavigateToCorrelation,
                icon: const Icon(LucideIcons.barChart2, size: 18),
                label: const Text('Analyze Correlation'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
          const SizedBox(height: 24),
          Text(
            'Column Details',
            style: GoogleFonts.ibmPlexSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.only(bottom: 24),
              itemCount: columnNames.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final columnName = columnNames[index] as String;
                final stats = descriptiveStats[columnName] as Map<String, dynamic>?;
                final missing = missingValues[columnName] as int? ?? 0;

                return Card(
                  elevation: 0,
                  color: Colors.grey[50],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey[200]!),
                  ),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text(
                      columnName,
                      style: GoogleFonts.ibmPlexSans(
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    subtitle: missing > 0
                        ? Text(
                            'Missing: $missing',
                            style: GoogleFonts.ibmPlexSans(color: Colors.red[400], fontSize: 12),
                          )
                        : Text(
                            'Complete Data',
                            style: GoogleFonts.ibmPlexSans(color: Colors.green[400], fontSize: 12),
                          ),
                    children: stats != null
                        ? stats.entries.map((entry) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    entry.key,
                                    style: GoogleFonts.ibmPlexSans(color: Colors.grey[600], fontSize: 13),
                                  ),
                                  Text(
                                    entry.value?.toString() ?? 'N/A',
                                    style: GoogleFonts.ibmPlexSans(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList()
                        : [const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('No stats available'),
                          )],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(Map<String, dynamic> summary) {
    return Row(
      children: [
        _statCard('Rows', summary['rows'].toString(), LucideIcons.rows),
        const SizedBox(width: 16),
        _statCard('Columns', summary['columns'].toString(), LucideIcons.columns),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF3B82F6).withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: const Color(0xFF3B82F6)),
            const SizedBox(height: 12),
            Text(
              value,
              style: GoogleFonts.ibmPlexSans(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.ibmPlexSans(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
