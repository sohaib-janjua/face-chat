import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:login_signup_auth/core/const.dart';

class MapTab extends StatefulWidget {
  const MapTab({super.key});

  @override
  State<MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> {
  LatLng myPosition = const LatLng(30.672425377080838, 73.64876633444932);

  final String uid = FirebaseAuth.instance.currentUser!.uid;

  late BitmapDescriptor mapIcon;

  LatLng destination = const LatLng(30.672425377080838, 73.64876633444932);

  @override
  void initState() {
    super.initState();
    BitmapDescriptor.fromAssetImage(
      ImageConfiguration.empty,
      "assets/images/map_icon.png",
    ).then((value) {
      setState(() {
        mapIcon = value;
      });
    });
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
          'is_live': true,
        });

        mapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(p.latitude, p.longitude),
            zoom: 16,
          ),
        ));
      },
    );
    FirebaseFirestore.instance
        .collection('users')
        .where(
          'is_live',
          isEqualTo: true,
        )
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
              ),
              //icon: mapIcon,
            );
          });
        }
      }
    });
  }

  Map<String, Marker> markers = {};
  Map<String, Polyline> pollyLines = {};

  late GoogleMapController mapController;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(30.672425377080838, 73.64876633444932),
            zoom: 16,
          ),
          markers: markers.values.toSet(),
          polylines: pollyLines.values.toSet(),
          myLocationEnabled: true,
          mapType: MapType.satellite,
          onCameraIdle: () {
            print("On Camera Stop");
          },
          onCameraMove: (position) {
            log(position.target.latitude.toString());
          },
          onTap: (argument) {
            markers['destination'] = Marker(
              markerId: const MarkerId('destination'),
              position: argument,
            );
            setState(() {
              destination = argument;
            });
          },
          zoomControlsEnabled: false,
          padding: const EdgeInsets.symmetric(vertical: 50),
          onMapCreated: (controller) {
            mapController = controller;
            controller.setMapStyle(Const.mapStyle);
          },
        ),
        Row(
          children: [
            IconButton(
              onPressed: () async {
                Position p = await Geolocator.getCurrentPosition();
                mapController.animateCamera(CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: LatLng(p.latitude, p.longitude),
                    zoom: 16,
                  ),
                ));
              },
              icon: const Icon(
                Icons.atm,
              ),
            ),
            IconButton(
              onPressed: () async {
                mapController.setMapStyle(Const.mapNightStyle);
              },
              icon: const Icon(
                Icons.night_shelter,
              ),
            ),
            IconButton(
              onPressed: () async {
                PolylinePoints polylinePoints = PolylinePoints();
                Position p = await Geolocator.getCurrentPosition();

                var results = await polylinePoints.getRouteBetweenCoordinates(
                  "AIzaSyBE0ICUo4vIKNYv90657DD1qqm7YQQg",
                  PointLatLng(p.latitude, p.longitude),
                  PointLatLng(destination.latitude, destination.longitude),
                );

                pollyLines['route-1'] = Polyline(
                  polylineId: const PolylineId('route-1'),
                  color: Colors.redAccent,
                  width: 12,
                  endCap: Cap.roundCap,
                  startCap: Cap.roundCap,
                  points: results.points
                      .map(
                        (e) => LatLng(e.latitude, e.longitude),
                      )
                      .toList(),
                );
                setState(() {});
                //results.points;
              },
              icon: const Icon(
                Icons.route,
              ),
            ),
          ],
        )
      ],
    );
  }

  @override
  void dispose() {
    FirebaseFirestore.instance.collection('users').doc(uid).update({
      'is_live': false,
    });
    super.dispose();
  }
}
