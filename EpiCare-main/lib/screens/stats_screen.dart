import 'package:flutter/material.dart';
import '../widgets/heart_rate_chart.dart';
import '../widgets/steps_chart.dart';
import '../widgets/seizure_history.dart';
import 'package:easy_localization/easy_localization.dart';
import '../widgets/seizure_report_download.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final screenWidth = media.size.width;
    final horizontalPadding = screenWidth * 0.04;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          "statistics".tr(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * 0.05,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
            ),
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Heart Rate Chart
            const HeartRateChart(),
            const SizedBox(height: 16),

            // Steps Chart
            const StepsChart(),
            const SizedBox(height: 16),

            // Seizure History
            const SeizureHistory(),
            const SizedBox(height: 16),
            // Seizure Report PDF
            const SeizureReportDownload(),
            const SizedBox(height: 16),

          ],
        ),
      ),
    );
  }
}
