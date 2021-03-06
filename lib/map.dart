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
import 'package:background_location/background_location.dart';

import 'package:runtimetogether/position.dart';
import 'dart:ui' as ui;
import 'package:image/image.dart' as image;
import 'package:runtimetogether/profilepainter.dart';
import 'package:http/http.dart' as http;
import 'package:runtimetogether/runmodal.dart';
import 'package:runtimetogether/states/userstate.dart';

import 'chat.dart';
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

  late String _uesrid;

  // 위도 경도
  double _latitude = 0.0;
  double _longitude = 0.0;
  double _speed = 0.0;

  //친구들의 위치
  List<Marker> _friendsMarker = [];

  //아이콘
  var icon;

  //타이머
  late Timer _timer;

  //화면이 지금 정중인지
  bool _isCenter = true;

  //지금 포커스 중인지
  bool _isFocus = false;

  //경로를 그리기 위한 변수
  List<LatLng> polylineCoordinates = [];
  Map<PolylineId, Polyline> polylines = {};

  //친구들 경로를 그리기 위한 변수
  List<LatLng> friendPolylineCoordinates = [];
  Map<PolylineId, Polyline> friendPolylines = {};

  //친구들 경로 색깔
  Map<String, Color> friendLineColor = {};

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
    _BackgroundLocationService();
    _getCurremtPosition();

    const oneSecond = const Duration(seconds: 5);

    _timer = new Timer.periodic(oneSecond, (Timer t) => setState(() {}));
  }

  _BackgroundLocationService() async {
    await BackgroundLocation.setAndroidNotification(
      title: 'Background service is running',
      message: 'Background location in progress',
      icon: '@mipmap/ic_launcher',
    );
    //await BackgroundLocation.setAndroidConfiguration(1000);
    await BackgroundLocation.startLocationService(distanceFilter: 5);
    BackgroundLocation.getLocationUpdates((location) {
      setState(() {
        _latitude = location.latitude!;
        _longitude = location.longitude!;
        _speed = location.speed!;
      });
      print(_speed);
    });
  }

  _getfriendProfile() async {
    var url = Uri.parse('${Env.URL_PREFIX}/get_friends.php');

    final UserState state = Provider.of<UserState>(context, listen: false);

    var myid = state.id;

    //깔끔하지 못한 코딩 나중에 수정 예정
    _uesrid = state.id;

    var data = {'userid': '$myid'};

    var response = await http.post(url, body: json.encode(data));

    var decoded = json.decode(response.body);

    //여기서 친구들의 위치 정보도 받아와야함
    for (Map freind in decoded) {
      String friendid = freind['friendid'];

      var url = Uri.parse('${Env.URL_PREFIX}/get_user.php');
      var data = {'userid': '$friendid'};
      var response = await http.post(url, body: json.encode(data));
      var message = jsonDecode(response.body);
      print(message);
    }
  }

  //일단 내 정보 부터 갱신
  Future<List<Marker>> _refresh() async {
    //매 5초마다 실행됨 참조 : _timer
    //렉을 유발할 수 있음 --> 계속 마커를 포함한 지도를 그리기 때문
    //렉을 줄일려면 _friends에서 직접 latitude를 건들여주어야함

    //현재 로그인 유저의 정보를 불러옴
    final UserState state = Provider.of<UserState>(context, listen: false);

    print('리프레쉬중...');

    //이제 뛰기 시작한 경우 여기서 처리
    if (state.isRun) {
      polylineCoordinates.add(LatLng(_latitude, _longitude));
      PolylineId plid = PolylineId(state.id);
      Polyline polyline = Polyline(
        polylineId: plid,
        color: Colors.red,
        points: polylineCoordinates,
        width: 3,
      );
      polylines[plid] = polyline;

      //자신의 주소를 DB에 계속 갱신 history
      var myid = state.id;
      _uesrid = state.id;
      var time = DateTime.now().toString();

      var data = {
        'userid': '$myid',
        'time': '$time',
        'latitude': '$_latitude',
        'longitude': '$_longitude'
      };

      var url = Uri.parse('${Env.URL_PREFIX}/set_history.php');

      var response = await http.post(url, body: json.encode(data));
      var message = jsonDecode(response.body);
    }

    Position we = await determinePosition();
    var latitude = we.latitude;
    var longitude = we.longitude;

    var url = Uri.parse('${Env.URL_PREFIX}/update_gps.php');

    //자신의 주소를 DB에 계속 갱신 currentgps
    var myid = state.id;
    _uesrid = state.id;
    var time = DateTime.now().toString();

    var data = {
      'userid': '$myid',
      'time': '$time',
      'latitude': '$latitude',
      'longitude': '$longitude'
    };
    var response = await http.post(url, body: json.encode(data));
    var message = jsonDecode(response.body);

    return _getFriends();
  }

  _getCurremtPosition() async {
    Position we = await determinePosition();
    _latitude = we.latitude;
    _longitude = we.longitude;
    setState(() {});
  }

  //현재 위치로 돌아오는 기능
  Future<void> _focus() async {
    _timer.cancel();
    _isFocus = true;
    _getCurremtPosition();
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        zoom: 15, bearing: 0, target: LatLng(_latitude, _longitude))));
    _isCenter = true;
    const oneSecond = const Duration(seconds: 5);
    _timer = new Timer.periodic(oneSecond, (Timer t) => setState(() {}));
  }

  //뛰기시작
  _run() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Color(0xfff4fef2),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        builder: (BuildContext context) {
          return ModalPage();
        });
  }

  //친구들도 불러오기 위에 내 정보 부터 갱신 다음입니다~!
  Future<List<Marker>> _getFriends() async {
    print('여기가 계속 실행됩니다');
    var url = Uri.parse('${Env.URL_PREFIX}/get_friends.php');

    final UserState state = Provider.of<UserState>(context, listen: false);

    var myid = state.id;

    var data = {'userid': '$myid'};

    var response = await http.post(url, body: json.encode(data));

    var decoded = json.decode(response.body);

    List<Marker> friendsMarker = [];

    //db에서 친구들 불러오기
    for (Map freind in decoded) {
      //서버 통신 부분
      String friendid = freind['friendid'];
      var data = {'userid': '$friendid'};

      //친구들의 위치를 가져온다 and 온라인인지 확인
      double latitude = 0.0;
      double longitude = 0.0;

      var url1 = Uri.parse('${Env.URL_PREFIX}/get_currentgps.php');
      var response1 = await http.post(url1, body: json.encode(data));
      var friendGps = jsonDecode(response1.body);
      if (friendGps == '현재 로그인 중이 아님') {
        continue;
      } else {
        Map tmp = friendGps;
        latitude = double.parse(tmp['latitude']);
        longitude = double.parse(tmp['longitude']);
      }

      //친구들의 정보를 가져온다
      var url2 = Uri.parse('${Env.URL_PREFIX}/get_user.php');
      var response2 = await http.post(url2, body: json.encode(data));
      Map friendData = jsonDecode(response2.body);

      //프로바이더 갱신 부분
      state.setFriends(friendData);

      //친구들이 뛰고 있다면 (history에 친구아이디의 데이터가 있으면) 경로 생성
      url2 = Uri.parse('${Env.URL_PREFIX}/get_history.php');
      response2 = await http.post(url2, body: json.encode(data));
      var historyData = jsonDecode(response2.body);

      List<LatLng> polylineCoordinates = [];
      Map<PolylineId, Polyline> polylines = {};
      if (historyData != '경로없음') {
        for (var history in historyData) {
          polylineCoordinates.add(LatLng(double.parse(history['latitude']),
              double.parse(history['longitude'])));
        }

        PolylineId id = PolylineId(friendid);
        if (!friendLineColor.containsKey(friendid)) {
          friendLineColor[friendid] =
              Color((Random().nextDouble() * 0xFFFFFF).toInt())
                  .withOpacity(1.0);
        }
        Polyline polyline = Polyline(
          polylineId: id,
          color: friendLineColor[friendid]!,
          points: polylineCoordinates,
          width: 4,
        );
        polylines[id] = polyline;
        friendPolylines.addAll(polylines);

        this.polylines.addAll(friendPolylines);
      }

      //커스텀 Marker 만드는 부분
      Uint8List friendicon = await _getFrinedIcon(friendData['image']);
      friendsMarker.add(new Marker(
          markerId: MarkerId(friendData['userid']),
          icon: BitmapDescriptor.fromBytes(friendicon),
          onTap: () => {print(friendData['username'])},
          position: LatLng(latitude, longitude)));
    }

    return friendsMarker;
  }

  //icon을 클래스내에 저장하는 작업
  Future<Uint8List> _getFrinedIcon(String blob) async {
    Uint8List iconUint8List = await getIcon(blob);
    return iconUint8List;
  }

  //서버에 userid 기반으로 image를 다운 받는다
  //image는 blob상태이다
  Future<Uint8List> getIcon(String blob) async {
    //final Uint8List markerIcon = await getBytesFromAsset('assets/images/flutter.png', 100);
    final Uint8List markerIcon = await getBytesFromCanvas(blob, 200, 200);
    return markerIcon;
  }

  //marker 만드는 작업 필요 why? 계속 갱신이 되어야함
  //동반되어야할 작업 계속 친구들 위치 불러와야함 background
  Future<Marker> makeMarker(Uint8List iconUint8List) async {
    return Marker(
        markerId: MarkerId('1'),
        icon: BitmapDescriptor.fromBytes(iconUint8List),
        onTap: () => {print('마커눌림')},
        position: LatLng(36.7749, 126.9327));
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
  Future<Uint8List> getBytesFromCanvas(
      String blob, int width, int height) async {
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
        await _loadImage(blob, width - 30, height - 30),
        width.toDouble(),
        height.toDouble());

    profileImage.paint(canvas, Size(width.toDouble(), height.toDouble()));
    final img = await pictureRecorder
        .endRecording()
        .toImage(width, height + triangleWidth.round());
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  }

  //서버에서 이미지를 받아온다
  Future<ui.Image> _loadImage(String blob, int height, int width) async {
    /*
    //매개변수 String userid를 String blob으로 바꿈
    //서버 통신하는 과정
    var url = Uri.parse('${Env.URL_PREFIX}/get_image.php');
    var data = {'userid': userid};
    var response = await http.post(url, body: json.encode(data));
    //서버에서는 이미지가 blob 형식으로 저장되어 있다
    var blob = response.body;
    */

    //blob형태를 Uint8List로 바꿔줌
    Uint8List img = base64Decode(blob);

    /*
    //기존 코드 첫번째 매개변수 String imageAssetPath 를 userid로 바꿈
    //userid를 통해서 서버에 접속해서 blob 이미지를 다운
    String imageAssetPath = 'assets/london.png';
    final ByteData assetImageByteData = await rootBundle.load(imageAssetPath);
    image.Image? baseSizeImage =
        image.decodeImage(assetImageByteData.buffer.asUint8List());
    */

    //이미지를 resize하는 과정
    image.Image? baseSizeImage = image.decodeImage(img);
    image.Image resizeImage =
        image.copyResize(baseSizeImage!, height: height, width: width);
    ui.Codec codec = await ui.instantiateImageCodec(
        Uint8List.fromList(image.encodePng(resizeImage)));
    ui.FrameInfo frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  }

  @override
  void dispose() {
    _timer.cancel();
    deleteMyGps();
    super.dispose();
  }

  deleteMyGps() async {
    var url = Uri.parse('${Env.URL_PREFIX}/delete_gps.php');

    var myid = _uesrid;

    var data = {'userid': '$myid'};
    var response = await http.post(url, body: json.encode(data));
    var message = jsonDecode(response.body);
    print(message);
  }

  //여기서 부터는 디자인 메소드
  Widget situationText() {
    final UserState state = Provider.of<UserState>(context, listen: false);
    if (state.isRun) {
      return Text('그만하기');
    } else if (_isCenter) {
      return Text('뛰기');
    } else {
      return Text('현재 위치로 이동');
    }
  }

  Widget situationIcon() {
    final UserState state = Provider.of<UserState>(context, listen: false);
    if (state.isRun) {
      return Icon(Icons.stop_circle_outlined);
    } else if (_isCenter) {
      return Icon(Icons.run_circle_outlined);
    } else {
      return Icon(Icons.refresh);
    }
  }

  Future<void> situationRun() async {
    final UserState state = Provider.of<UserState>(context, listen: false);
    if (_isCenter && state.isRun) {
      //여기는 뛰어야함
      state.setIsRun(false);

      //내가 만든 경로 삭제
      polylineCoordinates = [];
      polylines = {};

      //내가 만든 경로 db에서도 삭제
      var url = Uri.parse('${Env.URL_PREFIX}/delete_history.php');

      var myid = state.id;

      var data = {'userid': '$myid'};

      var response = await http.post(url, body: json.encode(data));

      var decoded = json.decode(response.body);

      setState(() {});
      return;
    }

    if (_isCenter) {
      _run();
    } else {
      _focus();
    }
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
                future: _refresh(),
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
                    _friendsMarker = snapshot.data;
                    final UserState state =
                        Provider.of<UserState>(context, listen: false);
                    return Stack(
                      children: [
                        GoogleMap(
                          polylines: Set<Polyline>.of(polylines.values),
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
                          markers: Set.from(_friendsMarker),
                          onCameraMoveStarted: () {
                            if (!_isFocus) {
                              _isCenter = false;
                              setState(() {});
                            }
                            print('화면이동');
                          },
                          onCameraIdle: () {
                            if (_isFocus) {
                              _isFocus = false;
                              setState(() {});
                            }
                            print('쉼');
                            if (_isCenter) {}
                            //_isCenter = false;
                          },
                          scrollGesturesEnabled: state.isRun ? false : true,
                          zoomControlsEnabled: false,
                        ),
                        Align(
                          alignment: Alignment(0, 0.8),
                          child: FloatingActionButton.extended(
                            onPressed: situationRun,
                            label: situationText(),
                            icon: situationIcon(),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: FloatingActionButton(
                              onPressed: () {}, child: Icon(Icons.access_time)),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: FloatingActionButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Chat()),
                                );
                              },
                              child: Icon(Icons.chat)),
                        ),
                      ],
                    );
                  }
                }),
      ),
    );
  }
}
