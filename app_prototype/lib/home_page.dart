import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

const LatLng currentLocation = LatLng(39.5299, -119.8143);

class Homepage extends StatefulWidget
{
  const Homepage({Key? key}) : super(key: key);
  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage>
{
  bool? isChecked = false;
  late GoogleMapController _mapController;
  final Map<String, Marker> _markers = {};
  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      body: GoogleMap(
        mapToolbarEnabled: false,
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

  // Method for adding a marker to the marker list
  addMarker(String id, LatLng location)
  {
    var marker = Marker(
        markerId: MarkerId(id),
        position: location,
        infoWindow: InfoWindow( title: id,
          onTap: () {
            showModalBottomSheet(context: context, builder: (context) {
              return createBottomSheet();
            });
          }
        )
    );

    _markers[id] = marker;
    setState(() {});
  }

// Bottom sheet widget. It will be the basic container for the template information of a vending machine.
// This can be edited as you wish.
  Widget createBottomSheet() {
    return Center(
      child: Column(
        children: [
          // Bottom sheets cannot be updated from outside the page so a stateful builder is needed to handle state changes.
          // Currently this checkbox should only work for a single vending machine. Whether or not this should be expanded is tbd.
          StatefulBuilder(
            builder: (BuildContext context, setState) {
              return Checkbox(value: isChecked, onChanged: (bool? checked) {
                setState(() {
                  isChecked = checked;
                });
              });
            },
          ),
          ElevatedButton(onPressed: () {
            Navigator.pop(context);
          }, child: const Text("Close Menu"))
        ],
      )
    );
  }
}
