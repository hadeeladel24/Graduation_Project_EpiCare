// lib/screens/home_screen.dart
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:permission_handler/permission_handler.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:epilepsy_care_app/services/bluetooth_service.dart';
import 'package:epilepsy_care_app/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

//import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import 'package:geolocator/geolocator.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

// Models + Widgets
import 'package:epilepsy_care_app/models/contact.dart';
import 'package:epilepsy_care_app/models/medication.dart';
import 'package:epilepsy_care_app/models/patient_data.dart';

import 'package:epilepsy_care_app/widgets/heart_rate_card.dart';
import 'package:epilepsy_care_app/widgets/steps_card.dart';
import 'package:epilepsy_care_app/widgets/seizure_risk_card.dart';
import 'package:epilepsy_care_app/widgets/medication_reminder.dart';
import 'package:epilepsy_care_app/widgets/location_sharing_card.dart';
import 'package:epilepsy_care_app/widgets/health_metrics_card.dart';

import 'package:epilepsy_care_app/services/emergency_service.dart';

// ML services
import 'package:epilepsy_care_app/services/hw_message_parser.dart';
import 'package:epilepsy_care_app/services/feature_vectorizer.dart';
import 'package:epilepsy_care_app/services/window_buffer.dart';
import 'package:epilepsy_care_app/services/seizure_client.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  // -------------------- Firebase --------------------
  final _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  String? get _uid => _auth.currentUser?.uid;
  StreamSubscription? _subscription;
  Timer? _btStatusTimer; 

  // -------------------- Seizure Info --------------------
  String lastSeizureText = "--";
  String seizureRiskValue = "--";
  bool _confirmationShown = false;
  Timer? _confirmTimer;

  // -------------------- Bluetooth --------------------
  bool _btConnected = false;
  bool _initialized = false;

  final btService = BluetoothService();
  String _btJsonBuffer = "";
  String _lineCarry = "";

  // -------------------- ML Pipeline --------------------
  final HwMessageParser _hwParser = HwMessageParser();
  final FeatureVectorizer _vectorizer = FeatureVectorizer();
  late final SeizureClient _mlApi;
  late final WindowBuffer _mlBuffer;
  
  int _posStreak = 0;
  static const int _REQ_POS = 3;
  List<Contact> emergencyContacts = [];

  bool _mlReady = false;
  double? _lastProb; 
  int? _lastPred;

  final String serverUrl = "http://192.168.1.9:5000";
  final double mlThr = 0.6;

  // -------------------- Data --------------------
  PatientData? patientData;
  String userFullName = "مستخدم";
  int? userNumber;

  bool sleepQuality = false;
  bool regularActivity = false;
  int waterIntake = 0;

  TimeOfDay? sleepTime;
  TimeOfDay? wakeTime;
  double calculatedSleepHours = 0.0;

  List<Medication> medications = [];
  int stepsGoal = 0;

  // -------------------- Heart Rate Storage --------------------
  DateTime? _lastHRStoredAt;

  // -------------------- Location Sharing --------------------
  bool locationSharingEnabled = false;
  double? _lastLat;
  double? _lastLng;
  String? _lastLocationUpdate;
  StreamSubscription<Position>? _positionSub;

  // -------------------- Animation --------------------
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // -------------------- Seizure Alert --------------------
  bool _isSeizureActive = false;
  Timer? _seizureTimer;

  // -------------------- Firebase listeners --------------------
  StreamSubscription<DatabaseEvent>? _metricsSub;
  StreamSubscription<DatabaseEvent>? _riskSub;
  StreamSubscription<DatabaseEvent>? _seizureSub;

  bool get _isHeartRateNormal {
    final hr = patientData?.heartRate ?? 0;
    return hr >= 60 && hr <= 100;
  }

  Color get _statusColor {
    if (_isSeizureActive) return Colors.red;
    if (!_isHeartRateNormal) return Colors.red;
    return Colors.green;
  }

  @override
  void initState() {
    super.initState();
    _setupAnimation();
    _btConnected = btService.isConnected;
    
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      if (!_initialized) {
        _initialized = true;
        _initAfterLogin();
      } else {
        _subscribeToBluetoothStream();
      }
    }
    
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null && !_initialized) {
        _initialized = true;
        _initAfterLogin();
      }
    });
  }

  Future<bool> ensureBluetoothPermissions() async {
    final statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();

    return statuses.values.every((s) => s.isGranted);
  }

  Future<void> _initAfterLogin() async {
    await _requestBluetoothPermissions();
    
    final permsOk = await ensureBluetoothPermissions();
    if (!permsOk) {
      debugPrint("Bluetooth permissions not granted.");
      return;
    }

    await _initializeApp();
    _subscribeToBluetoothStream();
    emergencyContacts = await _loadEmergencyContacts();
  }

  // ✅ اشتراك عادي بدون background
  void _subscribeToBluetoothStream() {
    debugPrint("🔄 Subscribing to Bluetooth stream...");
    
    _subscription?.cancel();
    
    _subscription = btService.dataStream.listen(
      (Uint8List data) {
        _onBtDataReceived(data);
        if (mounted && !_btConnected) {
          setState(() => _btConnected = true);
        }
      },
      onError: (e) {
        debugPrint("❌ Bluetooth stream error: $e");
        if (mounted) setState(() => _btConnected = false);
      },
      onDone: () {
        debugPrint("🔴 Bluetooth disconnected");
        if (mounted) setState(() => _btConnected = false);
      },
    );
    
    if (mounted) {
      final currentStatus = btService.isConnected;
      debugPrint("📡 Current BT status: $currentStatus");
      setState(() => _btConnected = currentStatus);
    }
    
    _startBluetoothStatusMonitor();
  }

  void _startBluetoothStatusMonitor() {
    _btStatusTimer?.cancel();
    _btStatusTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      final currentStatus = btService.isConnected;
      if (_btConnected != currentStatus) {
        debugPrint("🔄 BT status changed: $_btConnected -> $currentStatus");
        setState(() => _btConnected = currentStatus);
      }
    });
  }

  void _setupAnimation() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

  Future<void> _initializeApp() async {
    if (_uid == null) return;

    await _loadUserInfoFromRealtime();
    await _loadLastSeizure();
    await _loadTodayMedications();
    await _loadLocationInfo();
    await _loadSeizureRisk();
    await _initMlPipeline();

    if (locationSharingEnabled) {
      _startLocationStream();
    }
  }

  void _updateSeizureDecision(double prob, int pred) {
    if (pred == 1) {
      _posStreak++;
    } else {
      _posStreak = 0;
    }

    debugPrint("🧠 Seizure streak=$_posStreak prob=$prob");

    if (_posStreak >= _REQ_POS) {
      _posStreak = 0;
      // ✅ فقط إذا التطبيق مفتوح
       if (!_confirmationShown && !_isSeizureActive && mounted) {
        _showSeizureConfirmationDialog();
      }
      else {
    debugPrint("💡 Dialog skipped, already shown or seizure active");
  }
    }
  }

  Future<void> _initMlPipeline() async {
    try {
      await _vectorizer.init();
      _mlApi = SeizureClient(baseUrl: serverUrl, thr: mlThr);

      _mlBuffer = WindowBuffer(
        windowSize: 10,
        onWindowReady: (w) async {
          try {
            final res = await _mlApi.predict(w);
            final prob = (res["prob"] as num).toDouble();
            final pred = (res["pred"] as num).toInt();

            if (!mounted) return;
            setState(() {
              _lastProb = prob;
              _lastPred = pred;
            });

            _updateSeizureDecision(prob, pred);

            await _dbRef.child("users/$_uid/mlPredictions").push().set({
              "timestamp": DateTime.now().toIso8601String(),
              "probability": prob,
              "prediction": pred,
              "thr": mlThr,
            });
          } catch (e) {
            debugPrint("❌ ML API error: $e");
          }
        },
      );

      if (!mounted) return;
      setState(() => _mlReady = true);
      debugPrint("✅ ML pipeline ready. features=${_vectorizer.featureCols.length}");
    } catch (e) {
      debugPrint("❌ ML init error: $e");
    }
  }

  Future<void> _requestBluetoothPermissions() async {
    try {
      await FlutterBluetoothSerial.instance.requestEnable();
    } catch (e) {
      debugPrint("❌ Bluetooth permission error: $e");
    }
  }

  // ✅ الديالوج بس يظهر لما التطبيق مفتوح
  void _showSeizureConfirmationDialog() {
    if (_confirmationShown || _isSeizureActive || !mounted) return;

    _confirmationShown = true;
    bool userResponded = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          title:  Text("alert".tr()),
          content:  Text("are you well?".tr()),
          actions: [
            TextButton(
              onPressed: () {
                userResponded = true;
                _confirmationShown = false;
                _confirmTimer?.cancel();
                Navigator.pop(context);
                debugPrint("✅ User confirmed: NOT a seizure");
              },
              child: Text("yes".tr()),
            ),
          ],
        );
      },
    );

    _confirmTimer = Timer(const Duration(seconds: 10), () {
      if (!userResponded && mounted) {
        debugPrint("🚨 No response → confirmed seizure");
        Navigator.pop(context);
        _confirmationShown = false;
        _triggerSeizureState();
      }
    });
  }

  void _onBtDataReceived(Uint8List data) {
    final chunk = utf8.decode(data, allowMalformed: true);
    _btJsonBuffer += chunk;

    while (_btJsonBuffer.contains('{') && _btJsonBuffer.contains('}')) {
      final start = _btJsonBuffer.indexOf('{');
      final end = _btJsonBuffer.indexOf('}', start);
      if (end <= start) break;

      final jsonStr = _btJsonBuffer.substring(start, end + 1);
      _btJsonBuffer = _btJsonBuffer.substring(end + 1);

      final decoded = _tryParseJson(jsonStr);
      if (decoded != null) {
        _handleDecodedMessage(decoded);
      }
    }

    _lineCarry += chunk;
    while (_lineCarry.contains('\n')) {
      final idx = _lineCarry.indexOf('\n');
      final line = _lineCarry.substring(0, idx).trim();
      _lineCarry = _lineCarry.substring(idx + 1);
      if (line.isEmpty) continue;

      final msg = _hwParser.pushLine(line);
      if (msg != null) {
        _handleDecodedMessage(msg);
      }
    }
  }

  Map<String, dynamic>? _tryParseJson(String s) {
    try {
      final obj = jsonDecode(s);
      if (obj is Map) return Map<String, dynamic>.from(obj);
      return null;
    } catch (_) {
      return null;
    }
  }

  int _readIntAny(Map<String, dynamic> m, List<String> keys, {int fallback = 0}) {
    for (final k in keys) {
      if (!m.containsKey(k)) continue;
      final v = m[k];
      if (v == null) continue;
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) {
        final parsed = int.tryParse(v);
        if (parsed != null) return parsed;
        final parsedD = double.tryParse(v);
        if (parsedD != null) return parsedD.toInt();
      }
    }
    return fallback;
  }

  double _readDoubleAny(Map<String, dynamic> m, List<String> keys, {double fallback = 0.0}) {
    for (final k in keys) {
      if (!m.containsKey(k)) continue;
      final v = m[k];
      if (v == null) continue;
      if (v is double) return v;
      if (v is num) return v.toDouble();
      if (v is String) {
        final parsed = double.tryParse(v);
        if (parsed != null) return parsed;
      }
    }
    return fallback;
  }

  void _handleDecodedMessage(Map<String, dynamic> decoded) {
    final hr = _readIntAny(decoded, ["hr", "heartRate", "bpm"], fallback: 0);
    final steps = _readIntAny(decoded, ["steps", "step"], fallback: 0);
    final stress = _readIntAny(decoded, ["stressPercent", "stress"], fallback: patientData?.stressLevel ?? 0);
    final accel = _readDoubleAny(decoded, ["accel", "acc"], fallback: patientData?.accel ?? 0.0);

    debugPrint("📥 BT decoded => HR=$hr steps=$steps stress=$stress");

    if (!mounted) return;
    setState(() {
      if (patientData == null) {
        patientData = PatientData(
          fullName: userFullName,
          heartRate: hr,
          steps: steps,
          spo2: 0,
          accel: accel,
          stepsGoal: stepsGoal,
          sleepHours: calculatedSleepHours,
          stressLevel: stress,
          waterIntake: waterIntake,
          waterGoal: 8,
          lastSeizure: lastSeizureText,
          seizureRisk: seizureRiskValue,
          patientId: _uid ?? "",
        );
      } else {
        patientData = patientData!.copyWith(
          heartRate: hr,
          steps: steps,
          stressLevel: stress,
          accel: accel,
        );
      }
    });

    _saveTodaySteps(steps);
    _maybeStoreHR(hr);
    _calculateSeizureRisk();
    _handleMlFromDecoded(decoded);
  }

  void _handleMlFromDecoded(Map<String, dynamic> decoded) async {
    if (!_mlReady) return;
    if (decoded["window"] == null) return;

    try {
      final win = _vectorizer.extractWindow(decoded);
      final vec = _vectorizer.toVector(win);
      _mlBuffer.addVector(vec);
      debugPrint("📤 Window added to ML buffer");
    } catch (e) {
      debugPrint("❌ ML processing error: $e");
    }
  }

  Future<void> _saveSeizureRisk(double risk) async {
    if (_uid == null) return;
    await _dbRef.child("users/$_uid/seizureRisk").set({
      "value": risk.round(),
      "lastUpdate": DateTime.now().toIso8601String(),
    });
  }

  Future<void> _loadLastSeizure() async {
    if (_uid == null) return;

    try {
      final snap = await _dbRef
          .child("emergencyAlerts/$_uid")
          .orderByChild("timestamp")
          .limitToLast(1)
          .get();

      if (!snap.exists || snap.value == null) {
        if (mounted) setState(() => lastSeizureText = "no_seizures_recorded".tr());
        return;
      }

      final data = Map<String, dynamic>.from((snap.value as Map).values.first);
      final ts = DateTime.tryParse(data["timestamp"] ?? "");
      if (ts == null) {
        if (mounted) setState(() => lastSeizureText = "unknown".tr());
        return;
      }

      final diff = DateTime.now().difference(ts);
      String formatted;
      if (diff.inMinutes < 60) {
        formatted = "${diff.inMinutes} ${"minutes_ago".tr()}";
      } else if (diff.inHours < 24) {
        formatted = "${diff.inHours} ${"hours_ago".tr()}";
      } else {
        formatted = "${diff.inDays} ${"days_ago".tr()}";
      }

      if (mounted) setState(() => lastSeizureText = formatted);
    } catch (e, st) {
      debugPrint("❌ _loadLastSeizure failed: $e\n$st");
      if (mounted) setState(() => lastSeizureText = "unknown".tr());
    }
  }

  void _calculateSeizureRisk() {
    double risk = 0;
    final hasWatchData = patientData != null;

    if (hasWatchData) {
      final stress = patientData!.stressLevel;
      if (stress >= 80) risk += 30;
      else if (stress >= 60) risk += 20;
      else if (stress >= 40) risk += 10;
    }

    if (hasWatchData) {
      final hr = patientData!.heartRate;
      if (hr > 120 || hr < 50) risk += 20;
    }

    if (!sleepQuality) risk += 15;

    if (calculatedSleepHours > 0) {
      if (calculatedSleepHours < 5) risk += 20;
      else if (calculatedSleepHours < 7) risk += 10;
    }

    if (waterIntake < 4) risk += 10;
    else if (waterIntake < 6) risk += 5;

    if (!regularActivity) risk += 10;

    if (medications.isNotEmpty) {
      final total = medications.length;
      final taken = medications.where((m) => m.status == MedicationStatus.taken).length;
      final adherence = taken / total;

      if (adherence < 0.5) risk += 20;
      else if (adherence < 0.7) risk += 10;
    }

    final finalRisk = risk.round().clamp(0, 100);

    if (!mounted) return;
    setState(() {
      seizureRiskValue = finalRisk.toString();
      if (patientData != null) {
        patientData = patientData!.copyWith(seizureRisk: seizureRiskValue);
      }
    });

    _saveSeizureRisk(finalRisk.toDouble());
  }

  Future<void> _loadSeizureRisk() async {
    if (_uid == null) return;

    final snap = await _dbRef.child("users/$_uid/seizureRisk/value").get();
    if (!snap.exists || snap.value == null) return;

    final risk = snap.value as int;
    if (!mounted) return;
    setState(() {
      seizureRiskValue = risk.toString();
      if (patientData != null) {
        patientData = patientData!.copyWith(seizureRisk: seizureRiskValue);
      }
    });
  }

  Future<void> _storeHeartRateSample(int hr) async {
    if (_uid == null) return;
    final today = DateTime.now().toString().split(' ').first;
    await _dbRef.child("users/$_uid/heartRateHistory/$today").push().set({
      "hr": hr,
      "timestamp": DateTime.now().toIso8601String(),
    });
  }

  void _maybeStoreHR(int hr) {
    if (hr <= 0) return;

    final now = DateTime.now();
    if (_lastHRStoredAt == null || now.difference(_lastHRStoredAt!).inHours >= 3) {
      _lastHRStoredAt = now;
      _storeHeartRateSample(hr);
    }
  }

  Future<void> _loadUserInfoFromRealtime() async {
    if (_uid == null) return;

    final snap = await _dbRef.child("users/$_uid").get();
    if (snap.exists && snap.value != null) {
      final data = Map<String, dynamic>.from(snap.value as Map);
      final dayKey = _currentWeekdayKey();

      if (!mounted) return;
      setState(() {
        userFullName = data["fullName"] ?? data["name"] ?? "user";
        userNumber = data["user_number"] as int?;
        locationSharingEnabled = data["locationSharingEnabled"] ?? false;

        if (data["weeklyActivity"] != null && data["weeklyActivity"][dayKey] != null) {
          stepsGoal = data["weeklyActivity"][dayKey]["goal"] ?? 0;
        }
      });
    }
  }

  Future<void> _loadLocationInfo() async {
    if (_uid == null) return;

    final snap = await _dbRef.child("users/$_uid/location").get();
    if (!snap.exists || snap.value == null) return;

    final data = Map<String, dynamic>.from(snap.value as Map);
    if (!mounted) return;
    setState(() {
      _lastLat = (data["lat"] as num?)?.toDouble();
      _lastLng = (data["lng"] as num?)?.toDouble();
      _lastLocationUpdate = data["lastUpdate"] as String?;
    });
  }

  Future<void> _loadTodayMedications() async {
    if (_uid == null) return;

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final planSnap = await _dbRef.child("users/$_uid/medicationPlan").get();

    if (!planSnap.exists || planSnap.value == null) {
      if (mounted) setState(() => medications = []);
      return;
    }

    final planData = Map<String, dynamic>.from(planSnap.value as Map);
    final logSnap = await _dbRef.child("users/$_uid/medicationLogs/$today").get();

    final logData = logSnap.exists && logSnap.value != null
        ? Map<String, dynamic>.from(logSnap.value as Map)
        : {};

    final List<Medication> result = [];
    planData.forEach((id, med) {
      if (med["active"] != true) return;
      for (final time in List<String>.from(med["times"])) {
        final key = _medKey(med["name"], time);
        MedicationStatus status = MedicationStatus.soon;

        if (logData.containsKey(key)) {
          final s = logData[key]["status"];
          status = MedicationStatus.values.firstWhere(
            (e) => e.name == s,
            orElse: () => MedicationStatus.soon,
          );
        }

        result.add(Medication(
          id: id,
          name: med["name"],
          dosage: med["dosage"],
          time: time,
          status: status,
        ));
      }
    });

    if (mounted) setState(() => medications = result);
  }

  Future<void> _saveMedicationStatus(Medication med, MedicationStatus newStatus) async {
    if (_uid == null) return;
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    await _dbRef
        .child("users/$_uid/medicationLogs/$today/${_medKey(med.name, med.time)}")
        .set({
      "status": newStatus.name,
      "timestamp": DateTime.now().toIso8601String(),
      "name": med.name,
      "dosage": med.dosage,
      "time": med.time,
    });
  }

  String _currentWeekdayKey() {
    switch (DateTime.now().weekday) {
      case DateTime.sunday:
        return "sunday";
      case DateTime.monday:
        return "monday";
      case DateTime.tuesday:
        return "tuesday";
      case DateTime.wednesday:
        return "wednesday";
      case DateTime.thursday:
        return "thursday";
      case DateTime.friday:
        return "friday";
      case DateTime.saturday:
        return "saturday";
      default:
        return "monday";
    }
  }

  String _medKey(String name, String time) => "${name.trim()}_${time.trim()}";

  Future<void> _saveTodayStepsGoal(int goal) async {
    if (_uid == null) return;
    final dayKey = _currentWeekdayKey();
    await _dbRef.child("users/$_uid/weeklyActivity/$dayKey").update({
      "goal": goal,
      "lastUpdate": DateTime.now().toIso8601String(),
    });
  }

  Future<void> _saveTodaySteps(int steps) async {
    if (_uid == null) return;
    final dayKey = _currentWeekdayKey();
    await _dbRef.child("users/$_uid/weeklyActivity/$dayKey").update({
      "steps": steps,
      "lastUpdate": DateTime.now().toIso8601String(),
    });
  }

  Future<void> _saveDailyUserMetrics() async {
    if (_uid == null) return;

    await _dbRef.child("users/$_uid/metrics").update({
      "sleepQuality": sleepQuality,
      "regularActivity": regularActivity,
      "waterIntake": waterIntake,
      "sleepHours": calculatedSleepHours,
      "sleepTime": sleepTime != null ? "${sleepTime!.hour}:${sleepTime!.minute}" : null,
      "wakeTime": wakeTime != null ? "${wakeTime!.hour}:${wakeTime!.minute}" : null,
      "lastUpdate": DateTime.now().toIso8601String(),
    });
  }

  Future<void> _startLocationStream() async {
    if (_uid == null) return;

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("enable_location_service".tr())),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("location_permission_denied".tr())),
      );
      return;
    }

    _positionSub?.cancel();

    final current = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    await _saveLocationToFirebase(current);

    _positionSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((pos) {
      _saveLocationToFirebase(pos);
    });
  }

  void _stopLocationStream() {
    _positionSub?.cancel();
    _positionSub = null;
  }

  Future<void> _saveLocationToFirebase(Position pos) async {
    if (_uid == null) return;

    final now = DateTime.now().toIso8601String();

    if (mounted) {
      setState(() {
        _lastLat = pos.latitude;
        _lastLng = pos.longitude;
        _lastLocationUpdate = now;
      });
    }

    await _dbRef.child("users/$_uid/location").set({
      "lat": pos.latitude,
      "lng": pos.longitude,
      "lastUpdate": now,
    });

    await _dbRef.child("users/$_uid/locationHistory").push().set({
      "lat": pos.latitude,
      "lng": pos.longitude,
      "timestamp": now,
    });
  }

  Future<void> _handleLocationToggle(bool value) async {
    if (_uid == null) return;

    if (mounted) setState(() => locationSharingEnabled = value);

    await _dbRef.child("users/$_uid/locationSharingEnabled").set(locationSharingEnabled);

    if (locationSharingEnabled) {
      await _startLocationStream();
    } else {
      _stopLocationStream();
    }
  }

  void _openMapDialog() {
    if (_lastLat == null || _lastLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("no_location_recorded".tr())),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          height: 360,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "current_location".tr(),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(_lastLat!, _lastLng!),
                      initialZoom: 15,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.epicare',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            width: 40,
                            height: 40,
                            point: LatLng(_lastLat!, _lastLng!),
                            child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStepsGoalDialog() {
    final controller = TextEditingController(text: stepsGoal > 0 ? stepsGoal.toString() : "");

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("steps_goal_dialog_title".tr()),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(hintText: "steps_goal_placeholder".tr()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("cancel".tr()),
          ),
          TextButton(
            onPressed: () async {
              final v = int.tryParse(controller.text);
              if (v != null && v > 0) {
                if (mounted) setState(() => stepsGoal = v);
                await _saveTodayStepsGoal(v);
              }
              Navigator.pop(context);
            },
            child: Text("save".tr()),
          ),
        ],
      ),
    );
  }

  void _showSleepQualityDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("sleep_quality_title".tr()),
        content: Text("sleep_quality_question".tr()),
        actions: [
          TextButton(
            onPressed: () {
              if (mounted) setState(() => sleepQuality = false);
              _calculateSeizureRisk();
              _saveDailyUserMetrics();
              Navigator.pop(context);
            },
            child: Text("no".tr()),
          ),
          TextButton(
            onPressed: () {
              if (mounted) setState(() => sleepQuality = true);
              _calculateSeizureRisk();
              _saveDailyUserMetrics();
              Navigator.pop(context);
            },
            child: Text("yes".tr()),
          ),
        ],
      ),
    );
  }

  void _showActivityDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("physical_activity_title".tr()),
        content: Text("Do you practice a Physical_activity regularly?".tr()),
        actions: [
          TextButton(
            onPressed: () {
              if (mounted) setState(() => regularActivity = false);
              _calculateSeizureRisk();
              _saveDailyUserMetrics();
              Navigator.pop(context);
            },
            child: Text("no".tr()),
          ),
          TextButton(
            onPressed: () {
              if (mounted) setState(() => regularActivity = true);
              _calculateSeizureRisk();
              _saveDailyUserMetrics();
              Navigator.pop(context);
            },
            child: Text("yes".tr()),
          ),
        ],
      ),
    );
  }

  void _showWaterDialog() {
    int temp = waterIntake;
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (_, setX) {
          return AlertDialog(
            title: Text("water_intake_title".tr()),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    if (temp > 0) setX(() => temp--);
                  },
                  icon: const Icon(Icons.remove_circle_outline, size: 32),
                ),
                Text("$temp ${"cups".tr()}", style: const TextStyle(fontSize: 22)),
                IconButton(
                  onPressed: () => setX(() => temp++),
                  icon: const Icon(Icons.add_circle_outline, size: 32),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("cancel".tr()),
              ),
              TextButton(
                onPressed: () {
                  if (mounted) setState(() => waterIntake = temp);
                  _saveDailyUserMetrics();
                  _calculateSeizureRisk();
                  Navigator.pop(context);
                },
                child: Text("done".tr()),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showSleepHoursDialog() {
    TimeOfDay? tempSleep = sleepTime;
    TimeOfDay? tempWake = wakeTime;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (_, setX) {
          return AlertDialog(
            title: Text("sleep_hours_title".tr()),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text("when_sleep?".tr()),
                  subtitle: Text(
                    tempSleep != null
                        ? "${tempSleep!.hour.toString().padLeft(2, '0')}:${tempSleep!.minute.toString().padLeft(2, '0')}"
                        : "select_time".tr(),
                  ),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: tempSleep ?? TimeOfDay.now(),
                    );
                    if (picked != null) setX(() => tempSleep = picked);
                  },
                ),
                ListTile(
                  title: Text("when_wake?".tr()),
                  subtitle: Text(
                    tempWake != null
                        ? "${tempWake!.hour.toString().padLeft(2, '0')}:${tempWake!.minute.toString().padLeft(2, '0')}"
                        : "select_time".tr(),
                  ),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: tempWake ?? TimeOfDay.now(),
                    );
                    if (picked != null) setX(() => tempWake = picked);
                  },
                ),
                const SizedBox(height: 10),
                if (tempSleep != null && tempWake != null)
                  Text(
                    "${"total_sleep".tr()}: ${_calculateSleepDuration(tempSleep!, tempWake!).toStringAsFixed(1)} ساعة",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("cancel".tr()),
              ),
              TextButton(
                onPressed: () {
                  if (tempSleep != null && tempWake != null) {
                    if (mounted) {
                      setState(() {
                        sleepTime = tempSleep;
                        wakeTime = tempWake;
                        calculatedSleepHours = _calculateSleepDuration(tempSleep!, tempWake!);
                      });
                    }
                    _saveDailyUserMetrics();
                    _calculateSeizureRisk();
                  }
                  Navigator.pop(context);
                },
                child: Text("done".tr()),
              ),
            ],
          );
        },
      ),
    );
  }

  double _calculateSleepDuration(TimeOfDay sleep, TimeOfDay wake) {
    final start = sleep.hour * 60 + sleep.minute;
    final end = wake.hour * 60 + wake.minute;
    int diff = end - start;
    if (diff < 0) diff += 24 * 60;
    return diff / 60.0;
  }

  void _showMedicationDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("medication_name".tr()),
        content: Text("dosage".tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("close".tr()),
          ),
        ],
      ),
    );
  }

  void _triggerSeizureState() async {
    if (_isSeizureActive) return;

    if (mounted) setState(() => _isSeizureActive = true);
    
    await NotificationService.showEmergencyAlert(
      contactName: userFullName,
      message: "🚨 Seizure detected! Emergency alert activated.",
    );
    
    await _handleSeizureAlert();
    
    await EmergencyService.triggerEmergency(
      context,
      contacts: emergencyContacts,
    );

    _seizureTimer?.cancel();
    _seizureTimer = Timer(const Duration(minutes: 2), () {
      if (mounted) setState(() => _isSeizureActive = false);
    });
  }

  Future<List<Contact>> _loadEmergencyContacts() async {
    if (_uid == null) return [];

    final snap = await _dbRef.child("users/$_uid/contacts").get();
    if (!snap.exists || snap.value == null) return [];

    final Map data = Map<String, dynamic>.from(snap.value as Map);

    return data.entries.map((e) {
      final m = Map<String, dynamic>.from(e.value);

      return Contact(
        id: e.key.hashCode,
        name: m["name"] ?? "",
        relation: m["relation"] ?? "",
        phone: m["phone"] ?? "",
        sharingLocation: m["sharingLocation"] ?? true,
        notifyOnSeizure: m["notifyOnSeizure"] ?? true,
        fcmToken: m["fcmToken"],
      );
    }).toList();
  }

  Future<void> _handleSeizureAlert() async {
    if (_uid == null) return;

    try {
      await EmergencyService.playAlarm();
    } catch (e) {
      debugPrint("Alarm Error: $e");
    }

    final alertRef = _dbRef.child("emergencyAlerts/$_uid").push();

    final payload = <String, dynamic>{
      "timestamp": DateTime.now().toIso8601String(),
      "userId": _uid,
      "type": "seizure_alert",
      "severity": null,
      "duration": null,
    };

    if (_lastLat != null && _lastLng != null) {
      payload["lat"] = _lastLat;
      payload["lng"] = _lastLng;
      payload["location"] =
          "https://www.google.com/maps/search/?api=1&query=$_lastLat,$_lastLng";
    }

    await alertRef.set(payload);

    if (!mounted) return;
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     content: Text("🚨 ${"emergency_alert_sent_snackbar".tr()}"),
    //     backgroundColor: Colors.red,
    //   ),
    // );

    await _loadLastSeizure();
  }

  @override
  Widget build(BuildContext context) {
    final total = medications.length;
    final taken = medications.where((m) => m.status == MedicationStatus.taken).length;
    final isMedicationAdherent = total > 0 && taken >= (total * 0.7);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadTodayMedications();
          await _loadLocationInfo();
          await _loadSeizureRisk();
          await _loadLastSeizure();
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              flexibleSpace: _buildHeader(),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Container(
                  //   padding: const EdgeInsets.all(12),
                  //   margin: const EdgeInsets.only(bottom: 16),
                  //   decoration: BoxDecoration(
                  //     color: _btConnected? Colors.green.shade50 : Colors.red.shade50,
                  //     borderRadius: BorderRadius.circular(12),
                  //     border: Border.all(
                  //       color: _btConnected ? Colors.green : Colors.red,
                  //     ),
                  //   ),
                  //   child: Row(
                  //     children: [
                  //       Icon(Icons.bluetooth, color: _btConnected ? Colors.green : Colors.red),
                  //       const SizedBox(width: 8),
                  //       Text(
                  //         _btConnected ? "Bluetooth: متصل" : "Bluetooth: غير متصل",
                  //         style: TextStyle(
                  //           color: _btConnected ? Colors.green : Colors.red,
                  //           fontWeight: FontWeight.bold,
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),

                  Row(
                    children: [
                      Expanded(child: HeartRateCard(heartRate: patientData?.heartRate ?? 0)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: StepsCard(
                          steps: patientData?.steps ?? 0,
                          goal: stepsGoal,
                          onTap: _showStepsGoalDialog,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  if (_lastProb != null)
                    // Container(
                    //   padding: const EdgeInsets.all(12),
                    //   margin: const EdgeInsets.only(bottom: 16),
                    //   decoration: BoxDecoration(
                    //     color: Colors.blue.shade50,
                    //     borderRadius: BorderRadius.circular(12),
                    //   ),
                    //   child: Column(
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: [
                    //       const Text("ML Model Prediction:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    //       const SizedBox(height: 4),
                    //       Text("Probability: ${(_lastProb! * 100).toStringAsFixed(1)}%", style: const TextStyle(fontSize: 12)),
                    //       Text(
                    //         "Prediction: ${_lastPred == 1 ? '⚠️ Seizure Risk' : '✅ Normal'}",
                    //         style: TextStyle(
                    //           fontSize: 12,
                    //           color: _lastPred == 1 ? Colors.red : Colors.green,
                    //           fontWeight: FontWeight.bold,
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),

                  SeizureRiskCard(
                    risk: seizureRiskValue,
                    lastSeizure: lastSeizureText,
                    regularActivity: regularActivity,
                    medicationAdherent: isMedicationAdherent,
                    sleepQuality: sleepQuality,
                    onActivityTap: _showActivityDialog,
                    onMedicationTap: _showMedicationDialog,
                    onSleepQualityTap: _showSleepQualityDialog,
                  ),

                  const SizedBox(height: 16),

                  MedicationReminder(
                    medications: medications,
                    onAddMedication: _showAddMedicationDialog,
                    onStatusChanged: (med, newStatus) async {
                      if (mounted) setState(() => med.status = newStatus);
                      await _saveMedicationStatus(med, newStatus);
                      await _loadTodayMedications();
                      _calculateSeizureRisk();
                    },
                    onDeleteMedication: (med) async {
                      if (_uid == null) return;
                      await _dbRef.child("users/$_uid/medicationPlan/${med.id}").remove();
                      await _loadTodayMedications();
                      _calculateSeizureRisk();
                    },
                  ),

                  const SizedBox(height: 16),

                  LocationSharingCard(
                    enabled: locationSharingEnabled,
                    lastUpdate: _lastLocationUpdate,
                    lat: _lastLat,
                    lng: _lastLng,
                    onToggle: _handleLocationToggle,
                    onOpenMap: (locationSharingEnabled && _lastLat != null && _lastLng != null) ? _openMapDialog : null,
                  ),

                  const SizedBox(height: 16),

                  HealthMetricsCard(
                    sleepHours: calculatedSleepHours,
                    stressLevel: patientData?.stressLevel ?? 0,
                    waterIntake: waterIntake,
                    waterGoal: 8,
                    onWaterTap: _showWaterDialog,
                    onSleepHoursTap: _showSleepHoursDialog,
                  ),

                  const SizedBox(height: 16),

                  _emergencyButton(),

                  const SizedBox(height: 60),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return FlexibleSpaceBar(
      background: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.person, color: Colors.white, size: 30),
                    ),
                    ScaleTransition(
                      scale: _pulseAnimation,
                      child: Stack(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.monitor_heart_rounded, color: Colors.white, size: 28),
                          ),
                          Positioned(
                            right: 4,
                            top: 4,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: _statusColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Text(
                  "welcome".tr(),
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  userFullName,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  userNumber != null
                      ? "${"patient_number".tr()}: $userNumber"
                      : "${"patient_number".tr()}: ${"number_not_available".tr()}",
                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  decoration: BoxDecoration(
                    color: _isSeizureActive ? Colors.red : Colors.green,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(_isSeizureActive ? Icons.warning_amber_rounded : Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isSeizureActive ? "seizure_active".tr() : "status_normal".tr(),
                            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _isSeizureActive ? "emergency_alert_sent".tr() : "last_update_now".tr(),
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _emergencyButton() {
    return GestureDetector(
      onTap: _triggerSeizureState,
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Center(
          child: Text(
            "emergency_report_seizure".tr(),
            style: const TextStyle(color: Colors.white, fontSize: 22),
          ),
        ),
      ),
    );
  }

  void _showAddMedicationDialog() {
    final nameController = TextEditingController();
    final dosageController = TextEditingController();
    final List<TimeOfDay> times = [];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.medication_rounded, color: Color(0xFF2563EB)),
            const SizedBox(width: 8),
            Text("add_medication".tr()),
          ],
        ),
        content: StatefulBuilder(
          builder: (context, setX) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: "medication_name".tr(),
                      prefixIcon: const Icon(Icons.local_pharmacy),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: dosageController,
                    decoration: InputDecoration(
                      labelText: "dosage".tr(),
                      prefixIcon: const Icon(Icons.science),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("medication_times".tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.add_circle, color: Colors.blue),
                        onPressed: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (picked != null) setX(() => times.add(picked));
                        },
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: 8,
                    children: times.map((t) {
                      final hh = t.hour.toString().padLeft(2, '0');
                      final mm = t.minute.toString().padLeft(2, '0');
                      return Chip(
                        label: Text("$hh:$mm"),
                        deleteIcon: const Icon(Icons.close),
                        onDeleted: () => setX(() => times.remove(t)),
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("cancel".tr())),
          ElevatedButton(
            onPressed: () async {
              if (_uid == null || nameController.text.isEmpty || dosageController.text.isEmpty || times.isEmpty) return;

              final timesString = times.map((t) {
                final hh = t.hour.toString().padLeft(2, '0');
                final mm = t.minute.toString().padLeft(2, '0');
                return "$hh:$mm";
              }).toList();

              await _dbRef.child("users/$_uid/medicationPlan").push().set({
                "name": nameController.text.trim(),
                "dosage": dosageController.text.trim(),
                "times": timesString,
                "active": true,
                "createdAt": DateTime.now().toIso8601String(),
              });

              Navigator.pop(context);
              await _loadTodayMedications();
              _calculateSeizureRisk();
            },
            child: Text("save".tr()),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _btStatusTimer?.cancel(); 
    _metricsSub?.cancel();
    _riskSub?.cancel();
    _seizureSub?.cancel();
    _positionSub?.cancel();
    _pulseController.dispose();
    _confirmTimer?.cancel();
    _seizureTimer?.cancel();
    super.dispose();
  }
}
