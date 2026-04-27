import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userData;
  bool isLoading = true;

  bool isLocationSharingEnabled = true;
  bool isAutoSendEnabled = true;
  String formatDate(String? iso) {
    if (iso == null) return '---';
    try {
      final dt = DateTime.parse(iso);
      return DateFormat('yyyy-MM-dd').format(dt);
    } catch (_) {
      return iso;
    }
  }

  final List<Map<String, String>> mockContacts = [
    {'name': 'أحمد علي', 'phone': '+972 59-000-0001'},
    {'name': 'سارة محمد', 'phone': '+972 59-000-0002'},
    {'name': 'خالد يوسف', 'phone': '+972 59-000-0003'},
  ];

  final Map<String, String> fallbackValues = {
    'fullName': 'Noor Ahmad',
    'email': 'noor@example.com',
    'birthDate': '01/01/1990',
    'phone': '+972 59-000-0000',
    'diagnosis_date': '---',
    'patientType': 'المريض',
  };

  int activeContactsCount = 0;

  @override
  void initState() {
    super.initState();
    fetchUserData();
    _loadContactsCount();
  }

  Future<void> _loadContactsCount() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      final ref = FirebaseDatabase.instance.ref('users/$userId/contacts');
      final snapshot = await ref.get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        int count = 0;
        data.forEach((key, value) {
          if (value is Map && value['sharingLocation'] == true) {
            count++;
          }
        });

        setState(() {
          activeContactsCount = count;
        });
      }
    } catch (e) {
      debugPrint('Error loading contacts count: $e');
    }
  }

  String calculateAge(String birthDate) {
    try {
      List<String> parts =
          birthDate.contains('/') ? birthDate.split('/') : birthDate.split('-');
      if (parts.length == 3) {
        int day = int.parse(parts[0]);
        int month = int.parse(parts[1]);
        int year = int.parse(parts[2]);

        DateTime birth = DateTime(year, month, day);
        DateTime today = DateTime.now();

        int age = today.year - birth.year;
        if (today.month < birth.month ||
            (today.month == birth.month && today.day < birth.day)) {
          age--;
        }
        return '$age ${'year'.tr()}';
      }
    } catch (e) {
      debugPrint('Error calculating age: $e');
    }
    return '-- ${'year'.tr()}';
  }

  Future<void> fetchUserData() async {
    setState(() => isLoading = true);
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        setState(() {
          userData = Map<String, dynamic>.from(fallbackValues);
          isLoading = false;
        });
        return;
      }

      final ref = FirebaseDatabase.instance.ref('users/$userId');
      final snapshot = await ref.get();

      if (snapshot.exists && snapshot.value != null) {
        final raw = snapshot.value;
        if (raw is Map) {
          final map = raw.map((k, v) => MapEntry(k.toString(), v));
          final merged = <String, dynamic>{};
          fallbackValues.forEach((k, v) {
            merged[k] = map.containsKey(k) &&
                    map[k] != null &&
                    map[k].toString().trim().isNotEmpty
                ? map[k]
                : v;
          });
          map.forEach((k, v) {
            if (!merged.containsKey(k)) merged[k] = v;
          });

          if (map.containsKey('locationSharingEnabled')) {
            isLocationSharingEnabled = map['locationSharingEnabled'] == true;
          }
          if (map.containsKey('autoSendEnabled')) {
            isAutoSendEnabled = map['autoSendEnabled'] == true;
          }

          setState(() {
            userData = merged;
            isLoading = false;
          });
          return;
        }
      }

      setState(() {
        userData = Map<String, dynamic>.from(fallbackValues);
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching user data: $e');
      setState(() {
        userData = Map<String, dynamic>.from(fallbackValues);
        isLoading = false;
      });
    }
  }

  Future<void> saveLocationSettings() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        final ref = FirebaseDatabase.instance.ref('users/$userId');
        await ref.update({
          'locationSharingEnabled': isLocationSharingEnabled,
          'autoSendEnabled': isAutoSendEnabled,
        });
      }
    } catch (e) {
      debugPrint('Error saving location settings: $e');
    }
  }

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final textScale = MediaQuery.of(context).textScaleFactor;

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (userData == null) {
      return Scaffold(
        body: Center(child: Text("no_data_available").tr()),
      );
    }

    List<Map<String, String>> contacts = mockContacts;
    final rawContacts = userData!['contacts'];
    if (rawContacts is List) {
      final parsed = <Map<String, String>>[];
      for (var item in rawContacts) {
        if (item is Map) {
          final name = item['name']?.toString() ??
              item['fullName']?.toString() ??
              "contact".tr();
          final phone = item['phone']?.toString() ??
              item['tel']?.toString() ??
              "phone_ex".tr();
          parsed.add({'name': name, 'phone': phone});
        }
      }
      if (parsed.isNotEmpty) contacts = parsed;
    }

    String birthDate =
        userData!['birthDate']?.toString() ?? fallbackValues['birthDate']!;
    String age = calculateAge(birthDate);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          "profile".tr(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20 * textScale,
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
        actions: [
          IconButton(
            icon: Icon(Icons.logout_rounded,
                color: Colors.white, size: 24 * textScale),
            tooltip: "logout".tr(),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text("logout_confirm_title".tr()),
                  content: Text("logout_confirm_message".tr()),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text("cancel".tr())),
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: Text("confirm".tr())),
                  ],
                ),
              );
              if (confirm == true) _signOut(context);
            },
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(width * 0.04),
        children: [
          // Profile Card
          Container(
            padding: EdgeInsets.all(width * 0.05),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(width * 0.05),
              border: Border.all(color: const Color(0xFFE5E7EB), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: width * 0.025,
                  offset: Offset(0, height * 0.004),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: width * 0.12,
                      height: width * 0.12,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                        ),
                        borderRadius: BorderRadius.circular(width * 0.03),
                      ),
                      child: Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: width * 0.07,
                      ),
                    ),
                    SizedBox(width: width * 0.03),
                    Text(
                      "user_data".tr(),
                      style: TextStyle(
                        fontSize: 18 * textScale,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF111827),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: height * 0.02),
                Container(
                  padding: EdgeInsets.all(width * 0.04),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(width * 0.03),
                    border:
                        Border.all(color: const Color(0xFFBFDBFE), width: 2),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: width * 0.16,
                        height: width * 0.16,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                          ),
                          borderRadius: BorderRadius.circular(width * 0.03),
                        ),
                        child: Icon(
                          Icons.person_rounded,
                          color: Colors.white,
                          size: width * 0.08,
                        ),
                      ),
                      SizedBox(width: width * 0.04),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userData!['fullName']?.toString() ??
                                  fallbackValues['fullName']!,
                              style: TextStyle(
                                fontSize: 18 * textScale,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF111827),
                              ),
                            ),
                            SizedBox(height: height * 0.005),
                            Text(
                               getPatientTypeText(
                              userData?['patientType'] ?? 'patient',
                                    ),

                              style: TextStyle(
                                fontSize: 14 * textScale,
                                color: const Color.fromARGB(255, 104, 166, 185),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: height * 0.02),
                _buildInfoRow(width, textScale, "birth_date".tr(), birthDate),
                _buildInfoRow(width, textScale, "age".tr(), age),
                _buildInfoRow(width, textScale, "phone".tr(),
                    userData!['phone']?.toString() ?? fallbackValues['phone']!),
                _buildInfoRow(
                  width,
                  textScale,
                  "diagnosis_date".tr(),
                  formatDate(userData!['diagnosis_date']),
                ),
              ],
            ),
          ),
          SizedBox(height: height * 0.02),

          // Location Settings Card
          Container(
            padding: EdgeInsets.all(width * 0.05),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(width * 0.05),
              border: Border.all(color: const Color(0xFFBBF7D0), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: width * 0.025,
                  offset: Offset(0, height * 0.004),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: width * 0.12,
                      height: width * 0.12,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF10B981), Color(0xFF059669)],
                        ),
                        borderRadius: BorderRadius.circular(width * 0.03),
                      ),
                      child: Icon(
                        Icons.location_on_rounded,
                        color: Colors.white,
                        size: width * 0.06,
                      ),
                    ),
                    SizedBox(width: width * 0.03),
                    Text(
                      "location_settings".tr(),
                      style: TextStyle(
                        fontSize: 18 * textScale,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF111827),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: height * 0.02),
                _buildSettingRow(
                    width,
                    textScale,
                    "continuous_location_sharing".tr(),
                    isLocationSharingEnabled, (value) {
                  setState(() => isLocationSharingEnabled = value);
                  saveLocationSettings();
                }),
                _buildSettingRow(width, textScale, "auto_send_on_seizure".tr(),
                    isAutoSendEnabled, (value) {
                  setState(() => isAutoSendEnabled = value);
                  saveLocationSettings();
                }),
                SizedBox(height: height * 0.01),
                Text(
                  "location_shared_with".tr() +
                      " $activeContactsCount ${"contacts".tr()}",
                  style: TextStyle(
                      fontSize: 14 * textScale, color: const Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
          SizedBox(height: height * 0.03),

          Center(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: EdgeInsets.symmetric(
                    horizontal: width * 0.06, vertical: height * 0.015),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(width * 0.03),
                ),
              ),
              icon: Icon(Icons.logout_rounded,
                  color: Colors.white, size: 24 * textScale),
              label: Text('logout'.tr(),
                  style:
                      TextStyle(color: Colors.white, fontSize: 16 * textScale)),
              onPressed: () => _signOut(context),
            ),
          ),
          SizedBox(height: height * 0.06),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
      double width, double textScale, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: width * 0.03),
      child: Container(
        padding: EdgeInsets.all(width * 0.03),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(width * 0.02),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 14 * textScale, color: const Color(0xFF6B7280))),
            Text(value,
                style: TextStyle(
                    fontSize: 14 * textScale,
                    color: const Color(0xFF111827),
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingRow(double width, double textScale, String label,
      bool enabled, Function(bool) onChanged) {
    return Padding(
      padding: EdgeInsets.only(bottom: width * 0.03),
      child: Container(
        padding: EdgeInsets.all(width * 0.035),
        decoration: BoxDecoration(
          color: enabled ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2),
          borderRadius: BorderRadius.circular(width * 0.03),
          border: Border.all(
            color: enabled ? const Color(0xFFBBF7D0) : const Color(0xFFFECACA),
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(label,
                  style: TextStyle(
                    fontSize: 14 * textScale,
                    color: enabled
                        ? const Color(0xFF065F46)
                        : const Color(0xFF991B1B),
                  )),
            ),
            Switch(
              value: enabled,
              onChanged: onChanged,
              activeColor: const Color(0xFF10B981),
              inactiveThumbColor: Colors.redAccent,
            ),
          ],
        ),
      ),
    );
  }
}
String getPatientTypeText(String value) {
  switch (value) {
    case "patient":
      return "patient".tr();
    default:
      return "patient".tr();
  }
}

