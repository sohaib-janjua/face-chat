import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapTab extends StatefulWidget {
  const MapTab({super.key});

  @override
  State<MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> {
  LatLng myPosition = LatLng(30.672425377080838, 73.64876633444932);

  final String uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    getPermissionAndLocation();
  }

  Future getPermissionAndLocation() async {
    await Geolocator.requestPermission();

    Position p = await Geolocator.getCurrentPosition();
    Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
      distanceFilter: 1,
    )).listen(
      (event) {
        FirebaseFirestore.instance.collection('users').doc(uid).update({
          'location': GeoPoint(event.latitude, event.longitude),
        });
      },
    );
    FirebaseFirestore.instance
        .collection('users')
        .snapshots()
        .listen((collect) {
      for (var doc in collect.docs) {
        if (doc.data().containsKey('location')) {
          var geo = doc.data()['location'] as GeoPoint;
          setState(() {
            markers[doc.id] = Marker(
                markerId: MarkerId(doc.id),
                position: LatLng(geo.latitude, geo.longitude),
                infoWindow: InfoWindow(
                  title: doc.data()['name'],
                ));
          });
        }
      }
    });
  }

  Map<String, Marker> markers = {};

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: const CameraPosition(
        target: LatLng(30.672425377080838, 73.64876633444932),
        zoom: 16,
      ),
      markers: markers.values.toSet(),
      myLocationEnabled: true,
      padding: const EdgeInsets.symmetric(vertical: 50),
    );
  }
}
