import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../dashboard/bloc/dashboard_bloc.dart';

class CorrelationPage extends StatelessWidget {
  final VoidCallback? onNavigateToChat;
  const CorrelationPage({super.key, this.onNavigateToChat});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Correlation Analysis',
          style: GoogleFonts.ibmPlexSans(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          if (context.watch<DashboardBloc>().state.activeCorrelation != null)
            IconButton(
              icon: const Icon(LucideIcons.refreshCw, color: Color(0xFF3B82F6), size: 20),
              onPressed: () {
                context.read<DashboardBloc>().add(ClearCorrelation());
              },
              tooltip: 'Clear Results',
            ),
        ],
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state.isLoading && state.activeCorrelation == null) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6)));
          }

          if (state.activeCorrelation != null) {
            return _buildCorrelationView(context, state.activeCorrelation!, state.lastFilePath);
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.barChart2, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'No correlation data',
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 18,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Go to Summary and click "Analyze Correlation"\nto see the relationship between variables.',
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

  Widget _buildCorrelationView(BuildContext context, Map<String, dynamic> correlationData, String? filePath) {
    final matrix = correlationData['correlation_matrix'] as Map<String, dynamic>;
    final columns = matrix.keys.toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Variable Relationships',
            style: GoogleFonts.ibmPlexSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Values close to 1.0 indicate strong positive correlation, while values close to -1.0 indicate strong negative correlation.',
            style: GoogleFonts.ibmPlexSans(color: Colors.grey[600], fontSize: 13),
          ),
          const SizedBox(height: 16),
          if (filePath != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onNavigateToChat,
                icon: const Icon(LucideIcons.bot, size: 18),
                label: const Text('Ask with Chatbot'),
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
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 20,
                  headingRowColor: MaterialStateProperty.all(const Color(0xFF3B82F6).withOpacity(0.05)),
                  columns: [
                    const DataColumn(label: Text('')),
                    ...columns.map((col) => DataColumn(
                      label: Text(
                        col,
                        style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    )),
                  ],
                  rows: columns.map((rowLabel) {
                    final rowData = matrix[rowLabel] as Map<String, dynamic>;
                    return DataRow(
                      cells: [
                        DataCell(Text(
                          rowLabel,
                          style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.bold, fontSize: 12),
                        )),
                        ...columns.map((colLabel) {
                          final value = rowData[colLabel];
                          return DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getCorrelationColor(value),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                value != null ? (value as double).toStringAsFixed(2) : 'N/A',
                                style: GoogleFonts.ibmPlexSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _getTextColor(value),
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getCorrelationColor(dynamic value) {
    if (value == null) return Colors.transparent;
    final val = value as double;
    if (val > 0.7) return Colors.green.withOpacity(0.2);
    if (val > 0.4) return Colors.green.withOpacity(0.1);
    if (val < -0.7) return Colors.red.withOpacity(0.2);
    if (val < -0.4) return Colors.red.withOpacity(0.1);
    return Colors.grey.withOpacity(0.05);
  }

  Color _getTextColor(dynamic value) {
    if (value == null) return Colors.black54;
    final val = value as double;
    if (val > 0.7) return Colors.green[800]!;
    if (val < -0.7) return Colors.red[800]!;
    return Colors.black87;
  }
}
