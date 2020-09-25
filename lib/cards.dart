import 'package:flutter/material.dart';
import 'globals.dart' as globals;

class CardsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: globals.Theme.backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          color: globals.Theme.backgroundColor,
          image: DecorationImage(
            image: globals.Theme.whichLeaves,
            fit: BoxFit.none,
            repeat: ImageRepeat.repeat,
            colorFilter: globals.Theme.blur,
          ),
        ),
        alignment: Alignment.center,
        child: ListView(
          physics: BouncingScrollPhysics(),
          padding:
              EdgeInsets.only(top: 12.5, left: 6.0, right: 6.0, bottom: 12.5),
          children: globals.Artist.artistList,
        ),
      ),
    );
  }
}
