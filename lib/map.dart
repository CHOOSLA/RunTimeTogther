import 'dart:async';
import 'dart:ffi';

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
  double _latitude = 0.0;
  double _longitude = 0.0;

  //친구들의 위치
  List<Marker> _friends = [];

  //아이콘
  var icon;

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

    //이게 지금 친구들 위치 뽑아내는 것

    //이것은 이제 애들이 움직였을 때
    //_friends[0] =
    //  _friends[0].copyWith(positionParam: LatLng(36.7749, 126.9327));

    //맵에서 지금 위치 받아오는 것, 이게 실행되면 이제 맵 화면이 보임
    _getCurremtPosition();
  }

  _getCurremtPosition() async {
    Position we = await determinePosition();
    _latitude = we.latitude;
    _longitude = we.longitude;
    setState(() {});
  }

  Future<void> _refresh() async {
    _getCurremtPosition();
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        zoom: 15, bearing: 0, target: LatLng(_latitude, _longitude))));
  }

  Future<BitmapDescriptor> getIcons() async {
    return await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(1, 1)), 'assets/pin.png');
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Center(
        child: FutureBuilder(
            future: getIcons(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              //해당 부분은 data를 아직 받아 오지 못했을때 실행되는 부분을 의미한다.
              if (snapshot.hasData == false) {
                return CircularProgressIndicator();
              }
              //error가 발생하게 될 경우 반환하게 되는 부분
              else if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: TextStyle(fontSize: 15),
                  ),
                );
              }
              // 데이터를 정상적으로 받아오게 되면 다음 부분을 실행하게 되는 것이다.
              else {
                _friends.add(new Marker(
                    markerId: MarkerId('1'),
                    icon: snapshot.data,
                    onTap: () => {print('마커눌림')},
                    position: LatLng(36.7749, 126.9327)));
                return GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: CameraPosition(
                      zoom: 15,
                      bearing: 0,
                      target: LatLng(_latitude, _longitude)),
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  markers: Set.from(_friends),
                );
              }
            }),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _refresh,
        label: Text('현재 위치로 이동'),
        icon: Icon(Icons.refresh),
      ),
    );
  }
}
