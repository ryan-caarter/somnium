import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'flutter_map.dart';
import 'timeline.dart';
import 'globals.dart' as globals;
import 'full-lineup.dart';


// this is the home page once the user has selected their festival after first load of the app

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  int _currentIndex = 1;
  final List<Widget> _children = [
    new Scaffold(
      appBar: AppBar(
        centerTitle: true, // centers the title on android
        automaticallyImplyLeading: false, // gets rid of the back button
        backgroundColor: globals.Theme.backgroundColor,
        title: Text("- Lineup -",
            style: TextStyle(
                fontFamily: 'Oregon', color: Colors.black, fontSize: 30)),
      ),
      body: FullLineup(),
    ),
    TimelinePage(title: 'Schedule'),
    MapCustom(),
  ];

  Widget build(BuildContext context) {
    return Scaffold(
        body: _children[_currentIndex],
        bottomNavigationBar: CurvedNavigationBar(
          items: <Widget>[
            Padding(
              padding: EdgeInsets.all(5),
              child: Icon(Icons.assignment, size: 30, color: Colors.black),
            ),
            Padding(
              padding: EdgeInsets.all(5),
              child: Icon(Icons.home, size: 30, color: Colors.black),
            ),
            Padding(
              padding: EdgeInsets.all(5),
              child: Icon(Icons.add_location, size: 30, color: Colors.black),
            ),
          ],
          animationDuration: Duration(milliseconds: 200),
          color: globals.Theme.barColor,
          backgroundColor: globals.Theme.backgroundColor,
          index: _currentIndex,
          height: 70,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ));
  }
}
