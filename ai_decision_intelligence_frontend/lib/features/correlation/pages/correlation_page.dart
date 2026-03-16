import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive_helper.dart';
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
    final bool isMobile = ResponsiveHelper.isMobile(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24),
      child: ResponsiveHelper.constrainedContent(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCorrelationOverview(),
            const SizedBox(height: 24),
            if (!isMobile)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildCorrelationCharts(matrix, columns)),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _buildForecastSection(
                        context, columns, filePath, selectedColumn, forecastResult),
                  ),
                ],
              )
            else ...[
              _buildCorrelationCharts(matrix, columns),
              const SizedBox(height: 32),
              _buildForecastSection(
                  context, columns, filePath, selectedColumn, forecastResult),
            ],
            const SizedBox(height: 32),
            if (filePath != null) _buildChatAction(),
            const SizedBox(height: 32),
            _buildMatrixSection(matrix, columns),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildCorrelationOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Data Synergy 💎',
          style: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
            color: AppTheme.textMain,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Discover hidden relationships between your data points.',
          style: GoogleFonts.inter(
            fontSize: 16,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 24),
        _buildCorrelationGuide(),
      ],
    );
  }

  Widget _buildCorrelationGuide() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _guideItem(
          LucideIcons.trendingUp,
          Colors.green,
          'Positive (+1.0):',
          'Variables move in the same direction (e.g., Temperature ↑, Sales ↑).',
        ),
        const SizedBox(height: 12),
        _guideItem(
          LucideIcons.trendingDown,
          Colors.red,
          'Negative (-1.0):',
          'Variables move in opposite directions (e.g., Price ↑, Demand ↓).',
        ),
        const SizedBox(height: 12),
        _guideItem(
          LucideIcons.info,
          AppTheme.primaryBlue,
          'Note:',
          'Correlation shows relationship strength, not necessarily causation.',
        ),
      ],
    );
  }

  Widget _guideItem(IconData icon, Color color, String label, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: color, size: 12),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.inter(fontSize: 12, height: 1.5),
              children: [
                TextSpan(
                  text: '$label ',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                TextSpan(
                  text: desc,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
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
        Row(
          children: [
            Text(
              'Top Drivers',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.textMain,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(LucideIcons.zap, color: Colors.orange, size: 18),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          height: 300,
          padding: const EdgeInsets.fromLTRB(16, 24, 24, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: AppTheme.softShadow,
            border: Border.all(color: Colors.grey[100]!),
          ),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 1.0,
              minY: -1.0,
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (group) => AppTheme.textMain,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${topEntries[group.x].key}\n',
                      GoogleFonts.inter(
                          color: Colors.white, fontWeight: FontWeight.bold),
                      children: [
                        TextSpan(
                          text: rod.toY.toStringAsFixed(2),
                          style: GoogleFonts.inter(
                              color: rod.toY >= 0
                                  ? Colors.greenAccent
                                  : Colors.redAccent,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= 0 &&
                          value.toInt() < topEntries.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Transform.rotate(
                            angle: -0.5,
                            child: Text(
                              topEntries[value.toInt()].key.length > 8
                                  ? '${topEntries[value.toInt()].key.substring(0, 6)}..'
                                  : topEntries[value.toInt()].key,
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textSecondary,
                              ),
                            ),
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
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) => Text(
                      value.toStringAsFixed(1),
                      style: GoogleFonts.inter(
                          fontSize: 10, color: AppTheme.textSecondary),
                    ),
                  ),
                ),
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.grey[100]!,
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              barGroups: topEntries.asMap().entries.map((e) {
                final val = e.value.value as double;
                return BarChartGroupData(
                  x: e.key,
                  barRods: [
                    BarChartRodData(
                      toY: val,
                      gradient: LinearGradient(
                        colors: val >= 0
                            ? [AppTheme.primaryBlue, AppTheme.secondaryBlue]
                            : [Colors.redAccent, Colors.orangeAccent],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                      width: 20,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(6),
                        topRight: const Radius.circular(6),
                        bottomLeft: Radius.circular(val < 0 ? 6 : 0),
                        bottomRight: Radius.circular(val < 0 ? 6 : 0),
                      ),
                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        toY: val >= 0 ? 1 : -1,
                        color: Colors.grey[50],
                      ),
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
        Row(
          children: [
            Text(
              'Interactive Heatmap',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: AppTheme.textMain,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(LucideIcons.grid, color: AppTheme.primaryBlue, size: 20),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(1), // Border effect
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(24),
            boxShadow: AppTheme.softShadow,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(23),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 12,
                horizontalMargin: 12,
                headingRowHeight: 50,
                dataRowHeight: 50,
                headingRowColor: MaterialStateProperty.all(Colors.white),
                dataRowColor: MaterialStateProperty.all(Colors.white),
                dividerThickness: 0.5,
                columns: [
                  const DataColumn(label: SizedBox(width: 80)),
                  ...columns.map((col) => DataColumn(
                        label: SizedBox(
                          width: 60,
                          child: Text(
                            col,
                            overflow: TextSpan(text: col).toPlainText().length > 8 
                                ? TextOverflow.ellipsis 
                                : TextOverflow.visible,
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                                color: AppTheme.textMain),
                          ),
                        ),
                      )),
                ],
                rows: columns.map((rowLabel) {
                  final rowData = matrix[rowLabel] as Map<String, dynamic>;
                  return DataRow(
                    cells: [
                      DataCell(SizedBox(
                        width: 80,
                        child: Text(
                          rowLabel,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                              color: AppTheme.textSecondary),
                        ),
                      )),
                      ...columns.map((colLabel) {
                        final value = rowData[colLabel];
                        return DataCell(
                          SizedBox(
                            width: 60,
                            child: Center(
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: 44,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: _getCorrelationColor(value),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.5),
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    value != null
                                        ? (value as double).toStringAsFixed(2)
                                        : 'N/A',
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: _getTextColor(value),
                                    ),
                                  ),
                                ),
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
        Row(
          children: [
            Text(
              'AI Forecasting',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: AppTheme.textMain,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(LucideIcons.sparkles, color: Colors.purple, size: 20),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: AppTheme.softShadow,
            border: Border.all(color: Colors.grey[100]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Predict next trends based on historical patterns.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                value: selectedColumn.value,
                dropdownColor: Colors.white,
                icon: const Icon(LucideIcons.chevronDown, size: 18),
                decoration: InputDecoration(
                  labelText: 'Target Variable',
                  hintText: 'Select column',
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey[200]!),
                  ),
                ),
                items: columns.map((String col) {
                  return DropdownMenuItem<String>(
                    value: col,
                    child: Text(col,
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  selectedColumn.value = newValue;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: filePath != null && selectedColumn.value != null
                      ? () {
                          context.read<DashboardBloc>().add(
                              GetForecast(filePath, selectedColumn.value!));
                        }
                      : null,
                  icon: const Icon(LucideIcons.sparkles, size: 18),
                  label: const Text('Run Prediction'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              if (forecastResult != null) ...[
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryBlue.withOpacity(0.05),
                        AppTheme.primaryBlue.withOpacity(0.01)
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
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
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (forecastResult['explanation'] != null) ...[
                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 12),
                        Text(
                          forecastResult['explanation'],
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: 14,
                            color: Colors.grey[800],
                            height: 1.5,
                          ),
                        ),
                      ],
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
