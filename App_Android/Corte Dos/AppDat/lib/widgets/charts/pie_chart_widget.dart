import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../constants/app_constants.dart';

class PieChartWidget extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final String title;

  const PieChartWidget({
    super.key,
    required this.data,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 300, // Increased height
              child: Column( // Changed to Column for mobile responsiveness
                children: [
                  Expanded(
                    flex: 3,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: data.asMap().entries.map((entry) {
                          final item = entry.value;
                          final value = (item['value'] as num).toDouble();
                          final name = item['name'] as String;
                          final color = AppConstants.getClientColor(name);
                          
                          final total = data.map((e) => (e['value'] as num).toDouble()).reduce((a, b) => a + b);
                          final percentage = total > 0 ? (value / total * 100) : 0.0;

                          return PieChartSectionData(
                            value: value,
                            title: '${percentage.toStringAsFixed(1)}%',
                            radius: 60,
                            color: color,
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    flex: 2,
                    child: SingleChildScrollView( // Scrollable legend
                      child: Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: data.asMap().entries.map((entry) {
                          final item = entry.value;
                          final name = item['name'] as String;
                          final color = AppConstants.getClientColor(name);
                          
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                name,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
