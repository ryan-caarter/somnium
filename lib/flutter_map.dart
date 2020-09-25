import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'globals.dart' as globals;

// displays the map widget page which corresponds to the far-left nav icon

class MapCustom extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false, // gets rid of the back button
        title: Text("- MAP -",
            style: TextStyle(
                fontFamily: 'Oregon', color: Colors.black, fontSize: 30)),
        backgroundColor: globals.Theme.backgroundColor,
      ),
      body: Container(
        child: PhotoView(
          backgroundDecoration: BoxDecoration(
            color: globals.Theme.backgroundColor,
            image: DecorationImage(
                image: globals.Theme.whichLeaves,
                fit: BoxFit.none,
                repeat: ImageRepeat.repeat,
                colorFilter: globals.Theme.blur),
          ),
          imageProvider: AssetImage("assets/2020/map.jpg"),
          minScale: PhotoViewComputedScale.covered,
          maxScale: 8.0,
          enableRotation: false,
          loadingChild: Center(child: null),
        ),
      ),
    );
  }
}
