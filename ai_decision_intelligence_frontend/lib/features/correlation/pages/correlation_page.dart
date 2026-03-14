import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../dashboard/bloc/dashboard_bloc.dart';

class CorrelationPage extends HookWidget {
  final VoidCallback? onNavigateToChat;
  const CorrelationPage({super.key, this.onNavigateToChat});

  @override
  Widget build(BuildContext context) {
    final selectedColumn = useState<String?>(null);
    final state = context.watch<DashboardBloc>().state;
    final forecastResult = state.forecastResult;
    final correlationData = state.activeCorrelation;
    final filePath = state.lastFilePath;

    useEffect(() {
      if (correlationData != null) {
        final matrix = correlationData['correlation_matrix'] as Map<String, dynamic>;
        final columns = matrix.keys.toList();
        if (columns.isNotEmpty && selectedColumn.value == null) {
          selectedColumn.value = columns.first;
        }
      }
      return null;
    }, [correlationData]);

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
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(LucideIcons.barChart2,
                      color: Color(0xFF3B82F6), size: 24),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Correlation Analysis',
                      style: GoogleFonts.ibmPlexSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'Relationship & Trends',
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              if (correlationData != null)
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Tooltip(
                    message: 'Clear Results',
                    child: InkWell(
                      onTap: () => context.read<DashboardBloc>().add(ClearCorrelation()),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.redAccent.withOpacity(0.1)),
                        ),
                        child: const Icon(
                          LucideIcons.refreshCw,
                          color: Colors.redAccent,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
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
            if (state.isLoading && state.activeCorrelation == null) {
              return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF3B82F6)));
            }

            if (state.activeCorrelation != null) {
              return _buildCorrelationView(
                context,
                state.activeCorrelation!,
                state.lastFilePath,
                selectedColumn,
                forecastResult,
              );
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
            child:
                Icon(LucideIcons.barChart2, size: 64, color: Colors.grey[300]),
          ),
          const SizedBox(height: 24),
          Text(
            'No correlation data',
            style: GoogleFonts.ibmPlexSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Go to Summary and click "Analyze Correlation"\nto see the relationship between variables.',
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

  Widget _buildCorrelationView(
    BuildContext context,
    Map<String, dynamic> correlationData,
    String? filePath,
    ValueNotifier<String?> selectedColumn,
    dynamic forecastResult,
  ) {
    final matrix = correlationData['correlation_matrix'] as Map<String, dynamic>;
    final columns = matrix.keys.toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCorrelationOverview(),
          const SizedBox(height: 24),
          _buildCorrelationCharts(matrix, columns),
          const SizedBox(height: 32),
          _buildForecastSection(
              context, columns, filePath, selectedColumn, forecastResult),
          const SizedBox(height: 32),
          if (filePath != null) _buildChatAction(),
          const SizedBox(height: 32),
          _buildMatrixSection(matrix, columns),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildCorrelationOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Relationship Insights 🔗',
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
                  'Correlation measures how two variables move together. Values near +1.0 show a strong positive link, while values near -1.0 show a strong negative link. 0 means no linear relationship.',
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

  Widget _buildCorrelationCharts(
      Map<String, dynamic> matrix, List<String> columns) {
    final firstCol = columns.first;
    final firstColData = matrix[firstCol] as Map<String, dynamic>;
    final entries = firstColData.entries
        .where((e) => e.key != firstCol)
        .toList()
      ..sort((a, b) =>
          (b.value as double).abs().compareTo((a.value as double).abs()));

    final topEntries = entries.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Correlations with $firstCol',
          style: GoogleFonts.ibmPlexSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 250,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 1.0,
              minY: -1.0,
              barTouchData: BarTouchData(enabled: true),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= 0 &&
                          value.toInt() < topEntries.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            topEntries[value.toInt()].key.substring(
                                0,
                                (topEntries[value.toInt()].key.length)
                                    .clamp(0, 5)),
                            style: const TextStyle(
                                fontSize: 10, color: Colors.grey),
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) => Text(
                          value.toStringAsFixed(1),
                          style: const TextStyle(
                              fontSize: 10, color: Colors.grey))),
                ),
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: topEntries.asMap().entries.map((e) {
                final val = e.value.value as double;
                return BarChartGroupData(
                  x: e.key,
                  barRods: [
                    BarChartRodData(
                      toY: val,
                      color: val >= 0
                          ? const Color(0xFF3B82F6)
                          : Colors.redAccent,
                      width: 16,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMatrixSection(Map<String, dynamic> matrix, List<String> columns) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Correlation Matrix',
          style: GoogleFonts.ibmPlexSans(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 24,
              headingRowColor: MaterialStateProperty.all(
                  const Color(0xFF3B82F6).withOpacity(0.05)),
              columns: [
                const DataColumn(label: Text('')),
                ...columns.map((col) => DataColumn(
                      label: Text(
                        col,
                        style: GoogleFonts.ibmPlexSans(
                            fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    )),
              ],
              rows: columns.map((rowLabel) {
                final rowData = matrix[rowLabel] as Map<String, dynamic>;
                return DataRow(
                  cells: [
                    DataCell(Text(
                      rowLabel,
                      style: GoogleFonts.ibmPlexSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.black54),
                    )),
                    ...columns.map((colLabel) {
                      final value = rowData[colLabel];
                      return DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getCorrelationColor(value),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            value != null
                                ? (value as double).toStringAsFixed(2)
                                : 'N/A',
                            style: GoogleFonts.ibmPlexSans(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
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
      ],
    );
  }

  Widget _buildChatAction() {
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
        onPressed: onNavigateToChat,
        icon: const Icon(LucideIcons.bot, size: 20),
        label: Text(
          'Ask with AI Chatbot',
          style:
              GoogleFonts.ibmPlexSans(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3B82F6),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
        ),
      ),
    );
  }

  Color _getCorrelationColor(dynamic value) {
    if (value == null) return Colors.transparent;
    final val = value as double;
    if (val > 0.7) return Colors.green.withOpacity(0.15);
    if (val > 0.4) return Colors.green.withOpacity(0.08);
    if (val < -0.7) return Colors.red.withOpacity(0.15);
    if (val < -0.4) return Colors.red.withOpacity(0.08);
    return Colors.grey.withOpacity(0.05);
  }

  Color _getTextColor(dynamic value) {
    if (value == null) return Colors.black54;
    final val = value as double;
    if (val > 0.7) return Colors.green[700]!;
    if (val < -0.7) return Colors.red[700]!;
    return Colors.black87;
  }

  Widget _buildForecastSection(
    BuildContext context,
    List<String> columns,
    String? filePath,
    ValueNotifier<String?> selectedColumn,
    dynamic forecastResult,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Forecast Future Trends 📈',
          style: GoogleFonts.ibmPlexSans(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
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
              const Icon(LucideIcons.sparkles, color: Color(0xFF3B82F6), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Forecasting uses historical data patterns to predict the next likely value. This helps you anticipate future trends and make proactive, data-driven decisions.',
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
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select a column to forecast:',
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 15,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedColumn.value,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF3B82F6).withOpacity(0.05),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: columns.map((String col) {
                  return DropdownMenuItem<String>(
                    value: col,
                    child: Text(col, style: GoogleFonts.ibmPlexSans()),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  selectedColumn.value = newValue;
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: filePath != null && selectedColumn.value != null
                      ? () {
                          context.read<DashboardBloc>().add(
                              GetForecast(filePath, selectedColumn.value!));
                        }
                      : null,
                  icon: const Icon(LucideIcons.trendingUp, size: 20),
                  label: Text(
                    'Generate Forecast',
                    style: GoogleFonts.ibmPlexSans(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                ),
              ),
              if (forecastResult != null) ...[
                const SizedBox(height: 20),
                Divider(color: Colors.grey[200]),
                const SizedBox(height: 20),
                Text(
                  'Forecast Result:',
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: const Color(0xFF3B82F6).withOpacity(0.1)),
                  ),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.lightbulb,
                          color: Color(0xFF3B82F6), size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'The forecasted value for "${forecastResult['column']}" is: ${forecastResult['forecast']?.toStringAsFixed(2) ?? 'N/A'}',
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: 15,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
