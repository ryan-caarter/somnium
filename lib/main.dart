import 'package:flutter/material.dart';
import 'home.dart';
import 'globals.dart' as globals;
import 'SplashScreen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// this load the (messy) splash screen, opens/creates the database and displays
// the correct theme and acts scheduled based on the festival the user has selected

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // important
  int result = await globals.Theme.getChoice();
  print(result);
  if(result == 0) {
    await globals.Theme.createTables();
  }
  globals.flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  await globals.flutterLocalNotificationsPlugin.initialize(globals.initializationSettings); // get notification permission for iOS
  runApp(Myapp());
}

class Myapp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MyApp();
  }
}

class MyApp extends State<Myapp> {
  @override
  Widget build(BuildContext context) {
    var child = globals.Theme.isNorth != null
        ? new Home()
        : new MaterialApp(
            home: new FirstScreen(),
          );
    return MaterialApp(
      home: AdvancedSplashScreen(
        child: child,
        seconds: 2,
        appTitleStyle: TextStyle(
            color: globals.Theme.barColor,
            fontSize: 40.0,
            fontFamily: 'Oregon'),
        colorList: [
          Color(0xff9bcebb),
          Color(0xff9bceff),
          Color(0xff9bcfff),
        ],
        backgroundImage: "assets/Splash.png",
        bgImageOpacity: 0.95,
        appIcon: "assets/2020/logo.jpeg",
      ),
    );
  }
}

class FirstScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: Scaffold(
        body: new Center(
          child: new Column(
            mainAxisSize: MainAxisSize
                .min, // this will take as minimal space as possible (to center)
            children: <Widget>[
              new SizedBox(
                width: double.infinity,
              height: MediaQuery.of(context).size.height / 2, // native screen length / 2
              child: RaisedButton(
                elevation: 5,
                color: Color.fromRGBO(254, 234, 33, 1.0),
                child: Image.asset("assets/2020/mount-start.png"), // button image for the mount
                onPressed: () {
                  globals.Theme.isNorth = true;
                  globals.Theme.setColors();
                  globals.Artist.getArtists();
                  globals.Theme.setLocation();
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => Splash()),
                      (Route<dynamic> route) => false);
                },
              ),
              ),
          new SizedBox(
            width: double.infinity,
            height: MediaQuery.of(context).size.height / 2,
              child: RaisedButton(
                elevation: 5,
                color: Color.fromRGBO(75, 153, 29, 1.0),
                child: Image.asset("assets/2020/nelson-start.png"), // button image for nelson
                onPressed: () {
                  globals.Theme.isNorth = false;
                  globals.Theme.setColors();
                  globals.Artist.getArtists();
                  globals.Theme.setLocation();
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => Splash()),
                      (Route<dynamic> route) => false);
                },
              ),
          ),
            ],
          ),
        ),
      ),
    );
  }
}

class Splash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Home();
  }
}
