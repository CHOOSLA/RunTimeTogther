import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:angles/angles.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import 'package:runtimetogether/position.dart';
import 'dart:ui' as ui;
import 'package:image/image.dart' as image;
import 'package:runtimetogether/profilepainter.dart';
import 'package:http/http.dart' as http;
import 'package:runtimetogether/states/userstate.dart';

import 'states/env.dart';
import 'dart:convert';

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

    _getfriendProfile();

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

  _getfriendProfile() async {
    var url = Uri.parse('${Env.URL_PREFIX}/get_friends.php');

    final UserState state = Provider.of<UserState>(context, listen: false);

    var myid = state.id;

    var data = {'userid': '$myid'};

    var response = await http.post(url, body: json.encode(data));

    var decoded = json.decode(response.body);

    for (Map item in decoded) {
      String friendid = item['friendid'];

      var url = Uri.parse('${Env.URL_PREFIX}/get_user.php');
      var data = {'userid': '$friendid'};
      var response = await http.post(url, body: json.encode(data));
      var message = jsonDecode(response.body);
      print(message);
    }
  }

  _getCurremtPosition() async {
    Position we = await determinePosition();
    _latitude = we.latitude;
    _longitude = we.longitude;
    setState(() {});
  }

  //현재 위치로 돌아오는 기능
  Future<void> _refresh() async {
    _getCurremtPosition();
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        zoom: 15, bearing: 0, target: LatLng(_latitude, _longitude))));
  }

  //이제 여기 수정을 해야함
  Future<Uint8List> getIcon() async {
    //final Uint8List markerIcon = await getBytesFromAsset('assets/images/flutter.png', 100);
    final Uint8List markerIcon = await getBytesFromCanvas(200, 200);
    return markerIcon;
  }

  //이미지 불러오기
  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  //canvas로 그려서 가져오기
  Future<Uint8List> getBytesFromCanvas(int width, int height) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..color = Colors.green;
    final Radius radius = Radius.circular(20.0);
    canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(0.0, 0.0, width.toDouble(), height.toDouble()),
          topLeft: radius,
          topRight: radius,
          bottomLeft: radius,
          bottomRight: radius,
        ),
        paint);

    //아래 삼각형 그리기
    double triangleWidth = 50;
    Offset centerPoint =
        Offset(width / 2 - triangleWidth / 2, height.toDouble());

    Path path = Path();
    path.moveTo(centerPoint.dx, centerPoint.dy);
    path.lineTo(centerPoint.dx + triangleWidth, centerPoint.dy);
    path.lineTo((centerPoint.dx + (centerPoint.dx + triangleWidth)) / 2,
        centerPoint.dy + triangleWidth);

    path.close();

    canvas.drawPath(
        path,
        Paint()
          ..color = Colors.green
          ..style = PaintingStyle.fill);

    //여기 수정을해야함
    ProfilePainter profileImage = ProfilePainter(
        await _loadImage('assets/london.jpg', width - 30, height - 30),
        width.toDouble(),
        height.toDouble());

    profileImage.paint(canvas, Size(width.toDouble(), height.toDouble()));
    final img = await pictureRecorder
        .endRecording()
        .toImage(width, height + triangleWidth.round());
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  }

  Future<ui.Image> _loadImage(
      String imageAssetPath, int height, int width) async {
    final ByteData assetImageByteData = await rootBundle.load(imageAssetPath);
    image.Image? baseSizeImage =
        image.decodeImage(assetImageByteData.buffer.asUint8List());
    image.Image resizeImage =
        image.copyResize(baseSizeImage!, height: height, width: width);
    ui.Codec codec = await ui.instantiateImageCodec(
        Uint8List.fromList(image.encodePng(resizeImage)));
    ui.FrameInfo frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Center(
        child: _latitude == 0.0
            ? new CircularProgressIndicator(
                color: Colors.green,
              )
            : FutureBuilder(
                future: getIcon(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  //해당 부분은 data를 아직 받아 오지 못했을때 실행되는 부분을 의미한다.
                  if (snapshot.hasData == false) {
                    return CircularProgressIndicator(
                      color: Colors.greenAccent,
                    );
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
                    //이제 여기서 계속 통신 받아서 새로고침
                    _friends.add(new Marker(
                        markerId: MarkerId('1'),
                        icon: BitmapDescriptor.fromBytes(snapshot.data),
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
