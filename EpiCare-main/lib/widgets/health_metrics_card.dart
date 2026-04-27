import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class HealthMetricsCard extends StatelessWidget {
  final double sleepHours;
  final int stressLevel;
  final int waterIntake;
  final int waterGoal;

  final VoidCallback? onWaterTap;
  final VoidCallback? onSleepHoursTap;

  const HealthMetricsCard({
    super.key,
    required this.sleepHours,
    required this.stressLevel,
    required this.waterIntake,
    required this.waterGoal,
    this.onWaterTap,
    this.onSleepHoursTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // padding نسبي للشاشة
    final cardPadding = screenWidth * 0.04;
    final iconSize = screenWidth * 0.12;
    final valueFontSize = screenWidth * 0.05;
    final unitFontSize = screenWidth * 0.035;
    final labelFontSize = screenWidth * 0.038;
    final spacingSmall = screenHeight * 0.01;
    final spacingMedium = screenHeight * 0.015;

    return Row(
      children: [
        // ---------------- ماء ----------------
        Expanded(
          child: GestureDetector(
            onTap: onWaterTap,
            child: _buildWaterCard(
              cardPadding,
              iconSize,
              valueFontSize,
              labelFontSize,
              spacingSmall,
              spacingMedium,
            ),
          ),
        ),

        SizedBox(width: screenWidth * 0.03),

        // ---------------- ساعات النوم ----------------
        Expanded(
          child: GestureDetector(
            onTap: onSleepHoursTap,
            child: _buildMetricCard(
              icon: Icons.bedtime_rounded,
              value: sleepHours.toStringAsFixed(1),
              unit: "hours_label".tr(),
              label: "sleep_label".tr(),
              colors: const [Color(0xFF6366F1), Color(0xFF4F46E5)],
              bgColors: const [Color(0xFFEEF2FF), Colors.white],
              cardPadding: cardPadding,
              iconSize: iconSize,
              valueFontSize: valueFontSize,
              unitFontSize: unitFontSize,
              labelFontSize: labelFontSize,
              spacingSmall: spacingSmall,
              spacingMedium: spacingMedium,
            ),
          ),
        ),

        SizedBox(width: screenWidth * 0.03),

        // ---------------- مستوى التوتر ----------------
        Expanded(
          child: _buildMetricCard(
            icon: Icons.favorite_rounded,
            value: "$stressLevel%",
            unit: "",
            label: "stress_label".tr(),
            colors: const [Color(0xFFF97316), Color(0xFFEA580C)],
            bgColors: const [Color(0xFFFFF7ED), Colors.white],
            cardPadding: cardPadding,
            iconSize: iconSize,
            valueFontSize: valueFontSize,
            unitFontSize: unitFontSize,
            labelFontSize: labelFontSize,
            spacingSmall: spacingSmall,
            spacingMedium: spacingMedium,
          ),
        ),
      ],
    );
  }

  // ---------------- كرت التوتر والنوم ----------------
  Widget _buildMetricCard({
    required IconData icon,
    required String value,
    required String unit,
    required String label,
    required List<Color> colors,
    required List<Color> bgColors,
    required double cardPadding,
    required double iconSize,
    required double valueFontSize,
    required double unitFontSize,
    required double labelFontSize,
    required double spacingSmall,
    required double spacingMedium,
  }) {
    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: _boxDecoration(bgColors),
      child: Column(
        children: [
          _gradientIcon(icon, colors, iconSize),
          SizedBox(height: spacingMedium),
          Text(
            value,
            style: TextStyle(
              fontSize: valueFontSize,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF111827),
            ),
          ),
          if (unit.isNotEmpty)
            Text(
              unit,
              style: TextStyle(fontSize: unitFontSize, color: const Color(0xFF6B7280)),
            ),
          SizedBox(height: spacingSmall),
          Text(
            label,
            style: TextStyle(fontSize: labelFontSize, color: const Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  // ---------------- كرت الماء ----------------
  Widget _buildWaterCard(
    double cardPadding,
    double iconSize,
    double valueFontSize,
    double labelFontSize,
    double spacingSmall,
    double spacingMedium,
  ) {
    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: _boxDecoration(const [Color(0xFFECFEFF), Colors.white]),
      child: Column(
        children: [
          _gradientIcon(
            Icons.water_drop_rounded,
            const [Color(0xFF06B6D4), Color(0xFF0891B2)],
            iconSize,
          ),
          SizedBox(height: spacingMedium),
          Text(
            '$waterIntake/$waterGoal',
            style: TextStyle(
              fontSize: valueFontSize,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF111827),
            ),
          ),
          Text(
            'cups'.tr(),
            style: TextStyle(fontSize: labelFontSize, color: const Color(0xFF6B7280)),
          ),
          SizedBox(height: spacingSmall),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(waterGoal, (index) {
              final filled = index < waterIntake;
              return Container(
                width: iconSize * 0.08,
                height: iconSize * 0.2,
                margin: EdgeInsets.symmetric(horizontal: iconSize * 0.02),
                decoration: BoxDecoration(
                  color: filled ? const Color(0xFF06B6D4) : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(iconSize * 0.04),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ---------------- Helpers ----------------
  BoxDecoration _boxDecoration(List<Color> bgColors) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: bgColors,
      ),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Widget _gradientIcon(IconData icon, List<Color> colors, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(size * 0.25),
      ),
      child: Icon(icon, color: Colors.white, size: size * 0.5),
    );
  }
}
