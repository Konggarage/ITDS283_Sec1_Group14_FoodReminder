import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:myapp/Fooddatabase.dart';
import 'package:myapp/pages/settingpage.dart';

class Analyze extends StatefulWidget {
  const Analyze({super.key});

  @override
  State<Analyze> createState() => _AnalyzeState();
}

class _AnalyzeState extends State<Analyze> {
  double completedPercent = 0.0;
  double expiredPercent = 0.0;
  double inProgressPercent = 0.0;
  List<String> top3Categories = [];

  void updateChartData(double completed, double expired, double inProgress, List<String> top3) {
    setState(() {
      completedPercent = completed;
      expiredPercent = expired;
      inProgressPercent = inProgress;
      top3Categories = top3;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('Analyze Data', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Settingpage()),
              );
            },
          ),
        ],
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Chart(onDataCalculated: updateChartData),
            const SizedBox(height: 20),
            Text(
              'Eaten on Time: ${completedPercent.toStringAsFixed(1)}%',
              style: const TextStyle(
                color: Colors.green,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Wasted Foods: ${expiredPercent.toStringAsFixed(1)}%',
              style: const TextStyle(
                color: Colors.red,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'In Process: ${inProgressPercent.toStringAsFixed(1)}%',
              style: const TextStyle(
                color: Colors.orangeAccent,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Top 3 Most Wasted Food Categories:',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...top3Categories.asMap().entries.map((entry) {
              final index = entry.key + 1;
              final category = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '$index. $category',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

class Chart extends StatefulWidget {
  final Function(double, double, double, List<String>) onDataCalculated;
  const Chart({super.key, required this.onDataCalculated});

  @override
  State<Chart> createState() => _ChartState();
}

class _ChartState extends State<Chart> {
  double completed = 0;
  double expired = 0;
  double inProgress = 0;

  @override
  void initState() {
    super.initState();
    calculateData();
  }

  Future<void> calculateData() async {
    final data = await DatabaseHelper.instance.fetchReminders();
    final now = DateTime.now();

    int total = data.length;
    int completedCount = 0;
    int expiredCount = 0;
    int inProgressCount = 0;

    Map<String, int> expiredCategoryCount = {};

    for (var r in data) {
      final status = r['status'];
      final expDate = DateTime.tryParse(r['expirationDate'] ?? '');
      final category = r['category'] ?? 'Unknown';

      if (status == 'completed') {
        completedCount++;
      } else if (expDate != null && expDate.isBefore(now)) {
        expiredCount++;
        expiredCategoryCount[category] = (expiredCategoryCount[category] ?? 0) + 1;
      } else {
        inProgressCount++;
      }
    }

    final totalSafe = total == 0 ? 1 : total.toDouble();
    final completedPercent = (completedCount / totalSafe) * 100;
    final expiredPercent = (expiredCount / totalSafe) * 100;
    final inProgressPercent = (inProgressCount / totalSafe) * 100;

    final sortedCategories = expiredCategoryCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top3 = sortedCategories.take(3).map((e) => e.key).toList();

    widget.onDataCalculated(
      completedPercent,
      expiredPercent,
      inProgressPercent,
      top3,
    );

    setState(() {
      completed = completedPercent;
      expired = expiredPercent;
      inProgress = inProgressPercent;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Text(
                  'For Week',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Center(
              child: SizedBox(
                height: 200,
                width: 200,
                child: SfRadialGauge(
                  axes: <RadialAxis>[
                    RadialAxis(
                      minimum: 0,
                      maximum: 100,
                      startAngle: 0,
                      endAngle: 360,
                      showTicks: false,
                      showLabels: false,
                      axisLineStyle: AxisLineStyle(
                        thickness: 0.25,
                        cornerStyle: CornerStyle.bothFlat,
                        color: Colors.grey.shade300,
                        thicknessUnit: GaugeSizeUnit.factor,
                      ),
                      pointers: <GaugePointer>[
                        RangePointer(
                          value: expired + inProgress + completed,
                          width: 0.25,
                          sizeUnit: GaugeSizeUnit.factor,
                          color: Colors.green,
                          cornerStyle: CornerStyle.bothFlat,
                        ),
                        RangePointer(
                          value: expired + inProgress,
                          width: 0.25,
                          sizeUnit: GaugeSizeUnit.factor,
                          color: Colors.orange,
                          cornerStyle: CornerStyle.bothFlat,
                        ),
                        RangePointer(
                          value: expired,
                          width: 0.25,
                          sizeUnit: GaugeSizeUnit.factor,
                          color: Colors.red,
                          cornerStyle: CornerStyle.bothFlat,
                        ),
                      ],
                      annotations: <GaugeAnnotation>[
                        GaugeAnnotation(
                          angle: 90,
                          positionFactor: 0.1,
                          widget: Text(
                            '${completed.toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

