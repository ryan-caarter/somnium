import 'package:flutter/material.dart';
import 'package:timeline_list/timeline.dart';
import 'package:timeline_list/timeline_model.dart';
import 'data.dart';
import 'globals.dart' as globals;


// handles the full lineup on the leftmost navigation icon

class FullLineup extends StatefulWidget {
  FullLineup({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _FullLineupState createState() => _FullLineupState();
}

class _FullLineupState extends State<FullLineup> {
  final PageController pageController =
      PageController(initialPage: 1, keepPage: true);
  int pageIx = 1;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: globals.Theme.backgroundColor,
        image: DecorationImage(
            image: globals.Theme.whichLeaves,
            fit: BoxFit.none,
            repeat: ImageRepeat.repeat,
            colorFilter: globals.Theme.blur),
      ),
      alignment: Alignment.center,
      padding: EdgeInsets.all(5.0),
      child: timelineModel(TimelinePosition.Center),
    );
  }

  timelineModel(TimelinePosition position) => Timeline.builder(
        itemBuilder: centerTimelineBuilder,
        itemCount: globals.Artist.allDoodles.length + 1,
        physics: BouncingScrollPhysics(),
        position: TimelinePosition.Left,
      );

  TimelineModel centerTimelineBuilder(BuildContext context, int i) {
    Doodle doodle = i < globals.Artist.allDoodles.length
        ? globals.Artist.allDoodles[i]
        : globals.Artist.allDoodles[i - 1];
    return TimelineModel(
      SizedBox(
        width: MediaQuery.of(context).size.width - 40,
        height: i != globals.Artist.allDoodles.length ? null : 100,
        child: i != globals.Artist.allDoodles.length // if not end of timeline, show card
            ? Card(
                color: Colors.white,
                margin: EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0)),
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
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
                      Text(
                        doodle.stage + ": " + doodle.time,
                        style: TextStyle(
                            fontFamily: 'Oregon',
                            color: Colors.black,
                            fontSize: 20),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),
              )
            : SizedBox( // else show flamingo
                width: MediaQuery.of(context).size.width - 40,
                height: 100,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 15.0),
                  child: Image.asset(globals.Theme.whichFlamingo),
                ),
              ),
      ),
      position: TimelineItemPosition.left,
      isFirst: i == 0,
      isLast: i == globals.Artist.allDoodles.length,
      iconBackground: i < globals.Artist.allDoodles.length
          ? doodle.iconBackground
          : Colors.transparent,
      icon: i < globals.Artist.allDoodles.length ? doodle.icon : null, // if end of timeline, don't show the music icon
    );
  }
}
