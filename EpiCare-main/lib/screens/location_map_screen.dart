import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:easy_localization/easy_localization.dart';
class LocationMapScreen extends StatelessWidget {
  final double lat;
  final double lng;

  const LocationMapScreen({
    super.key,
    required this.lat,
    required this.lng,
  });

  @override
  Widget build(BuildContext context) {
    final point = LatLng(lat, lng);

    return Scaffold(
      appBar: AppBar(
        title:  Text("patieny_location".tr()),
        backgroundColor: const Color(0xFF2563EB),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: point,
          initialZoom: 15,
        ),
        children: [
          // طبقة الخريطة (OpenStreetMap مجانية)
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: 'com.example.epicare',
          ),

          // ماركر للمريض
          MarkerLayer(
            markers: [
              Marker(
                point: point,
                width: 60,
                height: 60,
                child: const Icon(
                  Icons.location_pin,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
