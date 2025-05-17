import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  final String museumName;
  final double latitude;
  final double longitude;

  const MapScreen({
    super.key,
    required this.museumName,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;

  @override
  Widget build(BuildContext context) {
    LatLng museumLocation = LatLng(widget.latitude, widget.longitude);

    return Scaffold(
      appBar: AppBar(title: Text(widget.museumName)),
      body: GoogleMap(
        onMapCreated: (controller) {
          mapController = controller;
        },
        initialCameraPosition: CameraPosition(
          target: museumLocation,
          zoom: 15.0,
        ),
        markers: {
          Marker(
            markerId: const MarkerId('museumLocation'),
            position: museumLocation,
            infoWindow: InfoWindow(title: widget.museumName),
          ),
        },
      ),
    );
  }
}
