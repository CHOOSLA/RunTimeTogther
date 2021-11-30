import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:runtimetogether/position.dart';

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() {
    return MapSampleState();
  }
}

class MapSampleState extends State<MapSample> {
  Completer<GoogleMapController> _controller = Completer();

  late LocationSettings locationSettings;
// 위도 경도
  double latitude = 0.0;
  double longitude = 0.0;

  static final CameraPosition _initPosition = CameraPosition(
    target: LatLng(36.7688, 126.9345),
    zoom: 18.4746,
  );

  @override
  void initState() {
    super.initState();
    if (defaultTargetPlatform == TargetPlatform.android) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
        forceLocationManager: true,
        intervalDuration: const Duration(seconds: 10),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
        pauseLocationUpdatesAutomatically: true,
      );
    } else {
      locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      );
    }
    _getCurremtPosition();
  }

  _getCurremtPosition() async {
    Position we = await determinePosition();
    latitude = we.latitude;
    longitude = we.longitude;
    setState(() {});
  }

  Future<void> _refresh() async {
    _getCurremtPosition();
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        zoom: 19.151926040649414, target: LatLng(latitude, longitude))));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: longitude == 0.0
          ?
          //현재 위치 받아질 때 까지 기다림
          Center(
              child: CircularProgressIndicator(),
            )
          //받아졌으면 여기로
          : GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: _initPosition,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _refresh,
        label: Text('현재 위치로 이동'),
        icon: Icon(Icons.refresh),
      ),
    );
  }
}
