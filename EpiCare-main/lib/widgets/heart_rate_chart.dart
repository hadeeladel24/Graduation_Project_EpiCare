// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:easy_localization/easy_localization.dart';

// class HeartRateChart extends StatefulWidget {
//   const HeartRateChart({super.key});

//   @override
//   State<HeartRateChart> createState() => _HeartRateChartState();
// }

// class _HeartRateChartState extends State<HeartRateChart> {
//   final List<FlSpot> heartRateData = const [
//     FlSpot(0, 65),
//     FlSpot(1, 62),
//     FlSpot(2, 70),
//     FlSpot(3, 75),
//     FlSpot(4, 78),
//     FlSpot(5, 72),
//     FlSpot(6, 68),
//   ];

//   final List<String> timeLabels = [
//     '00:00',
//     '04:00',
//     '08:00',
//     '12:00',
//     '16:00',
//     '20:00',
//     '23:59'
//   ];

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     // ======= أحجام نسبية =======
//     final padding = screenWidth * 0.05;
//     final iconSize = screenWidth * 0.12;
//     final iconRadius = iconSize * 0.5;
//     final spacingSmall = screenHeight * 0.015;
//     final spacingMedium = screenHeight * 0.02;
//     final headerFontSize = screenWidth * 0.045;
//     final subHeaderFontSize = screenWidth * 0.03;
//     final legendFontSize = screenWidth * 0.035;
//     final chartHeight = screenHeight * 0.3;
//     final statIconSize = screenWidth * 0.09;
//     final statIconRadius = statIconSize * 0.5;
//     final statLabelFontSize = screenWidth * 0.03;
//     final statValueFontSize = screenWidth * 0.05;
//     final statUnitFontSize = screenWidth * 0.025;

//     return Container(
//       padding: EdgeInsets.all(padding),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           begin: Alignment.topRight,
//           end: Alignment.bottomLeft,
//           colors: [Color(0xFFFEF2F2), Colors.white],
//         ),
//         borderRadius: BorderRadius.circular(screenWidth * 0.05),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
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
//                 width: iconSize,
//                 height: iconSize,
//                 decoration: BoxDecoration(
//                   gradient: const LinearGradient(
//                     colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
//                   ),
//                   borderRadius: BorderRadius.circular(iconRadius),
//                   boxShadow: [
//                     BoxShadow(
//                       color: const Color(0xFFEF4444).withOpacity(0.3),
//                       blurRadius: 8,
//                       offset: const Offset(0, 4),
//                     ),
//                   ],
//                 ),
//                 child: Center(
//                   child: Text(
//                     '❤️',
//                     style: TextStyle(fontSize: iconSize * 0.5),
//                   ),
//                 ),
//               ),
//               SizedBox(width: screenWidth * 0.03),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'heart_rate_today'.tr(),
//                       style: TextStyle(
//                         fontSize: headerFontSize,
//                         fontWeight: FontWeight.bold,
//                         color: const Color(0xFF111827),
//                       ),
//                     ),
//                     SizedBox(height: screenHeight * 0.003),
//                     Text(
//                       'live_readings_hourly'.tr(),
//                       style: TextStyle(
//                         fontSize: subHeaderFontSize,
//                         color: const Color(0xFF6B7280),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),

//           SizedBox(height: spacingMedium),

//           // Legend
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Row(
//                 children: [
//                   Container(
//                     width: iconSize * 0.25,
//                     height: iconSize * 0.25,
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFEF4444),
//                       shape: BoxShape.circle,
//                       boxShadow: [
//                         BoxShadow(
//                           color: const Color(0xFFEF4444).withOpacity(0.3),
//                           blurRadius: 4,
//                           spreadRadius: 1,
//                         ),
//                       ],
//                     ),
//                   ),
//                   SizedBox(width: screenWidth * 0.02),
//                   Text(
//                     'live_reading'.tr(),
//                     style: TextStyle(
//                       fontSize: legendFontSize,
//                       color: const Color(0xFF6B7280),
//                     ),
//                   ),
//                 ],
//               ),
//               Container(
//                 padding: EdgeInsets.symmetric(
//                     horizontal: screenWidth * 0.03, vertical: screenHeight * 0.005),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFD1FAE5),
//                   borderRadius: BorderRadius.circular(screenWidth * 0.015),
//                   border: Border.all(
//                     color: const Color(0xFF6EE7B7),
//                     width: 1,
//                   ),
//                 ),
//                 child: Text(
//                   'rate_normal'.tr(),
//                   style: TextStyle(
//                     fontSize: subHeaderFontSize,
//                     color: const Color(0xFF065F46),
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ],
//           ),

//           SizedBox(height: spacingMedium),

//           // Chart
//           SizedBox(
//             height: chartHeight,
//             child: Padding(
//               padding: EdgeInsets.only(right: screenWidth * 0.02, top: screenHeight * 0.01),
//               child: LineChart(
//                 LineChartData(
//                   minX: 0,
//                   maxX: 6,
//                   minY: 50,
//                   maxY: 90,
//                   gridData: FlGridData(
//                     show: true,
//                     drawVerticalLine: false,
//                     horizontalInterval: 10,
//                     getDrawingHorizontalLine: (value) => FlLine(
//                       color: const Color(0xFFF3F4F6),
//                       strokeWidth: 1,
//                       dashArray: [5, 5],
//                     ),
//                   ),
//                   titlesData: FlTitlesData(
//                     rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                     topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                     bottomTitles: AxisTitles(
//                       sideTitles: SideTitles(
//                         showTitles: true,
//                         reservedSize: screenHeight * 0.04,
//                         interval: 1,
//                         getTitlesWidget: (value, meta) {
//                           final index = value.toInt();
//                           if (index >= 0 && index < timeLabels.length) {
//                             return Padding(
//                               padding: EdgeInsets.only(top: screenHeight * 0.01),
//                               child: Text(
//                                 timeLabels[index],
//                                 style: TextStyle(
//                                   fontSize: legendFontSize,
//                                   color: const Color(0xFF9CA3AF),
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             );
//                           }
//                           return const Text('');
//                         },
//                       ),
//                     ),
//                     leftTitles: AxisTitles(
//                       sideTitles: SideTitles(
//                         showTitles: true,
//                         reservedSize: screenWidth * 0.11,
//                         interval: 10,
//                         getTitlesWidget: (value, meta) => Padding(
//                           padding: EdgeInsets.only(right: screenWidth * 0.01),
//                           child: Text(
//                             value.toInt().toString(),
//                             style: TextStyle(
//                               fontSize: legendFontSize,
//                               color: const Color(0xFF9CA3AF),
//                               fontWeight: FontWeight.w500,
//                             ),
//                             textAlign: TextAlign.center,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   borderData: FlBorderData(show: false),
//                   lineBarsData: [
//                     LineChartBarData(
//                       spots: heartRateData,
//                       isCurved: true,
//                       curveSmoothness: 0.4,
//                       color: const Color(0xFFEF4444),
//                       barWidth: screenWidth * 0.015,
//                       isStrokeCapRound: true,
//                       dotData: FlDotData(
//                         show: true,
//                         getDotPainter: (spot, percent, barData, index) =>
//                             FlDotCirclePainter(
//                           radius: screenWidth * 0.015,
//                           color: const Color(0xFFEF4444),
//                           strokeWidth: screenWidth * 0.007,
//                           strokeColor: Colors.white,
//                         ),
//                       ),
//                       belowBarData: BarAreaData(
//                         show: true,
//                         gradient: LinearGradient(
//                           begin: Alignment.topCenter,
//                           end: Alignment.bottomCenter,
//                           colors: [
//                             const Color(0xFFEF4444).withOpacity(0.3),
//                             const Color(0xFFEF4444).withOpacity(0.1),
//                             const Color(0xFFEF4444).withOpacity(0.0),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                   lineTouchData: LineTouchData(
//                     enabled: true,
//                     handleBuiltInTouches: true,
//                   ),
//                 ),
//               ),
//             ),
//           ),

//           SizedBox(height: spacingMedium),

//           // Statistics
//           Container(
//             padding: EdgeInsets.all(screenWidth * 0.04),
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                 colors: [Color(0xFFFEF2F2), Color(0xFFFEE2E2)],
//               ),
//               borderRadius: BorderRadius.circular(screenWidth * 0.03),
//               border: Border.all(
//                 color: const Color(0xFFFECACA),
//                 width: 1,
//               ),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 _buildStat(
//                   'minimum'.tr(),
//                   '62',
//                   'bpm'.tr(),
//                   Icons.trending_down_rounded,
//                   statIconSize,
//                   statIconRadius,
//                   statLabelFontSize,
//                   statValueFontSize,
//                   statUnitFontSize,
//                 ),
//                 Container(
//                   width: 1,
//                   height: screenHeight * 0.06,
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.topCenter,
//                       end: Alignment.bottomCenter,
//                       colors: [
//                         const Color(0xFFFCA5A5).withOpacity(0.0),
//                         const Color(0xFFFCA5A5),
//                         const Color(0xFFFCA5A5).withOpacity(0.0),
//                       ],
//                     ),
//                   ),
//                 ),
//                 _buildStat(
//                   'average'.tr(),
//                   '70',
//                   'bpm'.tr(),
//                   Icons.favorite_rounded,
//                   statIconSize,
//                   statIconRadius,
//                   statLabelFontSize,
//                   statValueFontSize,
//                   statUnitFontSize,
//                 ),
//                 Container(
//                   width: 1,
//                   height: screenHeight * 0.06,
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.topCenter,
//                       end: Alignment.bottomCenter,
//                       colors: [
//                         const Color(0xFFFCA5A5).withOpacity(0.0),
//                         const Color(0xFFFCA5A5),
//                         const Color(0xFFFCA5A5).withOpacity(0.0),
//                       ],
//                     ),
//                   ),
//                 ),
//                 _buildStat(
//                   'maximum'.tr(),
//                   '78',
//                   'bpm'.tr(),
//                   Icons.trending_up_rounded,
//                   statIconSize,
//                   statIconRadius,
//                   statLabelFontSize,
//                   statValueFontSize,
//                   statUnitFontSize,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStat(
//     String label,
//     String value,
//     String unit,
//     IconData icon,
//     double iconSize,
//     double iconRadius,
//     double labelFontSize,
//     double valueFontSize,
//     double unitFontSize,
//   ) {
//     return Column(
//       children: [
//         Container(
//           width: iconSize,
//           height: iconSize,
//           decoration: BoxDecoration(
//             gradient: const LinearGradient(
//               colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
//             ),
//             shape: BoxShape.circle,
//             boxShadow: [
//               BoxShadow(
//                 color: const Color(0xFFEF4444).withOpacity(0.3),
//                 blurRadius: 6,
//                 offset: const Offset(0, 3),
//               ),
//             ],
//           ),
//           child: Icon(
//             icon,
//             color: Colors.white,
//             size: iconSize * 0.5,
//           ),
//         ),
//         SizedBox(height: iconSize * 0.15),
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: labelFontSize,
//             color: const Color(0xFF991B1B),
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         SizedBox(height: iconSize * 0.05),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.end,
//           children: [
//             Text(
//               value,
//               style: TextStyle(
//                 fontSize: valueFontSize,
//                 fontWeight: FontWeight.bold,
//                 color: const Color(0xFF7F1D1D),
//                 height: 1,
//               ),
//             ),
//             SizedBox(width: iconSize * 0.03),
//             Padding(
//               padding: EdgeInsets.only(bottom: iconSize * 0.06),
//               child: Text(
//                 unit,
//                 style: TextStyle(
//                   fontSize: unitFontSize,
//                   color: const Color(0xFF991B1B),
//                   height: 1,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }




















// import 'dart:async';
// import 'dart:math';

// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:easy_localization/easy_localization.dart';

// enum HeartRateRange { today, last24h }

// class HeartRateChart extends StatefulWidget {
//   const HeartRateChart({super.key});

//   @override
//   State<HeartRateChart> createState() => _HeartRateChartState();
// }

// class _HeartRateChartState extends State<HeartRateChart> {
//   final _db = FirebaseDatabase.instance.ref();
//   final _auth = FirebaseAuth.instance;

//   StreamSubscription<DatabaseEvent>? _sub;

//   HeartRateRange selectedRange = HeartRateRange.today;

//   List<FlSpot> heartRateData = [];
//   List<String> timeLabels = [];

//   int minHR = 0;
//   int maxHR = 0;
//   int avgHR = 0;

//   bool loading = true;

//   final List<FlSpot> _placeholderSpots = const [
//     FlSpot(0, 0),
//     FlSpot(1, 0),
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _listenToHeartRate();
//   }

//   @override
//   void dispose() {
//     _sub?.cancel();
//     super.dispose();
//   }

//   // ================= Firebase Listener =================
//   void _listenToHeartRate() {
//     final uid = _auth.currentUser?.uid;
//     if (uid == null) return;

//     _sub?.cancel();
//     setState(() => loading = true);

//     DatabaseReference ref;

//     if (selectedRange == HeartRateRange.today) {
//       final today = DateTime.now().toString().split(' ').first;
//       ref = _db.child("users/$uid/heartRateHistory/$today");
//     } else {
//       ref = _db.child("users/$uid/heartRateHistory");
//     }

//     _sub = ref.onValue.listen((event) {
//       if (!event.snapshot.exists || event.snapshot.value == null) {
//         setState(() {
//           heartRateData = [];
//           timeLabels = [];
//           minHR = maxHR = avgHR = 0;
//           loading = false;
//         });
//         return;
//       }

//       _processSnapshot(event.snapshot);
//     });
//   }

//   // ================= Data Processing =================
//   void _processSnapshot(DataSnapshot snapshot) {
//     final List<_HRPoint> points = [];
//     final now = DateTime.now();

//     if (selectedRange == HeartRateRange.today) {
//       final data = Map<String, dynamic>.from(snapshot.value as Map);
//       data.forEach((_, v) {
//         _extractPoint(Map<String, dynamic>.from(v), points);
//       });
//     } else {
//       final days = Map<String, dynamic>.from(snapshot.value as Map);
//       days.forEach((_, dayMap) {
//         final readings = Map<String, dynamic>.from(dayMap);
//         readings.forEach((__, v) {
//           final map = Map<String, dynamic>.from(v);
//           final ts = DateTime.tryParse(map["timestamp"] ?? "");
//           if (ts != null && now.difference(ts).inHours <= 24) {
//             _extractPoint(map, points);
//           }
//         });
//       });
//     }

//     points.sort((a, b) => a.time.compareTo(b.time));

//     final sampled =
//         points.length > 12 ? points.sublist(points.length - 12) : points;

//     final spots = <FlSpot>[];
//     final labels = <String>[];

//     for (int i = 0; i < sampled.length; i++) {
//       spots.add(FlSpot(i.toDouble(), sampled[i].hr));
//       labels.add(
//         "${sampled[i].time.hour.toString().padLeft(2, '0')}:${sampled[i].time.minute.toString().padLeft(2, '0')}",
//       );
//     }

//     final values = sampled.map((e) => e.hr).toList();

//     setState(() {
//       heartRateData = spots;
//       timeLabels = labels;
//       minHR = values.isEmpty ? 0 : values.reduce(min).toInt();
//       maxHR = values.isEmpty ? 0 : values.reduce(max).toInt();
//       avgHR = values.isEmpty
//           ? 0
//           : (values.reduce((a, b) => a + b) / values.length).round();
//       loading = false;
//     });
//   }

//   void _extractPoint(Map<String, dynamic> data, List<_HRPoint> points) {
//     final rawHr = data["hr"] ?? data["heartRate"];
//     final hr =
//         (rawHr is int || rawHr is double) ? rawHr.toDouble() : 0.0;
//     final ts = DateTime.tryParse(data["timestamp"] ?? "");

//     if (hr > 0 && ts != null) {
//       points.add(_HRPoint(ts, hr));
//     }
//   }

//   // ================= UI (نفس القديم) =================
//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     if (loading) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     final hasData = heartRateData.isNotEmpty;
//     final chartSpots = hasData ? heartRateData : _placeholderSpots;

//     // ======= نفس القياسات القديمة =======
//     final iconSize = screenWidth * 0.12;
//     final iconRadius = iconSize * 0.5;
//     final headerFontSize = screenWidth * 0.045;
//     final subHeaderFontSize = screenWidth * 0.03;
//     final legendFontSize = screenWidth * 0.035;
//     final chartHeight = screenHeight * 0.3;

//     return Container(
//       padding: EdgeInsets.all(screenWidth * 0.05),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           begin: Alignment.topRight,
//           end: Alignment.bottomLeft,
//           colors: [Color(0xFFFEF2F2), Colors.white],
//         ),
//         borderRadius: BorderRadius.circular(screenWidth * 0.05),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // ===== Header (نفس القديم) =====
//           Row(
//             children: [
//               Container(
//                 width: iconSize,
//                 height: iconSize,
//                 decoration: BoxDecoration(
//                   gradient: const LinearGradient(
//                     colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
//                   ),
//                   borderRadius: BorderRadius.circular(iconRadius),
//                 ),
//                 child: Center(
//                   child: Text(
//                     '❤️',
//                     style: TextStyle(fontSize: iconSize * 0.5),
//                   ),
//                 ),
//               ),
//               SizedBox(width: screenWidth * 0.03),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'heart_rate_today'.tr(),
//                       style: TextStyle(
//                         fontSize: headerFontSize,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     Text(
//                       selectedRange == HeartRateRange.today
//                           ? 'live_readings_hourly'.tr()
//                           : 'last_24_hours'.tr(),
//                       style: TextStyle(
//                         fontSize: subHeaderFontSize,
//                         color: const Color(0xFF6B7280),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               DropdownButton<HeartRateRange>(
//                 value: selectedRange,
//                 underline: const SizedBox(),
//                 items: [
//                   DropdownMenuItem(
//                     value: HeartRateRange.today,
//                     child: Text("today".tr()),
//                   ),
//                   DropdownMenuItem(
//                     value: HeartRateRange.last24h,
//                     child: Text("last_24_hours".tr()),
//                   ),
//                 ],
//                 onChanged: (v) {
//                   if (v == null) return;
//                   setState(() => selectedRange = v);
//                   _listenToHeartRate();
//                 },
//               ),
//             ],
//           ),

//           SizedBox(height: screenHeight * 0.02),

//           // ===== Chart (نفس القديم + overlay) =====
//           SizedBox(
//             height: chartHeight,
//             child: Stack(
//               alignment: Alignment.center,
//               children: [
//                 LineChart(
//                   LineChartData(
//                     minX: 0,
//                     maxX: chartSpots.length - 1,
//                     minY: 40,
//                     maxY: 140,
//                     gridData: FlGridData(show: true),
//                     titlesData: FlTitlesData(
//                       rightTitles: const AxisTitles(
//                           sideTitles: SideTitles(showTitles: false)),
//                       topTitles: const AxisTitles(
//                           sideTitles: SideTitles(showTitles: false)),
//                       bottomTitles: AxisTitles(
//                         sideTitles: SideTitles(
//                           showTitles: hasData,
//                           getTitlesWidget: (value, _) {
//                             final i = value.toInt();
//                             if (i >= 0 && i < timeLabels.length) {
//                               return Text(
//                                 timeLabels[i],
//                                 style: TextStyle(fontSize: legendFontSize),
//                               );
//                             }
//                             return const Text('');
//                           },
//                         ),
//                       ),
//                       leftTitles: AxisTitles(
//                         sideTitles: SideTitles(
//                           showTitles: true,
//                           interval: 20,
//                           getTitlesWidget: (value, _) =>
//                               Text(value.toInt().toString()),
//                         ),
//                       ),
//                     ),
//                     borderData: FlBorderData(show: false),
//                     lineBarsData: [
//                       LineChartBarData(
//                         spots: chartSpots,
//                         isCurved: true,
//                         color: const Color(0xFFEF4444)
//                             .withOpacity(hasData ? 1 : 0.3),
//                         barWidth: screenWidth * 0.015,
//                         dotData: FlDotData(show: hasData),
//                         belowBarData: BarAreaData(show: hasData),
//                       ),
//                     ],
//                   ),
//                 ),

//                 if (!hasData)
//                   Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.85),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Text(
//                       "no_heart_rate_data".tr(),
//                       style: const TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w600,
//                         color: Color(0xFF6B7280),
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),

//           SizedBox(height: screenHeight * 0.02),

//           // ===== Stats (نفس القديم بس ديناميكي) =====
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               _stat('minimum'.tr(), minHR),
//               _stat('average'.tr(), avgHR),
//               _stat('maximum'.tr(), maxHR),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _stat(String label, int value) {
//     return Column(
//       children: [
//         Text(label, style: const TextStyle(fontSize: 12)),
//         const SizedBox(height: 4),
//         Text(
//           "$value bpm",
//           style: const TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ],
//     );
//   }
// }

// // ================= Helper =================
// class _HRPoint {
//   final DateTime time;
//   final double hr;
//   _HRPoint(this.time, this.hr);
// }




















import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:easy_localization/easy_localization.dart';

enum HeartRateRange { today, last24h }

class HeartRateChart extends StatefulWidget {
  const HeartRateChart({super.key});

  @override
  State<HeartRateChart> createState() => _HeartRateChartState();
}

class _HeartRateChartState extends State<HeartRateChart> {
  final _db = FirebaseDatabase.instance.ref();
  final _auth = FirebaseAuth.instance;

  StreamSubscription<DatabaseEvent>? _sub;

  HeartRateRange selectedRange = HeartRateRange.today;

  List<FlSpot> heartRateData = [];
  List<String> timeLabels = [];

  int minHR = 0;
  int maxHR = 0;
  int avgHR = 0;

  bool loading = true;

  // Placeholder (نفس القياسات بدون داتا)
  final List<FlSpot> _placeholderSpots = const [
    FlSpot(0, 0),
    FlSpot(1, 0),
  ];

  @override
  void initState() {
    super.initState();
    _listenToHeartRate();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  // ================= Firebase Listener =================
  void _listenToHeartRate() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    _sub?.cancel();
    setState(() => loading = true);

    DatabaseReference ref;

    if (selectedRange == HeartRateRange.today) {
      final today = DateTime.now().toString().split(' ').first;
      ref = _db.child("users/$uid/heartRateHistory/$today");
    } else {
      ref = _db.child("users/$uid/heartRateHistory");
    }

    _sub = ref.onValue.listen((event) {
      if (!event.snapshot.exists || event.snapshot.value == null) {
        setState(() {
          heartRateData = [];
          timeLabels = [];
          minHR = maxHR = avgHR = 0;
          loading = false;
        });
        return;
      }

      _processSnapshot(event.snapshot);
    });
  }

  // ================= Data Processing =================
  void _processSnapshot(DataSnapshot snapshot) {
    final List<_HRPoint> points = [];
    final now = DateTime.now();

    if (selectedRange == HeartRateRange.today) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      data.forEach((_, v) {
        _extractPoint(Map<String, dynamic>.from(v), points);
      });
    } else {
      final days = Map<String, dynamic>.from(snapshot.value as Map);
      days.forEach((_, dayMap) {
        final readings = Map<String, dynamic>.from(dayMap);
        readings.forEach((__, v) {
          final map = Map<String, dynamic>.from(v);
          final ts = DateTime.tryParse(map["timestamp"] ?? "");
          if (ts != null && now.difference(ts).inHours <= 24) {
            _extractPoint(map, points);
          }
        });
      });
    }

    points.sort((a, b) => a.time.compareTo(b.time));

    // Sampling: آخر 12 قراءة
    final sampled =
        points.length > 12 ? points.sublist(points.length - 12) : points;

    final spots = <FlSpot>[];
    final labels = <String>[];

    for (int i = 0; i < sampled.length; i++) {
      spots.add(FlSpot(i.toDouble(), sampled[i].hr));
      labels.add(
        "${sampled[i].time.hour.toString().padLeft(2, '0')}:${sampled[i].time.minute.toString().padLeft(2, '0')}",
      );
    }

    final values = sampled.map((e) => e.hr).toList();

    setState(() {
      heartRateData = spots;
      timeLabels = labels;
      minHR = values.isEmpty ? 0 : values.reduce(min).toInt();
      maxHR = values.isEmpty ? 0 : values.reduce(max).toInt();
      avgHR = values.isEmpty
          ? 0
          : (values.reduce((a, b) => a + b) / values.length).round();
      loading = false;
    });
  }

  void _extractPoint(Map<String, dynamic> data, List<_HRPoint> points) {
    final rawHr = data["hr"] ?? data["heartRate"];
    final hr =
        (rawHr is int || rawHr is double) ? rawHr.toDouble() : 0.0;
    final ts = DateTime.tryParse(data["timestamp"] ?? "");

    if (hr > 0 && ts != null) {
      points.add(_HRPoint(ts, hr));
    }
  }

  // ================= UI (نسخ لصق من القديم) =================
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final hasData = heartRateData.isNotEmpty;
    final chartSpots = hasData ? heartRateData : _placeholderSpots;

    // ======= نفس القياسات القديمة =======
    final padding = screenWidth * 0.05;
    final iconSize = screenWidth * 0.12;
    final iconRadius = iconSize * 0.5;
    final spacingMedium = screenHeight * 0.02;
    final headerFontSize = screenWidth * 0.045;
    final subHeaderFontSize = screenWidth * 0.03;
    final legendFontSize = screenWidth * 0.035;
    final chartHeight = screenHeight * 0.3;
    final statIconSize = screenWidth * 0.09;
    final statIconRadius = statIconSize * 0.5;
    final statLabelFontSize = screenWidth * 0.03;
    final statValueFontSize = screenWidth * 0.05;
    final statUnitFontSize = screenWidth * 0.025;

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFFFEF2F2), Colors.white],
        ),
        borderRadius: BorderRadius.circular(screenWidth * 0.05),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                width: iconSize,
                height: iconSize,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                  ),
                  borderRadius: BorderRadius.circular(iconRadius),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFEF4444).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '❤️',
                    style: TextStyle(fontSize: iconSize * 0.5),
                  ),
                ),
              ),
              SizedBox(width: screenWidth * 0.03),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'heart_rate_today'.tr(),
                      style: TextStyle(
                        fontSize: headerFontSize,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    Text(
                      selectedRange == HeartRateRange.today
                          ? 'live_readings_hourly'.tr()
                          : 'last_24_hours'.tr(),
                      style: TextStyle(
                        fontSize: subHeaderFontSize,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              DropdownButton<HeartRateRange>(
                value: selectedRange,
                underline: const SizedBox(),
                items: [
                  DropdownMenuItem(
                    value: HeartRateRange.today,
                    child: Text("today".tr()),
                  ),
                  DropdownMenuItem(
                    value: HeartRateRange.last24h,
                    child: Text("last_24_hours".tr()),
                  ),
                ],
                onChanged: (v) {
                  if (v == null) return;
                  setState(() => selectedRange = v);
                  _listenToHeartRate();
                },
              ),
            ],
          ),

          SizedBox(height: spacingMedium),

          // ================= Legend =================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: iconSize * 0.25,
                    height: iconSize * 0.25,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  Text(
                    'live_reading'.tr(),
                    style: TextStyle(
                      fontSize: legendFontSize,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.03,
                  vertical: screenHeight * 0.005,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(screenWidth * 0.015),
                  border: Border.all(color: const Color(0xFF6EE7B7)),
                ),
                child: Text(
                  'rate_normal'.tr(),
                  style: TextStyle(
                    fontSize: subHeaderFontSize,
                    color: const Color(0xFF065F46),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: spacingMedium),

          // ================= Chart =================
          SizedBox(
            height: chartHeight,
            child: Stack(
              alignment: Alignment.center,
              children: [
                LineChart(
                  LineChartData(
                    minX: 0,
                    maxX: chartSpots.length - 1,
                    minY: 50,
                    maxY: 90,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 10,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: const Color(0xFFF3F4F6),
                        strokeWidth: 1,
                        dashArray: [5, 5],
                      ),
                    ),
                    titlesData: FlTitlesData(
                      rightTitles:
                          const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles:
                          const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: hasData,
                          interval: 1,
                          getTitlesWidget: (value, _) {
                            final i = value.toInt();
                            if (i >= 0 && i < timeLabels.length) {
                              return Padding(
                                padding:
                                    EdgeInsets.only(top: screenHeight * 0.01),
                                child: Text(
                                  timeLabels[i],
                                  style: TextStyle(
                                    fontSize: legendFontSize,
                                    color: const Color(0xFF9CA3AF),
                                    fontWeight: FontWeight.w500,
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
                          interval: 10,
                          getTitlesWidget: (value, _) => Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              fontSize: legendFontSize,
                              color: const Color(0xFF9CA3AF),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: chartSpots,
                        isCurved: true,
                        curveSmoothness: 0.4,
                        color: const Color(0xFFEF4444)
                            .withOpacity(hasData ? 1 : 0.3),
                        barWidth: screenWidth * 0.015,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: hasData,
                          getDotPainter: (spot, percent, barData, index) =>
                              FlDotCirclePainter(
                            radius: screenWidth * 0.015,
                            color: const Color(0xFFEF4444),
                            strokeWidth: screenWidth * 0.007,
                            strokeColor: Colors.white,
                          ),
                        ),
                        belowBarData: BarAreaData(
                          show: hasData,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              const Color(0xFFEF4444).withOpacity(0.3),
                              const Color(0xFFEF4444).withOpacity(0.1),
                              const Color(0xFFEF4444).withOpacity(0.0),
                            ],
                          ),
                        ),
                      ),
                    ],
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
                      "no_heart_rate_data".tr(),
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

          SizedBox(height: spacingMedium),

          // ================= Statistics =================
          Container(
            padding: EdgeInsets.all(screenWidth * 0.04),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFEF2F2), Color(0xFFFEE2E2)],
              ),
              borderRadius: BorderRadius.circular(screenWidth * 0.03),
              border: Border.all(color: const Color(0xFFFECACA)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStat(
                  'minimum'.tr(),
                  minHR.toString(),
                  'bpm'.tr(),
                  Icons.trending_down_rounded,
                  statIconSize,
                  statIconRadius,
                  statLabelFontSize,
                  statValueFontSize,
                  statUnitFontSize,
                ),
                _divider(screenHeight),
                _buildStat(
                  'average'.tr(),
                  avgHR.toString(),
                  'bpm'.tr(),
                  Icons.favorite_rounded,
                  statIconSize,
                  statIconRadius,
                  statLabelFontSize,
                  statValueFontSize,
                  statUnitFontSize,
                ),
                _divider(screenHeight),
                _buildStat(
                  'maximum'.tr(),
                  maxHR.toString(),
                  'bpm'.tr(),
                  Icons.trending_up_rounded,
                  statIconSize,
                  statIconRadius,
                  statLabelFontSize,
                  statValueFontSize,
                  statUnitFontSize,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider(double screenHeight) {
    return Container(
      width: 1,
      height: screenHeight * 0.06,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFFCA5A5).withOpacity(0.0),
            const Color(0xFFFCA5A5),
            const Color(0xFFFCA5A5).withOpacity(0.0),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(
    String label,
    String value,
    String unit,
    IconData icon,
    double iconSize,
    double iconRadius,
    double labelFontSize,
    double valueFontSize,
    double unitFontSize,
  ) {
    return Column(
      children: [
        Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFEF4444).withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: iconSize * 0.5),
        ),
        SizedBox(height: iconSize * 0.15),
        Text(
          label,
          style: TextStyle(
            fontSize: labelFontSize,
            color: const Color(0xFF991B1B),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: iconSize * 0.05),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: valueFontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF7F1D1D),
                height: 1,
              ),
            ),
            SizedBox(width: iconSize * 0.03),
            Padding(
              padding: EdgeInsets.only(bottom: iconSize * 0.06),
              child: Text(
                unit,
                style: TextStyle(
                  fontSize: unitFontSize,
                  color: const Color(0xFF991B1B),
                  height: 1,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ================= Helper =================
class _HRPoint {
  final DateTime time;
  final double hr;
  _HRPoint(this.time, this.hr);
}
