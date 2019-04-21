import 'package:flutter/material.dart';
import 'package:sensors/sensors.dart';
import 'dart:async';
import 'package:firebase_database/firebase_database.dart';

void main() => runApp(GestureBot());

class GestureBot extends StatefulWidget {
  @override
  _GestureBotState createState() => _GestureBotState();
}

class _GestureBotState extends State<GestureBot> {
  List<double> _accelValues;
  String action = "stop";
  DatabaseReference dbRef;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GestureBot',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "Poppins",
        primaryColor: Colors.teal,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            'GestureBot',
            style: titleStyle,
          ),
          centerTitle: true,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(
              child: Text(
                action.toUpperCase(),
                style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void takeAction() {
    if (_accelValues[0] > 7.5) {
      setState(() {
        action = "left";
      });
      dbRef.set({"action": "left"});
    } else if (_accelValues[0] < -5.5) {
      setState(() {
        action = "right";
      });
      dbRef.set({"action": "right"});
    } else if (_accelValues[1] > 7) {
      setState(() {
        action = "backward";
      });
      dbRef.set({"action": "backward"});
    } else if (_accelValues[1] < -4.5) {
      setState(() {
        action = "forward";
      });
      dbRef.set({"action": "forward"});
    } else {
      setState(() {
        action = "stop";
      });
      dbRef.set({"action": "stop"});
    }
  }

  @override
  void initState() {
    super.initState();
    final FirebaseDatabase database = FirebaseDatabase.instance;
    dbRef = database.reference().child('robot');
    accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        _accelValues = <double>[event.x, event.y, event.z];
      });
    });
    Timer.periodic(const Duration(milliseconds: 500), (_) {
      accelerometerEvents.listen((AccelerometerEvent event) {
        setState(() {
          _accelValues = <double>[event.x, event.y, event.z];
        });
      });
      takeAction();
    });
  }
}

final titleStyle = new TextStyle(
  fontFamily: "Poppins",
  fontWeight: FontWeight.w700,
);
