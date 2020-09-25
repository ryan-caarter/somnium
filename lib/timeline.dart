import 'package:flutter/material.dart';
import 'package:skeleton/cards.dart';
import 'package:timeline_list/timeline.dart';
import 'package:timeline_list/timeline_model.dart';
import 'data.dart';
import 'globals.dart' as globals;
import 'package:rflutter_alert/rflutter_alert.dart';
import 'home.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:auto_size_text/auto_size_text.dart';

// maintains the homepage timeline of scheduled acts depending on if the user has scheduled any

GlobalKey bottomNavigationKey;

class TimelinePage extends StatefulWidget {
  TimelinePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _TimelinePageState createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  PageController pageController = PageController(
    initialPage: 1,
    keepPage: true,
  );

  @override
  void initState() {
    super.initState();
    pageController = PageController(
      initialPage: 1,
      keepPage: true,
    );
  }

  int pageIx = 1;

  @override
  Widget build(BuildContext context) {
    String place = globals.Theme.isNorth ? "THE MOUNT" : "NELSON";
    String notPlace = globals.Theme.isNorth ? "NELSON" : "THE MOUNT";
    // set up the AlertDialog
    List<Widget> pages;

    if (globals.Artist.doodles.length > 0) {
      pages = [
        CardsWidget(), //
        Scaffold(
            body: Container(
          decoration: BoxDecoration(
            color: globals.Theme.backgroundColor,
            image: DecorationImage(
                image: globals.Theme.whichLeaves,
                fit: BoxFit.none,
                repeat: ImageRepeat.repeat,
                colorFilter: globals.Theme.blur),
          ),
          child: timelineModel(TimelinePosition.Left),
        )),
      ];
    } else {
      pages = [
        CardsWidget(),
        Scaffold(
          body: Container(
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              color: globals.Theme.backgroundColor,
              image: DecorationImage(
                  image: globals.Theme.whichLeaves,
                  fit: BoxFit.none,
                  repeat: ImageRepeat.repeat,
                  colorFilter: globals.Theme.blur),
            ),
            alignment: Alignment.center,
            padding: EdgeInsets.all(30.0),
            child: new Column(
              children: <Widget>[
                new AutoSizeText(
                  "Scheduled artists will appear here.\n\n"
                  "We'll notify you 15 minutes before they're on!\n",
                  style: TextStyle(
                      fontFamily: 'Oregon', color: Colors.black, fontSize: 25),
                  textAlign: TextAlign.center,
                ),
                Image.asset(
                  globals.Theme.whichFlamingo,
                  fit: BoxFit.scaleDown,
                  width: MediaQuery.of(context).size.height / 10,
                ),
              ],
            ),
          ),
        )
      ];
    }

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          // centers the title on android
          automaticallyImplyLeading: false,
          // gets rid of the back button
          backgroundColor: globals.Theme.backgroundColor,
          title: Text("- $place -",
              style: TextStyle(
                  fontFamily: 'Oregon', color: Colors.black, fontSize: 30)),
          leading: IconButton(
              icon: Icon(Icons.shopping_cart, color: Colors.black),
              onPressed: () {
                Alert(
                  context: context,
                  type: AlertType.none,
                  style: AlertStyle(
                    titleStyle: TextStyle(
                        fontFamily: 'Oregon',
                        color: Colors.black,
                        fontSize: 25),
                    descStyle: TextStyle(
                        fontFamily: 'Oregon',
                        color: Colors.black,
                        fontSize: 15),
                    backgroundColor: globals.Theme.barColor,
                    isCloseButton: false,
                    isOverlayTapDismiss: true,
                    animationType: AnimationType.fromTop,
                    buttonAreaPadding: EdgeInsets.all(25.0),
                  ),
                  title: "Buy Tickets",
                  desc: "This will take you to buy tickets.",
                  buttons: [
                    DialogButton(
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                            fontFamily: 'Oregon',
                            color: Colors.black,
                            fontSize: 20),
                      ),
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop();
                      },
                      width: 120,
                      color: globals.Theme.backgroundColor,
                    ),
                    DialogButton(
                      child: Text(
                        "Continue",
                        style: TextStyle(
                            fontFamily: 'Oregon',
                            color: Colors.black,
                            fontSize: 20),
                      ),
                      onPressed: () async {
                        if (await canLaunch("https://www.baydreams.co.nz/")) {
                          await launch("https://www.baydreams.co.nz/");
                        }
                        Navigator.of(context, rootNavigator: true).pop();
                      },
                      width: 120,
                      color: globals.Theme.backgroundColor,
                    ),
                  ],
                ).show();
              }),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.shuffle,
                color: Colors.black,
              ),
              onPressed: () {
                Alert(
                  context: context,
                  type: AlertType.none,
                  style: AlertStyle(
                    titleStyle: TextStyle(
                        fontFamily: 'Oregon',
                        color: Colors.black,
                        fontSize: 25),
                    descStyle: TextStyle(
                        fontFamily: 'Oregon',
                        color: Colors.black,
                        fontSize: 15),
                    backgroundColor: globals.Theme.barColor,
                    isCloseButton: false,
                    isOverlayTapDismiss: true,
                    animationType: AnimationType.fromTop,
                    buttonAreaPadding: EdgeInsets.all(25.0),
                  ),
                  title: "Confirm festival swap",
                  desc: "Change location to " + notPlace + "?",
                  buttons: [
                    DialogButton(
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                            fontFamily: 'Oregon',
                            color: Colors.black,
                            fontSize: 20),
                      ),
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop();
                      },
                      width: 120,
                      color: globals.Theme.backgroundColor,
                    ),
                    DialogButton(
                      child: Text(
                        "Continue",
                        style: TextStyle(
                            fontFamily: 'Oregon',
                            color: Colors.black,
                            fontSize: 20),
                      ),
                      onPressed: () {
                        globals.Theme.change();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Home(), // swap theme button
                            ),
                        );
                        Navigator.of(context, rootNavigator: true).pop();
                      },
                      width: 120,
                      color: globals.Theme.backgroundColor,
                    ),
                  ],
                ).show();
              },
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
            currentIndex: pageIx,
            selectedItemColor: globals.Theme.barColor,
            selectedFontSize: 12,
            unselectedItemColor: Colors.black,
            backgroundColor: globals.Theme.backgroundColor,
            onTap: (i) => pageController.animateToPage(i,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.play_arrow),
                title: Text("Artists"),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bookmark),
                title: Text("My Schedule"),
              ),
            ]),
        backgroundColor: globals.Theme.backgroundColor,
        body: Container(
            decoration: BoxDecoration(
                color: globals.Theme.backgroundColor,
                image: DecorationImage(
                    image: globals.Theme.whichLeaves,
                    fit: BoxFit.none,
                    repeat: ImageRepeat.repeat,
                    colorFilter: globals.Theme.blur)),
            child: PageView(
              onPageChanged: (i) => setState(() => pageIx = i),
              controller: pageController,
              children: pages,
            )));
  }

  timelineModel(TimelinePosition position) {
    return Timeline.builder(
      itemBuilder: centerTimelineBuilder,
      itemCount: globals.Artist.doodles.length + 1, // +1 for the flamingo
      physics: BouncingScrollPhysics(),
      position: position,
    );
  }

  TimelineModel centerTimelineBuilder(BuildContext context, int i) {
    // if we're on the last item of their schedule, add a flamingo at the end
    if (i >= globals.Artist.doodles.length) {
      var child = globals.Artist.doodles.length == 0
          ? null
          : Image.asset(
              globals.Theme.whichFlamingo,
            );
      return TimelineModel(
        SizedBox(
            width: MediaQuery.of(context).size.width - 40,
            height: 100,
            child:
                Padding(padding: EdgeInsets.only(bottom: 15.0), child: child)),
        iconBackground: Colors.transparent,
        icon: null,
      );
    } else {
      Doodle doodle = globals.Artist.doodles[i];

      return TimelineModel(
        SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Card(
              color: globals.Theme.barColor,
              margin: EdgeInsets.symmetric(vertical: 16.0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)),
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Column(
                  children: <Widget>[
                    Text(
                      doodle.name,
                      style: TextStyle(
                          fontFamily: 'Oregon',
                          color: Colors.black,
                          fontSize: 30),
                      textAlign: TextAlign.center,
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          SizedBox(
                              //width: MediaQuery.of(context).size.width/10,
                              child: AutoSizeText(
                            doodle.stage + ": " + doodle.time,
                            style: TextStyle(
                                fontFamily: 'Oregon',
                                color: Colors.black,
                                fontSize: 20),
                            textAlign: TextAlign.left,
                          )),
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 8,
                            child: FlatButton(
                              child: Align(
                                child: Icon(
                                  Icons.delete,
                                  color: globals.Theme.backgroundColor,
                                  size: 30,
                                ),
                                alignment: Alignment.center,
                              ),
                              color: Colors.transparent,
                              onPressed: () async {
                                await globals.Artist.setArtist(doodle.name,
                                    false, doodle.time, doodle.stage);
                                await globals.Artist.getDoodles();
                                await globals.Artist.getArtists();
                                setState(() {});
                              },
                            ),
                          ),
                        ]),
                  ],
                ),
              ),
            )),
        position: TimelineItemPosition.left,
        isFirst: i == 0,
        isLast: i == globals.Artist.doodles.length,
        iconBackground: i < globals.Artist.doodles.length ? doodle.iconBackground : Colors.transparent,
        icon: i < globals.Artist.doodles.length ? doodle.icon : null,
      );
    }
  }
}
