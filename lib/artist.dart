import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:groovin_widgets/groovin_widgets.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'globals.dart' as globals;


class ArtistCard extends StatefulWidget {
  final String artistName;
  final String artistBio;
  final String artistGenre;
  final String artistSetTime;
  final String artistStage;
  final String imagePath;
  final String youtube;
  final String spotify;
  bool isSet;
  ArtistCard(
      this.artistName,
      this.artistBio,
      this.imagePath,
      this.artistGenre,
      this.artistSetTime,
      this.artistStage,
      this.youtube,
      this.spotify,
      this.isSet);
  @override
  _ArtistCardState createState() => _ArtistCardState(
      this.artistName,
      this.artistBio,
      this.imagePath,
      this.artistGenre,
      this.artistSetTime,
      this.artistStage,
      this.youtube,
      this.spotify,
      this.isSet);

}


/// checks if they have spotify installed (flutter_appavailibility)
/// and if not opens a URL via default launcher (url_launcher)

class _ArtistCardState extends State<ArtistCard> {
  _ArtistCardState(
      this.artistName,
      this.artistBio,
      this.imagePath,
      this.artistGenre,
      this.artistSetTime,
      this.artistStage,
      this.youtube,
      this.spotify,
      this.isSet);

  void openArtist(String youtube, String spotify) async {
        if (await canLaunch(spotify)) {
          await launch(spotify);
        }else if (await canLaunch(youtube)) {
        await launch(youtube);
      }else{
        return;
      }
    }

  String artistName;
  String artistBio;
  String artistGenre;
  String artistSetTime;
  String artistStage;
  String imagePath;
  String youtube;
  String spotify;
  bool isSet;
  Widget build(BuildContext context) {
    return Card(
      elevation: 10.0,
      margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Padding(
        padding:
            EdgeInsets.only(top: 12.5, left: 6.0, right: 6.0, bottom: 12.5),
        child: GroovinExpansionTile(
          leading: CircleAvatar(
            radius: 30.0,
            backgroundImage: AssetImage(this.imagePath),
          ),
          defaultTrailingIconColor: Colors.black,
          subtitle: Padding(
            padding: EdgeInsets.symmetric(vertical: 3.0),
            child: Text(this.artistGenre,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ),
          title: Text(this.artistName,
              style: TextStyle(
                  fontFamily: 'Oregon', color: Colors.black, fontSize: 25)),
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(this.artistBio, style: TextStyle(fontSize: 14)),
            ),
            ButtonBar(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(
                  width: MediaQuery.of(context).size.width/3,
                  //width: 110,
                  //height: 35,
                  child: RaisedButton(
                    elevation: 3.0,
                    child: FittedBox(fit:BoxFit.fitWidth,
                      child: new AutoSizeText(
                      'Listen',
                      style: TextStyle(
                          fontFamily: 'Oregon',
                          color: Colors.black,
                          //fontSize: 15
                      ),
                    )
                    ),
                    onPressed: () {
                      openArtist(this.youtube, this.spotify);
                    },
                    color: globals.Theme.barColor,
                    textColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0)),
                  ),
                ),
                SizedBox(
                  width:MediaQuery.of(context).size.width/3,
                  //width: 150,
                  //height: 35,
                  child: RaisedButton(
                    elevation: 3.0,
                    child: isSet
                        ? new AutoSizeText("Unschedule",
                            style: TextStyle(
                                fontFamily: 'Oregon',
                                color: Colors.black,
                                ))
                        : new AutoSizeText("Schedule",
                            style: TextStyle(
                                fontFamily: 'Oregon',
                                color: Colors.black,
                                //fontSize: 15
                            )),
                    onPressed: () {
                      setState(() {
                        isSet = !isSet;
                        globals.Artist.setArtist(this.artistName, isSet,
                            this.artistSetTime, this.artistStage);
                        globals.Artist.getArtists();
                      });
                    },
                    color: globals.Theme.barColor,
                    textColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
