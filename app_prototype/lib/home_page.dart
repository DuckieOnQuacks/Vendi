import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

const LatLng currentLocation = LatLng(39.5299, -119.8143);

class HomePage extends StatefulWidget
{
  const HomePage({Key? key}) : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
{
  late GoogleMapController _mapController;
  final Map<String, Marker> _markers = {};
  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
        target: currentLocation,
          zoom: 14,
      ),
        onMapCreated: (controller) {
          _mapController = controller;
          addMarker('Test Marker', currentLocation);
        },
        markers: _markers.values.toSet(),
      ),
    );
  }
  addMarker(String id, LatLng location)
  {
    var marker = Marker(
        markerId: MarkerId(id),
        position: location,
    );

    _markers[id] = marker;
    setState(() {});
  }
}
