import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class HeartRateCard extends StatelessWidget {
  final int heartRate;

  const HeartRateCard({
    super.key,
    required this.heartRate,
  });

  // ===================== LOGIC فقط =====================
  bool get _isLow => heartRate > 0 && heartRate < 60;
  bool get _isHigh => heartRate > 100;
  bool get _isNormal => heartRate >= 60 && heartRate <= 100;

  String get _statusText {
    if (heartRate == 0) return "not_available".tr();
    if (_isLow) return "heart_rate_low".tr();
    if (_isHigh) return "heart_rate_high".tr();
    return "heart_rate_normal".tr();
  }

  Color get _statusColor {
    if (_isNormal) return Colors.green;
    if (heartRate == 0) return Colors.grey;
    return Colors.red;
  }

  double get _progress {
    if (heartRate <= 0) return 0;
    return (heartRate / 200).clamp(0.0, 1.0);
  }

  // ===================== UI =====================
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // ======= أحجام نسبية =======
    final cardPadding = screenWidth * 0.05;
    final iconSize = screenWidth * 0.12;
    final iconRadius = iconSize * 0.25;
    final livePaddingH = screenWidth * 0.03;
    final livePaddingV = screenHeight * 0.008;
    final liveFontSize = screenWidth * 0.03;
    final heartRateFontSize = screenWidth * 0.08;
    final labelFontSize = screenWidth * 0.035;
    final statusFontSize = screenWidth * 0.03;
    final spacingSmall = screenHeight * 0.015;
    final spacingMedium = screenHeight * 0.02;

    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFFFEF2F2), Colors.white],
        ),
        borderRadius: BorderRadius.circular(screenWidth * 0.05),
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
          // -------- Header --------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: iconSize,
                height: iconSize,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                  ),
                  borderRadius: BorderRadius.circular(iconRadius),
                ),
                child: Icon(
                  Icons.favorite_rounded,
                  color: Colors.white,
                  size: iconSize * 0.5,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: livePaddingH, vertical: livePaddingV),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(screenWidth * 0.02),
                ),
                child: Text(
                  "live".tr(),
                  style: TextStyle(
                    fontSize: liveFontSize,
                    color: const Color(0xFFB91C1C),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: spacingMedium),

          // -------- Heart Rate --------
          Text(
            heartRate > 0 ? '$heartRate' : '--',
            style: TextStyle(
              fontSize: heartRateFontSize,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF111827),
            ),
          ),
          Text(
            "heart_rate".tr(),
            style: TextStyle(
              fontSize: labelFontSize,
              color: const Color(0xFF6B7280),
            ),
          ),

          SizedBox(height: spacingMedium),

          // -------- Progress + Status --------
          Row(
            children: [
              Expanded(
                child: Container(
                  height: screenHeight * 0.005,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(screenHeight * 0.0025),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerRight,
                    widthFactor: _progress,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                        ),
                        borderRadius:
                            BorderRadius.circular(screenHeight * 0.0025),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: screenWidth * 0.02),
              Text(
                _statusText,
                style: TextStyle(
                  fontSize: statusFontSize,
                  fontWeight: FontWeight.bold,
                  color: _statusColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
