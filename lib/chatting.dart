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

    var url = Uri.parse('http://220.69.208.121/get_chatting_list.php');

    var data = {'user_id': 'choochoo'};

    var response = await http.post(url, body: json.encode(data));

    var message = jsonDecode(utf8.decode(response.bodyBytes));
    print(message.toString());
    for (var data in message) {
      a.add(data);
    }
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
              SizedBox(
                width: 150,
              ),
            ]),
        body: Stack(children: [
          Container(
              child: FutureBuilder<List<Map<String, dynamic>>?>(
                  future: chatting(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: a.length,
                          padding: EdgeInsets.only(top: 10, bottom: 10),
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return sendMessage(snapshot, index, context);
                          });
                    } else if (snapshot.hasError) {
                      return Text('${snapshot.error}');
                    }
                    // 기본적으로 로딩 Spinner를 보여줍니다.
                    return CircularProgressIndicator();
                  })),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              padding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
              height: 60,
              width: double.infinity,
              color: Colors.white,
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                          hintText: "Write message...",
                          hintStyle: TextStyle(color: Colors.black54),
                          border: InputBorder.none),
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  FloatingActionButton(
                    onPressed: () {},
                    child: Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 18,
                    ),
                    backgroundColor: Colors.green[900],
                    elevation: 0,
                  ),
                ],
              ),
            ),
          ),
        ]));
  }

  Widget sendMessage(AsyncSnapshot snapshot, int index, BuildContext context) {
    return new Padding(
      padding: new EdgeInsets.symmetric(vertical: .0, horizontal: 8.0),
      child: Container(
        child: new Padding(
          padding: new EdgeInsets.fromLTRB(10.0, 16.0, 0, 0),
          child: Align(
            alignment: (snapshot.data[index]['userid'] == "choochoo"
                ? Alignment.topLeft
                : Alignment.topRight),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: (snapshot.data[index]['userid'] == "choochoo"
                    ? Colors.grey.shade300
                    : Colors.green[500]),
              ),
              padding: EdgeInsets.all(16),
              child: Text(
                snapshot.data[index]['context'],
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
