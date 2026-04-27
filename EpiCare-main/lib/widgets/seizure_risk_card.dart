import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class SeizureRiskCard extends StatelessWidget {
  final String risk;
  final String lastSeizure;

  final bool regularActivity;
  final bool medicationAdherent;
  final bool sleepQuality;

  final VoidCallback onActivityTap;
  final VoidCallback onMedicationTap;
  final VoidCallback onSleepQualityTap;

  const SeizureRiskCard({
    super.key,
    required this.risk,
    required this.lastSeizure,
    required this.regularActivity,
    required this.medicationAdherent,
    required this.sleepQuality,
    required this.onActivityTap,
    required this.onMedicationTap,
    required this.onSleepQualityTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final padding = screenWidth * 0.06;
    final iconSize = screenWidth * 0.055;
    final cardRadius = screenWidth * 0.05;
    final smallFont = screenWidth * 0.03;
    final mediumFont = screenWidth * 0.038;
    final largeFont = screenWidth * 0.045;

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFFD1FAE5), Color(0xFFEFF6FF)],
        ),
        borderRadius: BorderRadius.circular(cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // -------------------- الجزء العلوي --------------------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    // أيقونة الدماغ
                    Container(
                      width: screenWidth * 0.16,
                      height: screenWidth * 0.16,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                        ),
                        borderRadius: BorderRadius.circular(cardRadius * 0.8),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.psychology_rounded,
                          color: Colors.white,
                          size: iconSize * 1.5,
                        ),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.04),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "seizure_risk_assesment".tr(),
                            style: TextStyle(
                              fontSize: smallFont,
                              color: const Color(0xFF6B7280),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.04,
                              vertical: screenHeight * 0.006,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF10B981), Color(0xFF059669)],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              risk,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: mediumFont,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: screenWidth * 0.02),
              // مربع آخر نوبة
              Container(
                padding: EdgeInsets.all(screenWidth * 0.04),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "last_seizure".tr(),
                      style: TextStyle(fontSize: smallFont, color: const Color(0xFF6B7280)),
                    ),
                    SizedBox(height: screenHeight * 0.004),
                    Text(
                      lastSeizure,
                      style: TextStyle(
                        fontSize: mediumFont,
                        color: const Color(0xFF111827),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: screenHeight * 0.025),

          // -------------------- مؤشرات الضغط --------------------
          Container(
            padding: EdgeInsets.only(top: screenHeight * 0.02),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFFE5E7EB)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: _indicator(
                    screenWidth: screenWidth,
                    icon: Icons.favorite_rounded,
                    label: regularActivity ? "Regular_activity".tr() : "irregular_activity".tr(),
                    active: regularActivity,
                    color: Colors.blue,
                    onTap: onActivityTap,
                  ),
                ),
                Expanded(
                  child: _indicator(
                    screenWidth: screenWidth,
                    icon: Icons.medication_rounded,
                    label: medicationAdherent ? "commited".tr() : "not_commited".tr(),
                    active: medicationAdherent,
                    color: Colors.green,
                    onTap: onMedicationTap,
                  ),
                ),
                Expanded(
                  child: _indicator(
                    screenWidth: screenWidth,
                    icon: Icons.bedtime_rounded,
                    label: sleepQuality ? "good_sleep".tr() : "poor_sleep".tr(),
                    active: sleepQuality,
                    color: Colors.purple,
                    onTap: onSleepQualityTap,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _indicator({
    required double screenWidth,
    required IconData icon,
    required String label,
    required bool active,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: screenWidth * 0.11,
            height: screenWidth * 0.11,
            decoration: BoxDecoration(
              color: active ? color : Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: screenWidth * 0.06),
          ),
          SizedBox(height: screenWidth * 0.025),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}