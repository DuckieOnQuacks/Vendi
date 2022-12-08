import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

const LatLng curentLocation = LatLng(39.5299, -119.8143);

class Homepage extends StatefulWidget
{
  const Homepage({Key? key}) : super(key: key);
  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage>
{
  //late GoogleMapController _mapController;
  final Map<String, Marker> _markers = {};
  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
        target: curentLocation,
          zoom: 14,
      ),
        onMapCreated: (controller) {
          //_mapController = controller;
          addMarker('Test Marker', curentLocation);
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
