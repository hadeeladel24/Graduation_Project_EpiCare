import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:easy_localization/easy_localization.dart';

class LocationHistoryScreen extends StatefulWidget {
  const LocationHistoryScreen({super.key});

  @override
  State<LocationHistoryScreen> createState() => _LocationHistoryScreenState();
}

class _LocationHistoryScreenState extends State<LocationHistoryScreen> {
  final _dbRef = FirebaseDatabase.instance.ref();
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  List<LatLng> pathPoints = [];
  List<Polyline> polylines = [];
  List<Marker> markers = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadLocationHistory();
  }

  Future<void> _loadLocationHistory() async {
    final snap = await _dbRef.child("users/$uid/locationHistory").get();

    if (!snap.exists) {
      setState(() => loading = false);
      return;
    }

    final data = Map<String, dynamic>.from(snap.value as Map);
    pathPoints.clear();
    markers.clear();
    polylines.clear();

    data.forEach((key, value) {
      final lat = (value["lat"] as num).toDouble();
      final lng = (value["lng"] as num).toDouble();
      pathPoints.add(LatLng(lat, lng));
    });

    if (pathPoints.isNotEmpty) {
      // حساب حجم الأيقونة حسب حجم الشاشة
      final iconSize = MediaQuery.of(context).size.width * 0.1;

      markers.add(
        Marker(
          point: pathPoints.last,
          width: iconSize,
          height: iconSize,
          child: Icon(Icons.location_on, color: Colors.red, size: iconSize),
        ),
      );

      polylines.add(
        Polyline(
          points: pathPoints,
          strokeWidth: 4,
          color: Colors.blue,
        ),
      );
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("patient_movement_history".tr()),
        backgroundColor: const Color(0xFF2563EB),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : pathPoints.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_off,
                        size: MediaQuery.of(context).size.width * 0.2,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                      Text(
                        "no_location_history".tr(),
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.045,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : FlutterMap(
                  options: MapOptions(
                    initialCenter: pathPoints.last,
                    initialZoom: 15,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.epicare.app',
                    ),
                    PolylineLayer(polylines: polylines),
                    MarkerLayer(markers: markers),
                  ],
                ),
    );
  }
}
