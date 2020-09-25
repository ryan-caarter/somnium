import 'package:flutter/material.dart';
import 'globals.dart' as globals;

// organises the background gif and centers the correct flamingo

class PlaceholderWidget extends StatelessWidget {
 final Color color;

 PlaceholderWidget(this.color);

 @override
 Widget build(BuildContext context){
   return Scaffold(
     body: Container(
     decoration: BoxDecoration(
       color: globals.Theme.backgroundColor,
       image: DecorationImage(
         image: globals.Theme.whichLeaves,
         fit: BoxFit.none,
         repeat: ImageRepeat.repeat,
         colorFilter: globals.Theme.blur
       ),
     ),
      alignment: Alignment.center,
      child: Image.asset(globals.Theme.whichFlamingo,
        fit: BoxFit.cover,
      ),
   ),
   );
 }
}
     