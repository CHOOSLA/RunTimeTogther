import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:runtimetogether/main.dart';
import 'package:http/http.dart' as http;

class Chattingroom extends StatefulWidget {
  final String? friendid;
  Chattingroom({Key? key, @required this.friendid}) : super(key: key);
  @override
  _Chattingroom createState() => _Chattingroom();
}

class _Chattingroom extends State<Chattingroom> {
  bool visible = false;
  List<Map<String, dynamic>> a = [];

  final user_idController = TextEditingController();

  Future<List<Map<String, dynamic>>?> chatting() async {
    setState(() {
      visible = true;
      widget.friendid;
    });

    String user_id = user_idController.text;

    var url =
        Uri.parse('http://152.70.93.137/login_user.php'); //////////////////////

    var data = {'user_id': user_id};

    var response = await http.post(url, body: json.encode(data));

    var message = jsonDecode(response.body);
    for (var data in message) {
      a.add(data);
    }
    a = a.reversed.toList();
    return a;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.green[100],
            centerTitle: true,
            toolbarHeight: 70,
            actions: <Widget>[
              IconButton(
                iconSize: 50,
                icon: Icon(Icons.navigate_before),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              SizedBox(width: 70),
              Image.asset('images/logo1.png'),
              SizedBox(width: 150),
            ]),


        body: Stack(
        children: <Widget>[
          Container(
            child: FutureBuilder<List<Map<String, dynamic>>?>(
          future: chatting(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return  ListView.separated(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: a.length,
                  itemBuilder:(context, index) {
                    return sendMessage(snapshot, index, context);
                  }, separatorBuilder: (BuildContext context, int index) { return Divider(thickness: 1);},);
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }
              // 기본적으로 로딩 Spinner를 보여줍니다.
              return CircularProgressIndicator();
          }
        )),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              padding: EdgeInsets.only(left: 10,bottom: 10,top: 10),
              height: 60,
              width: double.infinity,
              color: Colors.white,
              child: Row(
                children: <Widget>[
                  SizedBox(width: 15,),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Send message",
                        hintStyle: TextStyle(color: Colors.black54),
                        border: InputBorder.none
                      ),
                    ),
                  ),
                  SizedBox(width: 15,),
                  FloatingActionButton(
                    onPressed: (){},
                    child: Icon(Icons.send,color: Colors.white,size: 23,),
                    backgroundColor: Colors.green[900],
                    elevation: 0,
                  ),
                ],
                
              ),
            ),
          ),
        ],
      ),
        );
  }

  Widget sendMessage(AsyncSnapshot snapshot, int index, BuildContext context) {
    return new Padding(
      padding: new EdgeInsets.symmetric(vertical: .0, horizontal: 8.0),
      child: InkWell(
        onTap: (){
          
        },
        child: Container(
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              new Padding(
                padding: new EdgeInsets.fromLTRB(10.0, 16.0, 0, 0),
                child: new Text(
                  snapshot.data[index]['friendid'],
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
  
}
