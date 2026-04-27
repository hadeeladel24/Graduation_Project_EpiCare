// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';

// class StepsChart extends StatelessWidget {
//   const StepsChart({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     final padding = screenWidth * 0.05;
//     final iconSize = screenWidth * 0.06;
//     final containerSize = screenWidth * 0.12;
//     final titleFont = screenWidth * 0.045;
//     final subtitleFont = screenWidth * 0.032;
//     final chartHeight = screenHeight * 0.25;
//     final barWidth = screenWidth * 0.035;
//     final borderRadius = screenWidth * 0.015;

//     return Container(
//       padding: EdgeInsets.all(padding),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           begin: Alignment.topRight,
//           end: Alignment.bottomLeft,
//           colors: [Color(0xFFEFF6FF), Colors.white],
//         ),
//         borderRadius: BorderRadius.circular(borderRadius * 2),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header
//           Row(
//             children: [
//               Container(
//                 width: containerSize,
//                 height: containerSize,
//                 decoration: BoxDecoration(
//                   gradient: const LinearGradient(
//                     colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
//                   ),
//                   borderRadius: BorderRadius.circular(borderRadius * 2),
//                 ),
//                 child: Icon(
//                   Icons.directions_walk_rounded,
//                   color: Colors.white,
//                   size: iconSize,
//                 ),
//               ),
//               SizedBox(width: screenWidth * 0.03),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     "Weekly_steps".tr(),
//                     style: TextStyle(
//                       fontSize: titleFont,
//                       fontWeight: FontWeight.bold,
//                       color: const Color(0xFF111827),
//                     ),
//                   ),
//                   Text(
//                     "Statistics for the last 7 days".tr(),
//                     style: TextStyle(
//                       fontSize: subtitleFont,
//                       color: const Color(0xFF6B7280),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),

//           SizedBox(height: screenHeight * 0.03),

//           SizedBox(
//             height: chartHeight,
//             child: BarChart(
//               BarChartData(
//                 alignment: BarChartAlignment.spaceAround,
//                 maxY: 12000,
//                 barTouchData: BarTouchData(
//                   enabled: true,
//                   touchTooltipData: BarTouchTooltipData(
//                     getTooltipColor: (group) => const Color(0xFF2563EB),
//                     getTooltipItem: (group, groupIndex, rod, rodIndex) {
//                       return BarTooltipItem(
//                         '${rod.toY.toInt()}\n${"steps".tr()}',
//                         const TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 12,
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//                 titlesData: FlTitlesData(
//                   show: true,
//                   rightTitles: const AxisTitles(
//                     sideTitles: SideTitles(showTitles: false),
//                   ),
//                   topTitles: const AxisTitles(
//                     sideTitles: SideTitles(showTitles: false),
//                   ),
//                   bottomTitles: AxisTitles(
//                     sideTitles: SideTitles(
//                       showTitles: true,
//                       getTitlesWidget: (value, meta) {
//                         final days = [
//                           "saturday".tr(),
//                           "sunday".tr(),
//                           "monday".tr(),
//                           "tuesday".tr(),
//                           "wednesday".tr(),
//                           "thursday".tr(),
//                           "friday".tr()
//                         ];
//                         if (value.toInt() >= 0 && value.toInt() < days.length) {
//                           return Padding(
//                             padding: EdgeInsets.only(top: screenHeight * 0.005),
//                             child: Text(
//                               days[value.toInt()],
//                               style: TextStyle(
//                                 fontSize: subtitleFont,
//                                 color: const Color(0xFF6B7280),
//                               ),
//                             ),
//                           );
//                         }
//                         return const Text('');
//                       },
//                     ),
//                   ),
//                   leftTitles: AxisTitles(
//                     sideTitles: SideTitles(
//                       showTitles: true,
//                       reservedSize: 40,
//                       getTitlesWidget: (value, meta) {
//                         return Text(
//                           '${(value / 1000).toInt()}k',
//                           style: TextStyle(
//                             fontSize: subtitleFont,
//                             color: const Color(0xFF9CA3AF),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ),
//                 gridData: FlGridData(
//                   show: true,
//                   drawVerticalLine: false,
//                   horizontalInterval: 2000,
//                   getDrawingHorizontalLine: (value) {
//                     return FlLine(
//                       color: const Color(0xFFF3F4F6),
//                       strokeWidth: 1,
//                     );
//                   },
//                 ),
//                 borderData: FlBorderData(show: false),
//                 barGroups: [
//                   _buildBarGroup(0, 5234, barWidth, borderRadius),
//                   _buildBarGroup(1, 6789, barWidth, borderRadius),
//                   _buildBarGroup(2, 7234, barWidth, borderRadius),
//                   _buildBarGroup(3, 5678, barWidth, borderRadius),
//                   _buildBarGroup(4, 8123, barWidth, borderRadius),
//                   _buildBarGroup(5, 6890, barWidth, borderRadius),
//                   _buildBarGroup(6, 6543, barWidth, borderRadius),
//                 ],
//               ),
//             ),
//           ),

//           SizedBox(height: screenHeight * 0.025),

//           // Weekly summary
//           Container(
//             padding: EdgeInsets.all(screenWidth * 0.04),
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                 colors: [Color(0xFFDBEAFE), Color(0xFFEFF6FF)],
//               ),
//               borderRadius: BorderRadius.circular(borderRadius),
//               border: Border.all(color: const Color(0xFF93C5FD)),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 _buildWeeklyStat("total".tr(), '47,491', subtitleFont),
//                 Container(
//                   width: 1,
//                   height: screenHeight * 0.05,
//                   color: const Color(0xFF93C5FD),
//                 ),
//                 _buildWeeklyStat("average".tr(), '6,784', subtitleFont),
//                 Container(
//                   width: 1,
//                   height: screenHeight * 0.05,
//                   color: const Color(0xFF93C5FD),
//                 ),
//                 _buildWeeklyStat("the_highest".tr(), '8,123', subtitleFont),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   BarChartGroupData _buildBarGroup(int x, double y, double width, double borderRadius) {
//     return BarChartGroupData(
//       x: x,
//       barRods: [
//         BarChartRodData(
//           toY: y,
//           width: width,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(borderRadius)),
//           gradient: const LinearGradient(
//             begin: Alignment.bottomCenter,
//             end: Alignment.topCenter,
//             colors: [Color(0xFF2563EB), Color(0xFF60A5FA)],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildWeeklyStat(String label, String value, double fontSize) {
//     return Column(
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: fontSize,
//             color: const Color(0xFF1E40AF),
//           ),
//         ),
//         SizedBox(height: fontSize * 0.3),
//         Text(
//           value,
//           style: TextStyle(
//             fontSize: fontSize + 4,
//             fontWeight: FontWeight.bold,
//             color: const Color(0xFF1E3A8A),
//           ),
//         ),
//       ],
//     );
//   }
// }



import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:easy_localization/easy_localization.dart';

class StepsChart extends StatefulWidget {
  const StepsChart({super.key});

  @override
  State<StepsChart> createState() => _StepsChartState();
}

class _StepsChartState extends State<StepsChart> {
  final _db = FirebaseDatabase.instance.ref();
  final _auth = FirebaseAuth.instance;

  StreamSubscription<DatabaseEvent>? _sub;

  List<double> steps = List.filled(7, 0);

  int totalSteps = 0;
  int avgSteps = 0;
  int maxSteps = 0;

  bool loading = true;

  final daysKeys = const [
    "saturday",
    "sunday",
    "monday",
    "tuesday",
    "wednesday",
    "thursday",
    "friday",
  ];

  @override
  void initState() {
    super.initState();
    _listenToSteps();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  // ================= Firebase Listener =================
  void _listenToSteps() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    _sub?.cancel();
    setState(() => loading = true);

    _sub = _db.child("users/$uid/weeklyActivity").onValue.listen((event) {
      if (!event.snapshot.exists || event.snapshot.value == null) {
        setState(() {
          steps = List.filled(7, 0);
          totalSteps = avgSteps = maxSteps = 0;
          loading = false;
        });
        return;
      }

      final data = Map<String, dynamic>.from(event.snapshot.value as Map);

      final values = <double>[];

      for (int i = 0; i < daysKeys.length; i++) {
        final day = daysKeys[i];
        final v = data[day]?["steps"] ?? 0;
        final s = (v is int || v is double) ? v.toDouble() : 0.0;
        values.add(s);
      }

      final total = values.reduce((a, b) => a + b).toInt();
      final maxV = values.reduce(max).toInt();
      final avgV =
          values.isEmpty ? 0 : (total / values.length).round();

      setState(() {
        steps = values;
        totalSteps = total;
        maxSteps = maxV;
        avgSteps = avgV;
        loading = false;
      });
    });
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final hasData = steps.any((e) => e > 0);

    final padding = screenWidth * 0.05;
    final iconSize = screenWidth * 0.06;
    final containerSize = screenWidth * 0.12;
    final titleFont = screenWidth * 0.045;
    final subtitleFont = screenWidth * 0.032;
    final chartHeight = screenHeight * 0.25;
    final barWidth = screenWidth * 0.035;
    final borderRadius = screenWidth * 0.015;

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFFEFF6FF), Colors.white],
        ),
        borderRadius: BorderRadius.circular(borderRadius * 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ================= Header =================
          Row(
            children: [
              Container(
                width: containerSize,
                height: containerSize,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                  ),
                  borderRadius:
                      BorderRadius.circular(borderRadius * 2),
                ),
                child: Icon(
                  Icons.directions_walk_rounded,
                  color: Colors.white,
                  size: iconSize,
                ),
              ),
              SizedBox(width: screenWidth * 0.03),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Weekly_steps".tr(),
                    style: TextStyle(
                      fontSize: titleFont,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  Text(
                    "Statistics for the last 7 days".tr(),
                    style: TextStyle(
                      fontSize: subtitleFont,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: screenHeight * 0.03),

          // ================= Chart =================
          SizedBox(
            height: chartHeight,
            child: Stack(
              alignment: Alignment.center,
              children: [
                BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: maxSteps > 0 ? maxSteps * 1.2 : 10000,
                    barTouchData: BarTouchData(enabled: hasData),
                    titlesData: FlTitlesData(
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, _) {
                            if (value.toInt() >= 0 &&
                                value.toInt() < daysKeys.length) {
                              return Text(
                                daysKeys[value.toInt()].tr(),
                                style: TextStyle(
                                  fontSize: subtitleFont,
                                  color: const Color(0xFF6B7280),
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
                          getTitlesWidget: (value, _) {
                            return Text(
                              "${(value / 1000).toInt()}k",
                              style: TextStyle(
                                fontSize: subtitleFont,
                                color: const Color(0xFF9CA3AF),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 2000,
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(7, (i) {
                      return BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: steps[i],
                            width: barWidth,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(borderRadius),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: hasData
                                  ? const [
                                      Color(0xFF2563EB),
                                      Color(0xFF60A5FA),
                                    ]
                                  : [
                                      const Color(0xFF2563EB)
                                          .withOpacity(0.3),
                                      const Color(0xFF60A5FA)
                                          .withOpacity(0.3),
                                    ],
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),

                if (!hasData)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "no_steps_data".tr(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          SizedBox(height: screenHeight * 0.025),

          // ================= Summary =================
          Container(
            padding: EdgeInsets.all(screenWidth * 0.04),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFDBEAFE), Color(0xFFEFF6FF)],
              ),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: const Color(0xFF93C5FD)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _stat("total".tr(), totalSteps),
                _divider(screenHeight),
                _stat("average".tr(), avgSteps),
                _divider(screenHeight),
                _stat("the_highest".tr(), maxSteps),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider(double h) {
    return Container(width: 1, height: h * 0.05, color: const Color(0xFF93C5FD));
  }

  Widget _stat(String label, int value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF1E40AF))),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E3A8A),
          ),
        ),
      ],
    );
  }
}
