import 'package:flutter/material.dart';
import '../models/medication.dart';
import 'package:easy_localization/easy_localization.dart';

class MedicationReminder extends StatelessWidget {
  final List<Medication> medications;
  final VoidCallback? onAddMedication;
  final Function(Medication med, MedicationStatus newStatus)? onStatusChanged;
  final Function(Medication med)? onDeleteMedication;

  const MedicationReminder({
    super.key,
    required this.medications,
    this.onStatusChanged,
    this.onAddMedication,
    this.onDeleteMedication,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // أحجام نسبية
    final padding = screenWidth * 0.05;
    final iconSize = screenWidth * 0.12;
    final iconRadius = iconSize * 0.25;
    final spacingSmall = screenHeight * 0.015;
    final spacingMedium = screenHeight * 0.02;
    final titleFontSize = screenWidth * 0.045;
    final descFontSize = screenWidth * 0.033;
    final medNameFontSize = screenWidth * 0.04;
    final medInfoFontSize = screenWidth * 0.033;
    final buttonIconSize = screenWidth * 0.06;

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFFEFF6FF), Colors.white],
        ),
        borderRadius: BorderRadius.circular(screenWidth * 0.05),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: iconSize,
                      height: iconSize,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                        ),
                        borderRadius: BorderRadius.circular(iconRadius),
                      ),
                      child: Icon(
                        Icons.medication_rounded,
                        color: Colors.white,
                        size: iconSize * 0.5,
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.03),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "today_medication_schedule".tr(),
                            style: TextStyle(
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "punctuality_is_very_important".tr(),
                            style: TextStyle(fontSize: descFontSize),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.add_circle_outline,
                    color: const Color(0xFF2563EB), size: buttonIconSize),
                onPressed: onAddMedication,
              ),
            ],
          ),

          SizedBox(height: spacingMedium),

          // Medication items
          ...medications.map((med) => _buildMedicationItem(context, med, screenWidth, screenHeight)).toList(),
        ],
      ),
    );
  }

  Widget _buildMedicationItem(BuildContext context, Medication med, double screenWidth, double screenHeight) {
    final iconSize = screenWidth * 0.06;
    final spacingSmall = screenHeight * 0.012;
    final spacingMedium = screenHeight * 0.018;
    final medNameFontSize = screenWidth * 0.04;
    final medInfoFontSize = screenWidth * 0.033;

    final status = med.status;
    Color bgColor;
    Color borderColor;
    String statusText;
    IconData statusIcon;

    switch (status) {
      case MedicationStatus.taken:
        bgColor = const Color(0xFFD1FAE5);
        borderColor = const Color(0xFF10B981);
        statusText = "taken".tr();
        statusIcon = Icons.check_circle_rounded;
        break;
      case MedicationStatus.soon:
        bgColor = const Color(0xFFEFF6FF);
        borderColor = const Color(0xFF2563EB);
        statusText = "soon".tr();
        statusIcon = Icons.access_time_rounded;
        break;
      case MedicationStatus.missed:
        bgColor = const Color(0xFFFEE2E2);
        borderColor = const Color(0xFFDC2626);
        statusText = "not_done".tr();
        statusIcon = Icons.cancel_rounded;
        break;
    }

    return Container(
      margin: EdgeInsets.only(bottom: spacingMedium),
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Column(
        children: [
          // Text row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(statusIcon, color: borderColor, size: iconSize),
                    SizedBox(width: screenWidth * 0.03),
                    Flexible(
                      child: Text(
                        med.name,
                        style: TextStyle(
                          fontSize: medNameFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    statusText,
                    style: TextStyle(fontSize: medInfoFontSize),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: Colors.red, size: iconSize),
                    onPressed: () => onDeleteMedication?.call(med),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: spacingSmall),

          // Action row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${med.dosage} - ${med.time}',
                  style: TextStyle(fontSize: medInfoFontSize, color: Colors.black54),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.check_circle, color: Colors.green, size: iconSize),
                    tooltip: "taken".tr(),
                    onPressed: () => onStatusChanged?.call(med, MedicationStatus.taken),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  IconButton(
                    icon: Icon(Icons.access_time_filled, color: Colors.orange, size: iconSize),
                    tooltip: "soon".tr(),
                    onPressed: () => onStatusChanged?.call(med, MedicationStatus.soon),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  IconButton(
                    icon: Icon(Icons.cancel_rounded, color: Colors.red, size: iconSize),
                    tooltip: "not_done".tr(),
                    onPressed: () => onStatusChanged?.call(med, MedicationStatus.missed),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}