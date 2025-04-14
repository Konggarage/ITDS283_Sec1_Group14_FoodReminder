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

  void updateChartData(double completed, double expired, double inProgress) {
    setState(() {
      completedPercent = completed;
      expiredPercent = expired;
      inProgressPercent = inProgress;
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
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('1. Meat', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text(
              '2. Dairy products',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              '3. Fresh vegetables',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class Chart extends StatefulWidget {
  final Function(double, double, double) onDataCalculated;
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

    for (var r in data) {
      final status = r['status'];
      final expDate = DateTime.tryParse(r['expirationDate'] ?? '');

      if (status == 'completed') {
        completedCount++;
      } else if (expDate != null && expDate.isBefore(now)) {
        expiredCount++;
      } else {
        inProgressCount++;
      }
    }

    final totalSafe = total == 0 ? 1 : total.toDouble();
    final completedPercent = (completedCount / totalSafe) * 100;
    final expiredPercent = (expiredCount / totalSafe) * 100;
    final inProgressPercent = (inProgressCount / totalSafe) * 100;

    widget.onDataCalculated(
      completedPercent,
      expiredPercent,
      inProgressPercent,
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

// import 'package:flutter/material.dart';
// import 'package:myapp/pages/settingpage.dart';
// import 'package:syncfusion_flutter_gauges/gauges.dart';
// import 'package:myapp/Fooddatabase.dart';

// class Analyze extends StatelessWidget {
//   const Analyze({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.black,
//         iconTheme: const IconThemeData(color: Colors.white),

//         title: const Text(
//           'Analyze Data',
//           style: TextStyle(color: Colors.white),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.settings, color: Colors.white),
//             onPressed: () {
//               // Navigate to settings page
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => Settingpage()),
//               );
//             },
//           ),
//         ],
//       ),
//       backgroundColor: Colors.black,
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Chart(),
//             const Text(
//               'Eaten on Time: 85%',
//               style: TextStyle(
//                 color: Colors.green,
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 8),
//             const Text(
//               'Wasted Foods: 15%',
//               style: TextStyle(
//                 color: Colors.red,
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 20),
//             const Text(
//               'Top 3 Most Wasted Food Categories:',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 8),
//             const Text(
//               '1. Meat',
//               style: TextStyle(color: Colors.white70, fontSize: 18),
//             ),
//             const SizedBox(height: 4),
//             const Text(
//               '2. Dairy products',
//               style: TextStyle(color: Colors.white70, fontSize: 18),
//             ),
//             const SizedBox(height: 4),
//             const Text(
//               '3. Fresh vegetables',
//               style: TextStyle(color: Colors.white70, fontSize: 18),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class Chart extends StatefulWidget {
//   const Chart({super.key});
//   @override
//   _ChartState createState() => _ChartState();
// }

// @override
// class _ChartState extends State<Chart> {
//   Widget build(BuildContext context) {
//     return Card(
//       color: Colors.white,
//       surfaceTintColor: Colors.yellowAccent,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Text(
//                   'For Week',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//                 ),
//               ],
//             ),
//             SizedBox(height: 10),

//             // SfRadialGauge(
//             // axes: [
//             //   RadialAxis(
//             //     radiusFactor: 0.65,
//             //     axisLineStyle:
//             //     AxisLineStyle(thickness: 25, color: Colors.orange.shade200),
//             //     startAngle: 270,
//             //     endAngle: 270,
//             //     showLabels: false,
//             //     showTicks: false,
//             //     annotations: [
//             //       GaugeAnnotation(widget: Text('73%',style: TextStyle(fontWeight: FontWeight.w600,color: Colors.black,fontSize: 24),),
//             //       angle: 270,
//             //       positionFactor: 0.1,
//             //       )
//             //     ],
//             //   ),
//             //   RadialAxis(
//             //     radiusFactor: 0.8,
//             //     pointers: [
//             //       RangePointer(
//             //         value: 50,
//             //         color:  Colors.lightBlueAccent,
//             //         width: 50,
//             //       )
//             //     ],
//             //     startAngle: 270,
//             //     endAngle: 270,
//             //     showLabels: false,
//             //     showTicks: false,
//             //     showAxisLine: false,
//             //   ),
//             //   RadialAxis(
//             //     radiusFactor: 0.65,
//             //     pointers: [
//             //       RangePointer(
//             //         value: 20,
//             //         color:  const Color.fromARGB(255, 65, 149, 90),
//             //         width: 30,
//             //       )
//             //     ],
//             //     startAngle: 90,
//             //     endAngle: 50,
//             //     showLabels: false,
//             //     showTicks: false,
//             //     showAxisLine: false,
//             //   )
//             // ],
//             // ),

//             // SfRadialGauge(
//             //   axes: <RadialAxis>[
//             //     RadialAxis(
//             //       minimum: 0,
//             //       maximum: 100,
//             //       startAngle: 5,
//             //       endAngle: 5,
//             //       showTicks: false,
//             //       showLabels: false,
//             //       axisLineStyle: AxisLineStyle(
//             //         thickness: 0.2,
//             //         cornerStyle: CornerStyle.bothCurve,
//             //         color: Colors.grey.shade300,
//             //         thicknessUnit: GaugeSizeUnit.factor,
//             //       ),
//             //       pointers: <GaugePointer>[
//             //         RangePointer(
//             //           value: 70,
//             //           cornerStyle: CornerStyle.bothCurve,
//             //           width: 0.2,
//             //           sizeUnit: GaugeSizeUnit.factor,
//             //           gradient: const SweepGradient(
//             //             colors: <Color>[Colors.deepOrange, Colors.amber],
//             //           ),
//             //         ),
//             //       ],
//             //       annotations: <GaugeAnnotation>[
//             //         GaugeAnnotation(
//             //           widget: const Text(
//             //             '70%',
//             //             style: TextStyle(
//             //               fontSize: 20,
//             //               fontWeight: FontWeight.bold,
//             //             ),
//             //           ),
//             //           angle: 270,
//             //           positionFactor: 0.1,
//             //         ),
//             //       ],
//             //     ),
//             //   ],
//             // ),
//             Center(
//   child: SizedBox(
//     height: 200,
//     width: 200, // 👈 ให้เท่ากัน 100%
//     child: SfRadialGauge(
//       axes: <RadialAxis>[
//         RadialAxis(
//           minimum: 0,
//           maximum: 100,
//           startAngle: 0,
//           endAngle: 360,
//           showTicks: false,
//           showLabels: false,
//           axisLineStyle: AxisLineStyle(
//             thickness: 0.25,
//             cornerStyle: CornerStyle.bothFlat,
//             color: Colors.grey.shade300,
//             thicknessUnit: GaugeSizeUnit.factor,
//           ),
//           pointers: <GaugePointer>[
//             RangePointer(
//               value: 70,
//               width: 0.25,
//               sizeUnit: GaugeSizeUnit.factor,
//               cornerStyle: CornerStyle.bothCurve,
//               gradient: SweepGradient(
//                 colors: [Colors.amber, Colors.deepOrange],
//                 stops: [0.0, 1.0],
//               ),
//             ),
//           ],
//           annotations: <GaugeAnnotation>[
//             GaugeAnnotation(
//               angle: 90,
//               positionFactor: 0.1,
//               widget: Text(
//                 '70%',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ],
//     ),
//   ),
// )

//           ],
//         ),
//       ),
//     );
//   }
// }
