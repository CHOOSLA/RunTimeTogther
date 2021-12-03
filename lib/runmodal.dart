import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:runtimetogether/states/userstate.dart';

class ModalPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 40),
          width: double.infinity,
          child: Column(
            children: [
              //실선
              Container(
                width: 150,
                child: Divider(color: Colors.black54, thickness: 2.5),
              ),
              const Padding(padding: EdgeInsets.only(top: 45)),
              TextButton(
                onPressed: () {
                  final UserState state =
                      Provider.of<UserState>(context, listen: false);
                  state.setIsRun(true);
                  Navigator.pop(context);
                },
                child: Text("뛰기시작"),
                style: TextButton.styleFrom(
                  primary: Colors.white,
                  backgroundColor: Color(0xff45983F),
                  elevation: 1,
                  textStyle:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 45),
                  padding: EdgeInsets.all(16.0),
                  minimumSize: Size(200, 200),
                  side: BorderSide(color: Colors.black45, width: 2.0),
                  shape: CircleBorder(),
                ),
              ),
              const Padding(padding: EdgeInsets.only(bottom: 45)),
            ],
          ),
        )
      ],
    );
  }
}
