class PatientData {
  final String patientId;
  final String fullName;
  final int heartRate;
  final int steps;
  final int stepsGoal;
  final double sleepHours;
  final int stressLevel;
  final int waterIntake;
  final int waterGoal;
  final String lastSeizure;
  final String seizureRisk; // "--" إذا غير متوفر
  final double spo2;
  final double accel;

  PatientData({
    required this.patientId,
    required this.fullName,
    required this.heartRate,
    required this.steps,
    required this.stepsGoal,
    required this.sleepHours,
    required this.stressLevel,
    required this.waterIntake,
    required this.waterGoal,
    required this.lastSeizure,
    required this.seizureRisk,
    required this.spo2,
    required this.accel,
  });

  // =========================
  // Factory — REAL DATA ONLY
  // =========================
  factory PatientData.fromJson(Map<String, dynamic> json) {
    return PatientData(
      patientId: json['patientId']?.toString() ??
          json['id']?.toString() ??
          'UNKNOWN',

      fullName: json['fullName']?.toString() ??
          json['name']?.toString() ??
          'Unknown',

      heartRate: _toInt(json['heartRate']),
      steps: _toInt(json['steps']),
      stepsGoal: _toInt(json['stepsGoal']),
      sleepHours: _toDouble(json['sleepHours']),
      stressLevel: _toInt(json['stressLevel']),
      waterIntake: _toInt(json['waterIntake']),
      waterGoal: _toInt(json['waterGoal']),
      lastSeizure: json['lastSeizure']?.toString() ?? "--",

      // ❗ لا خطر بدون حساب
      seizureRisk: json['seizureRisk']?.toString() ?? "--",

      spo2: _toDouble(json['spo2']),
      accel: _toDouble(json['accel']),
    );
  }

  // =========================
  // copyWith
  // =========================
  PatientData copyWith({
    String? patientId,
    String? fullName,
    int? heartRate,
    int? steps,
    int? stepsGoal,
    double? sleepHours,
    int? stressLevel,
    int? waterIntake,
    int? waterGoal,
    String? lastSeizure,
    String? seizureRisk,
    double? spo2,
    double? accel,
  }) {
    return PatientData(
      patientId: patientId ?? this.patientId,
      fullName: fullName ?? this.fullName,
      heartRate: heartRate ?? this.heartRate,
      steps: steps ?? this.steps,
      stepsGoal: stepsGoal ?? this.stepsGoal,
      sleepHours: sleepHours ?? this.sleepHours,
      stressLevel: stressLevel ?? this.stressLevel,
      waterIntake: waterIntake ?? this.waterIntake,
      waterGoal: waterGoal ?? this.waterGoal,
      lastSeizure: lastSeizure ?? this.lastSeizure,
      seizureRisk: seizureRisk ?? this.seizureRisk,
      spo2: spo2 ?? this.spo2,
      accel: accel ?? this.accel,
    );
  }

  // =========================
  // Helpers
  // =========================
  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}