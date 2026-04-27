import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class StepsCard extends StatelessWidget {
  final int steps;
  final int goal;
  final VoidCallback? onTap;

  const StepsCard({
    super.key,
    required this.steps,
    required this.goal,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final padding = screenWidth * 0.05;
    final iconSize = screenWidth * 0.06;
    final containerSize = screenWidth * 0.12;
    final titleFont = screenWidth * 0.035;
    final numberFont = screenWidth * 0.08;
    final labelFont = screenWidth * 0.038;
    final progressHeight = screenHeight * 0.006;
    final borderRadius = screenWidth * 0.03;

    final percentage =
        goal > 0 ? ((steps / goal) * 100).clamp(0, 100).round() : 0;

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFFEFF6FF), Colors.white],
        ),
        borderRadius: BorderRadius.circular(borderRadius),
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
          // ---- Header Row ----
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: onTap,
                child: Container(
                  width: containerSize,
                  height: containerSize,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                    ),
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                  child: Icon(
                    Icons.directions_walk_rounded,
                    color: Colors.white,
                    size: iconSize,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.03,
                  vertical: screenHeight * 0.006,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFDBEAFE),
                  borderRadius: BorderRadius.circular(borderRadius * 0.6),
                ),
                child: Text(
                  "today".tr(),
                  style: TextStyle(
                    fontSize: titleFont,
                    color: const Color(0xFF1E40AF),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: screenHeight * 0.02),

          // ---- Steps Number ----
          Text(
            steps.toString(),
            style: TextStyle(
              fontSize: numberFont,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF111827),
            ),
          ),
          Text(
            "steps".tr(),
            style: TextStyle(
              fontSize: labelFont,
              color: const Color(0xFF6B7280),
            ),
          ),

          SizedBox(height: screenHeight * 0.015),

          // ---- Progress Bar ----
          Row(
            children: [
              Expanded(
                child: Container(
                  height: progressHeight,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDBEAFE),
                    borderRadius: BorderRadius.circular(progressHeight / 2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: goal > 0 ? steps / goal : 0,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                        ),
                        borderRadius: BorderRadius.circular(progressHeight / 2),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: screenWidth * 0.02),
              Text(
                '$percentage%',
                style: TextStyle(
                  fontSize: labelFont,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
