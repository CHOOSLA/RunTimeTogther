import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:runtimetogether/main.dart';
import 'package:http/http.dart' as http;
import 'chatting.dart';

class Chat extends StatefulWidget {
  @override
  _Chat createState() => _Chat();
}

class _Chat extends State<Chat> {
  bool visible = false;
  List<Map<String, dynamic>> a = [];

  final user_idController = TextEditingController();

  Future<List<Map<String, dynamic>>?> chatting() async {
    setState(() {
      visible = true;
    });

    String user_id = user_idController.text;

    var url =
        Uri.parse('http://220.69.208.121/get_friends.php'); //////////////////////

    var data = {'userid': 'choochoo'};

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
              Image.asset('assets/images/logo1.png'),
              SizedBox(width: 150),
            ]),
        body: Container(
            child: FutureBuilder<List<Map<String, dynamic>>?>(
          future: chatting(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return  ListView.separated(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: a.length,
                  itemBuilder: (context, index) {
                    return makePost(snapshot, index, context);
                  }, separatorBuilder: (BuildContext context, int index) { return Divider(thickness: 1);},);
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }
              // 기본적으로 로딩 Spinner를 보여줍니다.
              return CircularProgressIndicator();
          }
        )));
  }

  Widget makePost(AsyncSnapshot snapshot, int index, BuildContext context) {
    return new Padding(
      padding: new EdgeInsets.symmetric(vertical: .0, horizontal: 8.0),
      child: InkWell(
        onTap: (){
          Navigator.push(context,MaterialPageRoute(builder: (context)=>Chattingroom(friendid:snapshot.data[index]['friendid'])));
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
