
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';

import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

enum ReportRange { days7, days30, days90 }

class SeizureReportDownload extends StatefulWidget {
  const SeizureReportDownload({super.key});

  @override
  State<SeizureReportDownload> createState() =>
      _SeizureReportDownloadState();
}

class _SeizureReportDownloadState extends State<SeizureReportDownload> {
  ReportRange selectedRange = ReportRange.days30;
  bool generating = false;

  int _rangeDays() {
    switch (selectedRange) {
      case ReportRange.days7:
        return 7;
      case ReportRange.days30:
        return 30;
      case ReportRange.days90:
        return 90;
    }
  }

  PdfColor _severityPdfColor(String s) {
    switch (s) {
      case "light":
        return PdfColors.green;
      case "medium":
        return PdfColors.orange;
      case "severe":
        return PdfColors.red;
      default:
        return PdfColors.grey;
    }
  }

  String _severityText(String s) {
    switch (s) {
      case "light":
        return "light".tr();
      case "medium":
        return "medium".tr();
      case "severe":
        return "severe".tr();
      default:
        return "-";
    }
  }

  String formatDuration(String duration) {
    int minutes = int.tryParse(duration) ?? 1;
    if (minutes == 1) return "1 ${"minute".tr()}";
    return "$minutes ${"minutes".tr()}";
  }

  Future<void> _generatePdf(BuildContext context) async {
    setState(() => generating = true);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    String userName = "Patient";

    if (uid != null) {
      final nameSnapshot =
          await FirebaseDatabase.instance.ref("users/$uid/fullName").get();
      if (nameSnapshot.exists) {
        userName = nameSnapshot.value.toString();
      }
    }

    final arabicFont = pw.Font.ttf(
      await rootBundle.load("assets/fonts/Amiri-Regular.ttf"),
    );

    final ref = FirebaseDatabase.instance.ref("emergencyAlerts/$uid");
    final snapshot = await ref.get();

    if (!snapshot.exists || snapshot.value == null) {
      _showMsg(context, "no_recorded_seizure".tr());
      setState(() => generating = false);
      return;
    }

    final data = Map<String, dynamic>.from(snapshot.value as Map);
    final now = DateTime.now();
    final fromDate = now.subtract(Duration(days: _rangeDays()));

    final records = data.values
        .map((v) => Map<String, dynamic>.from(v))
        .where((r) {
      final ts = DateTime.tryParse(r["timestamp"] ?? "");
      return ts != null && ts.isAfter(fromDate);
    }).toList();

    if (records.isEmpty) {
      _showMsg(context, "no_recorded_seizure".tr());
      setState(() => generating = false);
      return;
    }

    final pdf = pw.Document();
    final locale = context.locale.languageCode; // "en" أو "ar"

    pdf.addPage(
      pw.MultiPage(
        textDirection: pw.TextDirection.rtl,
        build: (_) => [
          pw.Text(
            "download_seizure_report".tr(),
            textDirection: pw.TextDirection.rtl,
            style: pw.TextStyle(
              font: arabicFont,
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            "${"patient_name".tr()}: $userName",
            textDirection: pw.TextDirection.rtl,
            style: pw.TextStyle(font: arabicFont, fontSize: 12),
          ),
          pw.Text(
            "${"created_at".tr()}: ${DateFormat.yMMMMd(locale).format(now)} ${DateFormat.Hm(locale).format(now)}",
            textDirection: pw.TextDirection.rtl,
            style: pw.TextStyle(font: arabicFont, fontSize: 12),
          ),
          pw.SizedBox(height: 16),

          pw.Table(
            border: pw.TableBorder.all(),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(
                  color: PdfColors.grey300,
                ),
                children: [
                  _cell("date".tr(), arabicFont),
                  _cell("time".tr(), arabicFont),
                  _cell("severity".tr(), arabicFont),
                  _cell("duration".tr(), arabicFont),
                ],
              ),
              ...records.map((r) {
                final dt = DateTime.parse(r["timestamp"]);
                final sev = r["severity"] ?? "-";
                final dur = r["duration"]?.toString() ?? "1";

                return pw.TableRow(
                  children: [
                    _cell(DateFormat.yMMMMd(locale).format(dt), arabicFont),
                    _cell(DateFormat.Hm(locale).format(dt), arabicFont),
                    pw.Container(
                      color: _severityPdfColor(sev),
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(
                        _severityText(sev),
                        textDirection: pw.TextDirection.rtl,
                        style: pw.TextStyle(
                          font: arabicFont,
                          color: PdfColors.white,
                        ),
                      ),
                    ),
                    _cell(formatDuration(dur), arabicFont),
                  ],
                );
              }),
            ],
          ),
        ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File(
      "${dir.path}/seizure_report_${_rangeDays()}_days.pdf",
    );

    await file.writeAsBytes(await pdf.save());
    await OpenFile.open(file.path);

    setState(() => generating = false);
  }

  pw.Widget _cell(String text, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        textDirection: pw.TextDirection.rtl,
        style: pw.TextStyle(font: font),
      ),
    );
  }

  void _showMsg(BuildContext context, String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.all(w * 0.045),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(w * 0.04),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "download_seizure_report".tr(),
            style: TextStyle(
              fontSize: w * 0.04,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          DropdownButton<ReportRange>(
            value: selectedRange,
            items: [
              DropdownMenuItem(
                value: ReportRange.days7,
                child: Text("days_7".tr()),
              ),
              DropdownMenuItem(
                value: ReportRange.days30,
                child: Text("days_30".tr()),
              ),
              DropdownMenuItem(
                value: ReportRange.days90,
                child: Text("days_90".tr()),
              ),
            ],
            onChanged: (v) {
              if (v != null) setState(() => selectedRange = v);
            },
          ),

          const SizedBox(height: 12),

          ElevatedButton.icon(
            onPressed: generating ? null : () => _generatePdf(context),
            icon: const Icon(Icons.picture_as_pdf),
            label: Text(
              generating ? "generating".tr() : "download_pdf".tr(),
            ),
          ),
        ],
      ),
    );
  }
}
