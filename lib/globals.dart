library somnium.globals;

import 'package:flutter/material.dart';
import 'package:skeleton/data.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'artist.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// this file handles all global variables, database CRUD, notification scheduling, and card generation for the schedule timeline

Database database;
String path;
PageController pageController;

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin; // https://stackoverflow.com/questions/55820299/dont-know-what-file-error-is-referring-to-in-flutter-local-notifications-plugin
var initializationSettingsAndroid = AndroidInitializationSettings('logo'); // location is android/app/src/main/drawable/logo.jpeg
var initializationSettingsIOS = IOSInitializationSettings(
    requestSoundPermission: true,
    requestBadgePermission: true,
    requestAlertPermission: true);
var initializationSettings = InitializationSettings(initializationSettingsAndroid, initializationSettingsIOS);

List<List<String>> notification = List<List<String>>();


class Artist {
  static List<Widget> artistList = new List<Widget>();

  static List<Doodle> doodles = new List<Doodle>();

  static List<Doodle> allDoodles = new List<Doodle>();

  static Future<void> getArtists() async {
    try {
      artistList = new List<Widget>();
      List<Map<String, dynamic>> all;
      database = await openDatabase(path, version: 1);
      await database.transaction((txn) async {
        all = await txn.rawQuery(
            'SELECT * FROM artistList ORDER BY artistName COLLATE NOCASE ASC');
      });
      for (int i = 0; i < all.length; i++) {
        bool isSet;
        switch (all[i]['isSet']) {
          case 0:
            isSet = false;
            break;
          case 1:
            isSet = true;
            break;
        }
        ArtistCard artist = ArtistCard(
            all[i]['artistName'],
            all[i]['artistBio'],
            all[i]['imagePath'],
            all[i]['artistGenre'],
            all[i]['artistSetTime'],
            all[i]['artistStage'],
            all[i]['youtube'],
            all[i]['spotify'],
            isSet);
        artistList.add(artist);
      }
      await getDoodles();
      await getAllDoodles();
    } catch (Exception) {
      print("E1 ");
      print(
          "RyansException: " + Exception.toString());
    }
  }

  static Future<void> getDoodles() async {
    try {
      doodles = new List<Doodle>();
      List<Map<String, dynamic>> all;
      database = await openDatabase(path, version: 1);
      await database.transaction((txn) async {
        all = await txn.rawQuery("SELECT * FROM artistList WHERE isSet = 1");
      });
      if (all.length > 0) {
        for (int i = 0; i < all.length; i++) {
          Doodle doodle = Doodle(
            name: all[i]['artistName'],
            time: all[i]['artistSetTime'],
            content: all[i]['artistBio'],
            stage: all[i]['artistStage'],
            icon: Icon(Icons.music_note, color: Theme.backgroundColor),
            iconBackground: Theme.barColor,
          );
          doodles.add(doodle);
        }
      }
    } catch (Exception) {
      print("E2 ");
      print(
          "RyansException: " + Exception.toString());
    }
  }

  static Future<void> getAllDoodles() async {
    try {
      allDoodles = new List<Doodle>();
      List<Map<String, dynamic>> all;
      database = await openDatabase(path, version: 1);
      await database.transaction((txn) async {
        all = await txn.rawQuery("SELECT * FROM artistList");
      });
      if (all.length > 0) {
        for (int i = 0; i < all.length; i++) {
          Doodle doodle = Doodle(
            name: all[i]['artistName'],
            time: all[i]['artistSetTime'],
            content: all[i]['artistBio'],
            stage: all[i]['artistStage'],
            icon: Icon(Icons.music_note, color: Theme.backgroundColor),
            iconBackground: Theme.barColor.withOpacity(0.75),
          );
          allDoodles.add(doodle);
        }
      }
    } catch (Exception) {
      print("E3 ");
      print(
          "RyansException: " + Exception.toString());
    }
  }

  static Future<void> setArtist(String name, bool isSet, String time, String stage) async { // triggered when an artist is scheduled
    WidgetsFlutterBinding.ensureInitialized(); // important
    var result;
    int id;
    try {
      database = await openDatabase(path, version: 1);
      await database.transaction((txn) async {
        await txn.rawUpdate(
            "UPDATE artistList SET isSet = ? WHERE artistName = ?",
            [isSet, name]);
        result = await txn.rawQuery("SELECT notificationID from artistList WHERE artistName = ?", [name]);
      });
      id = result[0]["notificationID"];
    if(isSet) { // if schedule clicked, schedule the notification
        var scheduledNotificationDateTime = DateTime.now().add(
            Duration(seconds: 5));
        var androidPlatformChannelSpecifics = AndroidNotificationDetails(
            name,
            'your other channel name', 'your other channel description');
        var iOSPlatformChannelSpecifics = IOSNotificationDetails();
        NotificationDetails platformChannelSpecifics = NotificationDetails(
            androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
        await flutterLocalNotificationsPlugin.schedule(id, name + " is playing in 15 minutes!", time+" at "+stage+" 🌞",
            scheduledNotificationDateTime, platformChannelSpecifics,
            androidAllowWhileIdle: true);
      }else{ // cancel the notification
        await flutterLocalNotificationsPlugin.cancel(id);
      }
    } catch (Exception) {
      print("E4 ");
      print("RyansException: " + Exception.toString());
    }
  }
}

class Theme {
  // globals used for theme choice
  static bool isNorth;
  static Color barColor = Color.fromRGBO(75, 153, 29, 1.0);
  static Color backgroundColor = Color.fromRGBO(254, 234, 33, 1.0);
  static AssetImage whichLeaves = AssetImage("assets/images/small-leaf.gif");
  static String whichFlamingo = "assets/images/flamingo.png";
  static ColorFilter blur =
      ColorFilter.mode(Color.fromRGBO(254, 234, 33, 0.7), BlendMode.overlay);
  static String place = "THE MOUNT";

  static Future<int> getChoice() async {
    // open the database
    var databasesPath = await getDatabasesPath();
    path = join(databasesPath, 'my_db.db');
    database = await openDatabase(path, version: 1);
    try {
      List<Map<String, dynamic>> exists = await database.rawQuery(
          "SELECT * FROM sqlite_master WHERE name ='isNorth' and type='table'");
      if (exists.isNotEmpty) {
        List<Map<String, dynamic>> result;
        await database.transaction((txn) async {
          // uncomment the drop queries and comment the select then run, then revert back and run to see the initial buttons
          result = await txn.rawQuery('SELECT * FROM isNorth'); // comment to seen the two buttons at
          // result = await txn.rawQuery('DROP TABLE isNorth'); // uncomment to see two buttons at the start of the app
          // result = await txn.rawQuery('DROP TABLE artistList'); // uncomment to see two buttons at the start of the app
        });
        switch (result[0]['isNorth']) {
          case 0:
            isNorth = false;
            break;
          case 1:
            isNorth = true;
            break;
        }
        Theme.setColors();
        Artist.getArtists();
        return 1;
      }
      return 0;
    } catch (Exception) {
      print("E5 ");
      print(
          "RyansException: " + Exception.toString());
    }
  }
  // called on first download to set place
static Future<void> setLocation() async{
  database = await openDatabase(path, version: 1);
  await database.transaction((txn) async {
    await txn.rawQuery(
        'SELECT * FROM artistList ORDER BY artistName COLLATE NOCASE ASC');
    await txn.rawUpdate("UPDATE isNorth SET isNorth = ? WHERE id = ?", [isNorth, 123]);
  });
}

// change theme function, updates database isNorth variable and resets colors
  static Future<void> change() async {
    WidgetsFlutterBinding.ensureInitialized(); // important
    isNorth = !isNorth;
    setColors();
    for (int i = 0; i < Artist.allDoodles.length; i++) {
      Artist.allDoodles[i].icon =
          Icon(Icons.music_note, color: backgroundColor);
      Artist.allDoodles[i].iconBackground = barColor.withOpacity(0.75);
    }
    for (int i = 0; i < Artist.doodles.length; i++) {
      Artist.doodles[i].icon = Icon(Icons.music_note, color: backgroundColor);
      Artist.doodles[i].iconBackground = barColor.withOpacity(0.75);
    }
    try {
      database = await openDatabase(path, version: 1);
      await database.transaction((txn) async {
        await txn.rawUpdate(
            "UPDATE isNorth SET isNorth = ? WHERE id = ?", [isNorth, 123]);
      });
    } catch (Exception) {
      print("E6 ");
      print("RyansException: " + Exception.toString());
    }
  }

  // set theme based on isNorth change
  static void setColors() {
    try {
      if (isNorth) {
        barColor = Color.fromRGBO(75, 153, 29, 1.0);
        backgroundColor = Color.fromRGBO(254, 234, 33, 1.0);
        whichLeaves = AssetImage("assets/images/small-leaf.gif");
        whichFlamingo = "assets/images/flamingo.png";
        blur = ColorFilter.mode(
            Color.fromRGBO(254, 234, 33, 0.7), BlendMode.overlay);
        place = "THE MOUNT";
      } else {
        // color settings for the South theme
        barColor = Color.fromRGBO(254, 234, 33, 1.0);
        backgroundColor = Color.fromRGBO(75, 153, 29, 1.0);
        whichLeaves = AssetImage("assets/images/small-leaf-green.gif");
        whichFlamingo = "assets/images/nelson_flamingo.png";
        blur = ColorFilter.mode(
            Color.fromRGBO(75, 153, 29, 0.3), BlendMode.colorDodge);
        // the place variable is for the appbar title
        place = "NELSON";
      }
    }catch(Exception){
      print("E7 ");
      print("RyansException: " + Exception.toString());
    }
  }

  // creates the table that holds the theme preference. this is only called once on the first time the app is opened
  static Future<void> createTables() async {
    try {
      await database.transaction((txn) async {
        await txn.rawQuery(
            "CREATE TABLE IF NOT EXISTS isNorth (id INTEGER PRIMARY KEY, isNorth BOOLEAN)");
        await txn.rawQuery(
            "CREATE TABLE IF NOT EXISTS artistList (id INTEGER PRIMARY KEY AUTOINCREMENT, artistName VARCHAR(255), artistBio VARCHAR(255), imagePath VARCHAR(255), artistGenre VARCHAR(255), artistSetTime VARCHAR(255), artistStage VARCHAR(255), youtube VARCHAR(255), spotify VARCHAR(255), isSet BOOLEAN, notificationID INTEGER)");
      });
      await database.transaction((txn) async {
        var batch = txn.batch();
        batch.insert('isNorth', {"id": 123, "isNorth": isNorth});
        var sql = {
          "artistName": "Yelawolf",
          "artistBio":
              "Yelawolf is an underground rapper from a small town in the South who found major-label success in 2011. Born Michael Wayne Atha on December 30, 1979, in Gadsden, Alabama, he made his full-length album debut with the independent release Creekwater (2005).",
          "imagePath": "assets/Headshots/yelawolf.jpg",
          "artistGenre": "Rap",
          "artistSetTime": "1pm",
          "artistStage": "Main Stage",
          "youtube": "https://www.youtube.com/user/YelaWolfMusic",
          "spotify":
              "spotify:artist:68DWke2VjdDmA75aJX5C57",
              //"https://open.spotify.com/artist/68DWke2VjdDmA75aJX5C57?si=amkEQB6RRcCh0cf3fkox1w",
          "isSet":
              false // this is false by default, because a user hasn't scheduled any on first run
          , "notificationID": 0
        };
        batch.insert('artistList', sql);
        sql = {
          "artistName": "Skepta",
          "artistBio":
              "A veteran of the U.K. grime scene, MC, producer, and record-label owner Skepta was influential in the genre's shift from the underground to the pop charts, as well as its creative and commercial resurgence during the mid-2010s.",
          "imagePath": "assets/Headshots/skepta.jpg",
          "artistGenre": "Grime",
          "artistSetTime": "3pm",
          "artistStage": "Second Stage",
          "youtube": "https://www.youtube.com/channel/UCcfVrE3mmeQZ_RN3u5cUECA",
          "spotify":
              "spotify:artist:2p1fiYHYiXz9qi0JJyxBzN",
              //"https://open.spotify.com/artist/2p1fiYHYiXz9qi0JJyxBzN?si=D5zQhkXATyW1y644wepSjQ",
          "isSet": false
          , "notificationID": 1
        };
        batch.insert('artistList', sql);
        sql = {
          "artistName": "Halsey",
          "artistBio":
              "Halsey is the alias of New York-based pop singer Ashley Frangipane. The New Jersey native took her moniker from a New York L train subway stop, and her adopted city plays a large role in both the sound and lyrics of her dark, gritty electro-pop.",
          "imagePath": "assets/Headshots/halsey.jpg",
          "artistGenre": "Pop",
          "artistSetTime": "12pm",
          "artistStage": "Main Stage",
          "youtube": "https://www.youtube.com/user/iamhalsey",
          "spotify":
              "spotify:artist:26VFTg2z8YR0cCuwLzESi2",
              //"https://open.spotify.com/artist/26VFTg2z8YR0cCuwLzESi2?si=uWlrlzj3S2KDGbYWmPUbug",
          "isSet": false
          , "notificationID": 2
        };
        batch.insert('artistList', sql);
        sql = {
          "artistName": "Tyler, The Creator",
          "artistBio":
              "One of the more fascinating artistic evolutions since the late 2000s has been that of Tyler, The Creator. The rapper and producer surfaced as a founding member of Odd Future, an outlandish alternative rap crew that gradually permeated the mainstream as it began a multitude of related projects.",
          "imagePath": "assets/Headshots/tyler.jpg",
          "artistGenre": "Funk/Hiphop",
          "artistSetTime": "1pm",
          "artistStage": "Small Stage",
          "youtube": "https://www.youtube.com/channel/UCsQBsZJltmLzlsJNG7HevBg",
          "spotify":
              "spotify:artist:4V8LLVI7PbaPR0K2TGSxFF",
              //"https://open.spotify.com/artist/4V8LLVI7PbaPR0K2TGSxFF?si=BSuzVtEVREyn-e4KBkEivg",
          "isSet": false
          , "notificationID": 3
        };
        batch.insert('artistList', sql);
        sql = {
          "artistName": "Ocean Alley",
          "artistBio":
              "Hailing from the Northern Beaches of Sydney, the band – Baden Donegal (vocals), Angus Goodwin (guitar), Nic Blom (bass), Lach Galbraith (keys/vocals), Mitch Galbraith (guitar) and Tom O’Brien (drums) have taken their independent brand of sun-soaked psychedelic rock to the world over the last 18 months.",
          "imagePath": "assets/Headshots/oceanalley.jpg",
          "artistGenre": "Psychedelic Surf Rock",
          "artistSetTime": "4pm",
          "artistStage": "Main Stage",
          "youtube": "https://www.youtube.com/channel/UCA-oOXgnhQwqKNrC6CbDiPw",
          "spotify":
              "spotify:artist:18lpwfiys4GtdHWNUu9qQr",
              //"https://open.spotify.com/artist/18lpwfiys4GtdHWNUu9qQr?si=L1wvS33mSSe0lwaqC_SkNQ",
          "isSet": false
          , "notificationID": 4
        };
        batch.insert('artistList', sql);
        sql = {
          "artistName": "Shoreline Mafia",
          "artistBio":
              "California hip-hop collective Shoreline Mafia deliver hedonistic trap rap focused on partying, sex, and drugs. After a slow rise in the late 2010s, they signed with Atlantic for their major-label debut OTXmas in 2018.",
          "imagePath": "assets/Headshots/shorelinemafia.jpg",
          "artistGenre": "Rap/HipHop",
          "artistSetTime": "8pm",
          "artistStage": "Second Stage",
          "youtube": "https://www.youtube.com/channel/UCTGvupQMw-IokKJ6U9zFgjQ",
          "spotify":
              "spotify:artist:4tYSBptyGeVyZsk8JC4JHZ",
              //"https://open.spotify.com/artist/4tYSBptyGeVyZsk8JC4JHZ?si=WMlG840ORLyOmKtT2EY8YQ",
          "isSet": false
          , "notificationID": 5
        };
        batch.insert('artistList', sql);
        sql = {
          "artistName": "Mako Road",
          "artistBio":
              "The names Mako Road, a four-piece indie rock band from New Zealand made up of Rhian (guitar and vocals), CJ (bass), Connor (guitar) and Robbie (drums). Following a huge AUS/NZ summer tour the boys are parked up in Wellington writing new tunes and playing gigs all over the show. ",
          "imagePath": "assets/Headshots/makoroad.jpg",
          "artistGenre": "Orchestra Dubstep Hybrid Rock",
          "artistSetTime": "6pm",
          "artistStage": "Small Stage",
          "youtube": "https://www.youtube.com/channel/UCLDU2KJtPUAv4gCEUZjiHZA",
          "spotify":
              "spotify:artist:5dbCgsqzVweFpd1yYHv3Bz",
              //"https://open.spotify.com/artist/5dbCgsqzVweFpd1yYHv3Bz?si=217K-Da8Sh62FX87-CcuFw",
          "isSet": false
          , "notificationID": 6
        };
        batch.insert('artistList', sql);
        sql = {
          "artistName": "Friction",
          "artistBio":
              "Multi award-winning Friction is one of the most revered and respected electronic music artists in the world today.",
          "imagePath": "assets/Headshots/friction.jpg",
          "artistGenre": "Drum and Bass",
          "artistSetTime": "3pm",
          "artistStage": "Second Stage",
          "youtube": "https://www.youtube.com/channel/UCv_-mMayj42ubcTTnY5cu_A",
          "spotify":
              "spotify:artist:5xdizdgbQQvGAgAolGhpXr",
              //"https://open.spotify.com/artist/5xdizdgbQQvGAgAolGhpXr?si=kOvBnqVrTPCoQ6h2U_A-Vw",
          "isSet": false
          , "notificationID": 7

        };
        batch.insert('artistList', sql);
        sql = {
          "artistName": "Sons of Zion",
          "artistBio":
              "With their fusion of Reggae, Rock, Dub and Roots, Sons of Zion are a talented 6 piece reggae band which comprises of 6 young Rangitahi from various locations in Aotearoa (New Zealand).",
          "imagePath": "assets/Headshots/sonsofzion.jpg",
          "artistGenre": "Reggae/Rock",
          "artistSetTime": "12pm",
          "artistStage": "Second Stage",
          "youtube": "https://www.youtube.com/channel/UCPaX1exyF4z2IJC2LwYtLjg",
          "spotify":
              "spotify:artist:0PK0Dx3s9et0Uf4XbdFpiW",
              //"https://open.spotify.com/artist/0PK0Dx3s9et0Uf4XbdFpiW?si=p0tQXSU7T4Wmg2j3HgSosQ",
          "isSet": false
          , "notificationID": 8
        };
        batch.insert('artistList', sql);
        sql = {
          "artistName": "Netsky",
          "artistBio":
              "One of Belgium's top Drum and Bass producers, Netsky (Boris Daenen) made his name producing deep, smoothly rolling tracks in the liquid funk style before achieving chart success in Europe and the U.K. with his increasingly pop-minded singles and full-lengths.",
          "imagePath": "assets/Headshots/netsky.jpg",
          "artistGenre": "EDM/Drum and Bass",
          "artistSetTime": "10am",
          "artistStage": "Main Stage",
          "youtube": "https://www.youtube.com/user/NetskymusicTV",
          "spotify":
              "spotify:artist:5TgQ66WuWkoQ2xYxaSTnVP",
              //"https://open.spotify.com/artist/5TgQ66WuWkoQ2xYxaSTnVP?si=QXf0QCgBRAywu8BcEXv1Hg",
          "isSet": false
          , "notificationID": 9
        };
        batch.insert('artistList', sql);
        sql = {
          "artistName": "Gunna",
          "artistBio":
              "When the history books open up, “Drip” will forever be associated with the meteoric and platinum rise of Gunna. Dubbed “The King of Drip” and pegged “to take over the rap world” by Interview, Gunna generated over one billion cumulative streams and achieved one platinum and two gold certifications within a year.",
          "imagePath": "assets/Headshots/gunna.jpg",
          "artistGenre": "Rap/Hip Hop",
          "artistSetTime": "2pm",
          "artistStage": "Main Stage",
          "youtube": "https://www.youtube.com/channel/UCAkIMkEaa9sZmjcy7mfd5lQ",
          "spotify":
              "spotify:artist:2hlmm7s2ICUX0LVIhVFlZQ",
              //"https://open.spotify.com/artist/2hlmm7s2ICUX0LVIhVFlZQ?si=idJytM9oQwqiW9UUSTaLew",
          "isSet": false
          , "notificationID": 10
        };
        batch.insert('artistList', sql);
        sql = {
          "artistName": "Dimension",
          "artistBio":
              "Dimension, real name Robert Etheridge, is an electronic music producer and DJ from London, United Kingdom. A man of few words who tends to let his music do the talking, Dimension is receiving mainstream success without deliberately releasing crossover music – striking the perfect balance between club and radio.",
          "imagePath": "assets/Headshots/dimension.jpeg",
          "artistGenre": "EDM/House",
          "artistSetTime": "4pm",
          "artistStage": "Small Stage",
          "youtube": "https://www.youtube.com/channel/UCz7HeKNi11EdK6_B0bCUK_Q",
          "spotify": "spotify:artist:1QMgre3BHX161ZHtWMUu6S",
          "isSet": false
          , "notificationID": 11
        };
        batch.insert('artistList', sql);
        sql = {
          "artistName": "Flux Pavilion",
          "artistBio":
              "Flux Pavilion’s polymath-like ability to involve himself in all aspects of music cannot be understated. Known as Joshua Steele to friends and family, Flux is a singer-songwriter, record producer and label owner.",
          "imagePath": "assets/Headshots/fluxpavilion.jpg",
          "artistGenre": "EDM/Dubstep",
          "artistSetTime": "7pm",
          "artistStage": "Main Stage",
          "youtube": "https://www.youtube.com/user/FluxPavilion",
          "spotify":
              "spotify:artist:7HkdQ0gt53LP4zmHsL0nap",
              //"https://open.spotify.com/artist/7muzHifhMdnfN1xncRLOqk?si=6QjW5iNXT56yyr_zsh7fZA",
          "isSet": false
          , "notificationID": 12
        };
        batch.insert('artistList', sql);
        sql = {
          "artistName": "Sub Focus",
          "artistBio":
              "Over the course of a 16-year career, Nick Douwma aka Sub Focus has risen through the ranks of underground jungle to become a global dance music superstar. First building a reputation around air-punching, dancefloor-dismantling drum & bass, he now draws from all corners of the electronic landscape - epitomising the ‘anything goes’ mantra of today's scene.",
          "imagePath": "assets/Headshots/subfocus.jpg",
          "artistGenre": "Drum and Bass",
          "artistSetTime": "1pm",
          "artistStage": "Main Stage",
          "youtube": "https://www.youtube.com/channel/UCWkMMrVPVVNxuJFHv4ApiDg",
          "spotify":
              "spotify:artist:0QaSiI5TLA4N7mcsdxShDO",
              //"https://open.spotify.com/artist/0QaSiI5TLA4N7mcsdxShDO?si=o60u5M0MQfu0siB-ahQA5A",
          "isSet": false
          , "notificationID": 13
        };
        batch.insert('artistList', sql);
        sql = {
          "artistName": "Holy Goof",
          "artistBio":
              "Holy Goof has emerged as one of the UK’s most promising acts over the last 24 months and is rising rapidly. His sound — a fluid, bass-house hybrid referencing everything from bassline to grime — is squarely tilted at the club.",
          "imagePath": "assets/Headshots/holygoof.jpg",
          "artistGenre": "Bass/Future House",
          "artistSetTime": "12am",
          "artistStage": "Second Stage",
          "youtube": "https://www.youtube.com/channel/UC-Dr9sNae7U6_pLs5VC7cog",
          "spotify":
              "spotify:artist:2gNmFyBanPG1slh2pHnCtU",
              //"https://open.spotify.com/artist/2gNmFyBanPG1slh2pHnCtU?si=1kbzNAcIQkSMKZVt4nA0yA",
          "isSet": false
          , "notificationID": 14
        };
        batch.insert('artistList', sql);
        sql = {
          "artistName": "Mitch James",
          "artistBio":
              "Following in the vein of influences Jack Johnson and Ben Harper, singer/songwriter Mitch James' acoustic pop focuses on personal lyrics, agile guitar playing, and a warm delivery. He made his self-titled debut via Sony in 2018.",
          "imagePath": "assets/Headshots/mitchjames.jpg",
          "artistGenre": "Pop",
          "artistSetTime": "2pm",
          "artistStage": "Second Stage",
          "youtube": "https://www.youtube.com/channel/UCEoAsX261pEOb0PGEKi4gVw",
          "spotify":
              "spotify:artist:65oocmSeB6z75kHwrZo1le",
              // "https://open.spotify.com/artist/65oocmSeB6z75kHwrZo1le?si=LscEdDUCRemzyRwUEkTJJw",
          "isSet": false
          , "notificationID": 15
        };
        batch.insert('artistList', sql);
        sql = {
          "artistName": "Ella Mai",
          "artistBio":
              "An R&B singer and songwriter with a casually commanding voice, Ella Mai wasn't exactly an unknown artist before DJ Mustard signed her to his 10 Summers label, but the U.K. native hit the mainstream in 2018 with breakthrough single 'Boo'd Up,' a sparkling slow jam that increased in popularity throughout the year. ",
          "imagePath": "assets/Headshots/ellamai.jpg",
          "artistGenre": "R&B/Hip Hop",
          "artistSetTime": "3pm",
          "artistStage": "Main Stage",
          "youtube": "https://www.youtube.com/channel/UCy1qd93CcOTvOrQ-QM8_pyQ",
          "spotify":
            "spotify:artist:7HkdQ0gt53LP4zmHsL0nap",
              //"https://open.spotify.com/artist/7HkdQ0gt53LP4zmHsL0nap?si=pYe_IV8MS0G-fDkYes8WNw",
          "isSet": false
          , "notificationID": 16
        };
        batch.insert('artistList', sql);

        await batch.commit(noResult: true);
      });
    } catch (Exception) {
      print("E8 ");
      print("RyansException: " + Exception.toString());
    }
  }
}



