import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class SeizureHistory extends StatefulWidget {
  const SeizureHistory({super.key});

  @override
  State<SeizureHistory> createState() => _SeizureHistoryState();
}

class _SeizureHistoryState extends State<SeizureHistory> {
  final _db = FirebaseDatabase.instance.ref();
  final _auth = FirebaseAuth.instance;

  List<Map<String, dynamic>> records = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _listenToSeizures();
  }

  // ==================== Listen to Seizure Records ====================
  void _listenToSeizures() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    _db
        .child("emergencyAlerts/$uid")
        .orderByChild("timestamp")
        .limitToLast(4)
        .onValue
        .listen((event) {
      if (!event.snapshot.exists || event.snapshot.value == null) {
        setState(() {
          records = [];
          loading = false;
        });
        return;
      }

      final data = Map<String, dynamic>.from(event.snapshot.value as Map);

      final list = data.entries.map((e) {
        final v = Map<String, dynamic>.from(e.value);
        return {
          "id": e.key,
          "timestamp": v["timestamp"],
          "severity": v["severity"],
          "duration": v["duration"],
        };
      }).toList();

      list.sort((a, b) =>
          DateTime.parse(b["timestamp"]).compareTo(DateTime.parse(a["timestamp"])));

      setState(() {
        records = list;
        loading = false;
      });
    });
  }

  // ==================== Ask severity & duration ====================
  void _askSeizureDetails(Map<String, dynamic> record) {
    String severity = record["severity"] ?? "light";
    String duration = record["duration"] ?? "1 min";

    final screenWidth = MediaQuery.of(context).size.width;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("seizure_details".tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: severity,
              items: [
                DropdownMenuItem(value: "light", child: Text("light".tr())),
                DropdownMenuItem(value: "medium", child: Text("medium".tr())),
                DropdownMenuItem(value: "severe", child: Text("severe".tr())),
              ],
              onChanged: (v) => severity = v!,
              decoration: InputDecoration(
                labelText: "degree_of_seizure".tr(),
                contentPadding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
              ),
            ),
            SizedBox(height: screenWidth * 0.03),
            TextFormField(
              initialValue: duration,
              decoration: InputDecoration(
                labelText: "duration_of_seizure".tr(),
                contentPadding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
              ),
              onChanged: (v) => duration = v,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("cancle".tr()),
          ),
          ElevatedButton(
            onPressed: () async {
              final uid = _auth.currentUser?.uid;
              if (uid == null) return;

              await _db
                  .child("emergencyAlerts/$uid/${record["id"]}")
                  .update({
                "severity": severity,
                "duration": duration,
              });

              Navigator.pop(context);
              _listenToSeizures();
            },
            child: Text("save".tr()),
          ),
        ],
      ),
    );
  }

  // ==================== UI ====================
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (records.isEmpty) {
      return Text("no_recorded_seizure".tr());
    }

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.05),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFFFAF5FF), Colors.white],
        ),
        borderRadius: BorderRadius.circular(screenWidth * 0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "recorded_seizures".tr(),
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          ...records.asMap().entries.map((entry) {
            final index = entry.key;
            final r = entry.value;

            final dt = DateTime.parse(r["timestamp"]);
            final date = DateFormat("yyyy-MM-dd").format(dt);
            final time = DateFormat("HH:mm").format(dt);

            return GestureDetector(
              onTap: () => _askSeizureDetails(r),
              child: _recordCard(
                context: context,
                date: date,
                time: time,
                duration: r["duration"] ?? "not_determined".tr(),
                severity: r["severity"] ?? "not_determined".tr(),
                number: records.length - index,
              ),
            );
          }),
        ],
      ),
    );
  }

  // ==================== Record Card (Responsive) ====================
  Widget _recordCard({
    required BuildContext context,
    required String date,
    required String time,
    required String duration,
    required String severity,
    required int number,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final padding = screenWidth * 0.04;
    final borderRadius = screenWidth * 0.04;
    final severityPaddingH = screenWidth * 0.03;
    final severityPaddingV = screenHeight * 0.008;
    final fontSizeTitle = screenWidth * 0.038;
    final fontSizeSub = screenWidth * 0.033;

    Color color;
    switch (severity) {
      case "light":
        color = const Color(0xFF10B981);
        break;
      case "medium":
        color = const Color(0xFFF59E0B);
        break;
      case "severe":
        color = const Color(0xFFEF4444);
        break;
      default:
        color = const Color(0xFF6B7280);
    }

    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.015),
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 2),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "seizure_number".tr() + "#$number",
                  style: TextStyle(fontSize: fontSizeTitle),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: severityPaddingH, vertical: severityPaddingV),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                 getSeverityText(severity), 
                   style: TextStyle(
                   color: Colors.white,
                   fontSize: fontSizeSub,
                     ),
                    ),
               
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.01),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "$date • $time",
                  style: TextStyle(fontSize: fontSizeSub),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: screenWidth * 0.02),
              Flexible(
                child: Text(
                  "duration_of_seizure".tr() + ": $duration",
                  style: TextStyle(fontSize: fontSizeSub),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
String getSeverityText(String value) {
  switch (value) {
    case "light":
      return "light".tr();
    case "medium":
      return "medium".tr();
    case "severe":
      return "severe".tr();
    default:
      return "not_determined".tr();
  }
}
