import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_beep/flutter_beep.dart';
import 'package:sailing_timer/Settings.dart';
import 'package:sailing_timer/review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:theme_provider/theme_provider.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'extra.dart';

// Toggle this to cause an async error to be thrown during initialization
// and to test that runZonedGuarded() catches the error
const _kShouldTestAsyncErrorOnInit = false;

// Toggle this for testing Crashlytics in your app locally.
const _kTestingCrashlytics = false;

Future<void> main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

    runApp(MyApp());
  }, (error, stackTrace) {
    FirebaseCrashlytics.instance.recordError(error, stackTrace);
  });
}

class MyApp extends StatelessWidget {
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    return ThemeProvider(
      themes: [
        AppTheme(
          id: "dark", // Id(or name) of the theme(Has to be unique)
          description: "Dark Theme", // Description of theme
          data: ThemeData(
              // Real theme data
              brightness: Brightness.dark,
              scaffoldBackgroundColor: Color.fromRGBO(46, 48, 48, 1),
              backgroundColor: Color.fromRGBO(46, 48, 48, 1),
              primaryColor: Colors.lightBlueAccent,
              primaryColorLight: Colors.white,
              accentColor: Color.fromRGBO(46, 48, 48, 1),
              iconTheme: IconThemeData(color: Colors.white),
              primaryColorDark: Colors.lightBlueAccent),
        ),
        AppTheme(
          id: "light", // Id(or name) of the theme(Has to be unique)
          description: "Light Theme", // Description of theme
          data: ThemeData(
            // Real theme data
            primaryColor: Colors.lightBlueAccent,
            primaryColorLight: Colors.lightBlueAccent,
            accentColor: Colors.white,
            textTheme: TextTheme(bodyText1: TextStyle(color: Colors.pink)),

            cupertinoOverrideTheme: NoDefaultCupertinoThemeData(
                textTheme: CupertinoTextThemeData(primaryColor: Colors.pink)),
            iconTheme: IconThemeData(color: Colors.lightBlueAccent),
          ),
        ),
        AppTheme(
          id: "red", // Id(or name) of the theme(Has to be unique)
          description: "Dark Theme", // Description of theme
          data: ThemeData(
              // Real theme data
              brightness: Brightness.dark,
              scaffoldBackgroundColor: Color.fromRGBO(46, 48, 48, 1),
              backgroundColor: Color.fromRGBO(46, 48, 48, 1),
              primaryColor: Colors.redAccent,
              primaryColorLight: Colors.white,
              accentColor: Colors.redAccent,
              iconTheme: IconThemeData(color: Colors.white),
              primaryColorDark: Colors.redAccent),
        ),
        AppTheme(
          id: "green", // Id(or name) of the theme(Has to be unique)
          description: "Dark Theme", // Description of theme
          data: ThemeData(
              // Real theme data
              brightness: Brightness.dark,
              scaffoldBackgroundColor: Color.fromRGBO(46, 48, 48, 1),
              backgroundColor: Color.fromRGBO(46, 48, 48, 1),
              primaryColor: Colors.greenAccent,
              primaryColorLight: Colors.white,
              accentColor: Colors.greenAccent,
              iconTheme: IconThemeData(color: Colors.white),
              primaryColorDark: Colors.greenAccent),
        ),
        AppTheme(
          id: "pink", // Id(or name) of the theme(Has to be unique)
          description: "Dark Theme", // Description of theme
          data: ThemeData(
              // Real theme data
              brightness: Brightness.light,
              // scaffoldBackgroundColor: Color.fromRGBO(46, 48, 48, 1),
              //backgroundColor: Color.fromRGBO(46, 48, 48, 1),
              primaryColor: Colors.pinkAccent,
              primaryColorLight: Colors.pinkAccent,
              accentColor: Colors.pinkAccent,
              iconTheme: IconThemeData(color: Colors.pinkAccent),
              primaryColorDark: Colors.pinkAccent),
        ),
        AppTheme(
          id: "orange", // Id(or name) of the theme(Has to be unique)
          description: "Dark Theme", // Description of theme
          data: ThemeData(
              // Real theme data
              brightness: Brightness.dark,
              scaffoldBackgroundColor: Color.fromRGBO(46, 48, 48, 1),
              backgroundColor: Color.fromRGBO(46, 48, 48, 1),
              primaryColor: Colors.orangeAccent,
              primaryColorLight: Colors.white,
              accentColor: Colors.orangeAccent,
              iconTheme: IconThemeData(color: Colors.white),
              primaryColorDark: Colors.orangeAccent),
        ),
        AppTheme(
          id: "purple", // Id(or name) of the theme(Has to be unique)
          description: "Dark Theme", // Description of theme
          data: ThemeData(
              // Real theme data
              brightness: Brightness.dark,
              scaffoldBackgroundColor: Color.fromRGBO(46, 48, 48, 1),
              backgroundColor: Color.fromRGBO(46, 48, 48, 1),
              primaryColor: Colors.purpleAccent,
              primaryColorLight: Colors.white,
              accentColor: Colors.purpleAccent,
              iconTheme: IconThemeData(color: Colors.white),
              primaryColorDark: Colors.purpleAccent),
        ),
      ],
      saveThemesOnChange: true,
      onInitCallback: (controller, previouslySavedThemeFuture) async {
        // Do some other task here if you need to
        String? savedTheme = await previouslySavedThemeFuture;
        if (savedTheme != null) {
          controller.setTheme(savedTheme);
        }
      },
      child: ThemeConsumer(
        child: Builder(
            builder: (themeContext) => MaterialApp(
                  title: 'Flutter Demo',
                  debugShowCheckedModeBanner: false,
                  theme: ThemeProvider.themeOf(themeContext).data,
                  navigatorObservers: <NavigatorObserver>[observer],
                  home: MyHomePage(analytics, observer),
                )),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage(this.analytics, this.observer);

  FirebaseAnalytics analytics;
  FirebaseAnalyticsObserver observer;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Duration count_time = Duration(minutes: 5);
  bool _running = false;
  bool _warning = false;
  int time = Duration(minutes: 5).inSeconds;
  int? soundId;
  AudioCache audioCache = AudioCache();
  AudioPlayer audioPlayer = AudioPlayer(mode: PlayerMode.LOW_LATENCY);

  bool rolling = false;
  bool sound = true;

  List<int> beep_times = [
    0,
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    15,
    20,
    30,
    40,
    50,
    60,
    90,
    120,
    180,
    240,
    241,
    242,
    243,
    244,
    245
  ];
  List<int> beep_times_fast = [];

  void timer_func(Timer timer) {
    if (_running) {
      if (time == 0) {
        setState(() {
          _running = false;
        });
      } else {
        setState(() {
          time = time - 1;
        });

        if (time == 0 && sound) {
          audioCache.play(
            'beep2.mp3',
            mode: PlayerMode.LOW_LATENCY,
            stayAwake: true,
          );

          if (rolling) {
            startTimer();
          }
        }
        if (beeps().new_beeps(count_time).contains(time) && sound) {
          FlutterBeep.beep();
        }
      }
    }
  }

  Future<void> loadPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey("rolling")) {
      setState(() {
        rolling = prefs.getBool("rolling")!;
      });
    } else {
      prefs.setBool("rolling", false);
    }

    if (prefs.containsKey("warning")) {
      setState(() {
        _warning = prefs.getBool("warning")!;
      });
    } else {
      prefs.setBool("warning", false);
    }

    if (prefs.containsKey("sound")) {
      setState(() {
        sound = prefs.getBool("sound")!;
      });
    } else {
      prefs.setBool("sound", true);
    }

    if (prefs.containsKey("time")) {
      setState(() {
        count_time = Duration(seconds: prefs.getInt("time")!);
        time = count_time.inSeconds;
      });
    } else {
      prefs.setInt("time", time);
    }
  }

  void snack() {
    final snackBar = SnackBar(
      content: Text(
        'Start Timer First',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),

      action: SnackBarAction(
        label: "Ok",
        textColor: Colors.white,
        onPressed: () {
          Navigator.of(context);
        },
      ),
      // backgroundColor: Color.fromRGBO(50, 50, 50, 1),
      backgroundColor: Theme.of(context).primaryColor,
    );

    //ScaffoldMessenger.of(context).showSnackBar(snackBar);
    showTopSnackBar(
      context,
      CustomSnackBar.error(
        message: "Start The Timer First",
      ),
    );
  }

  Future<void> _initializeFlutterFire() async {
    // Wait for Firebase to initialize

    if (_kTestingCrashlytics) {
      // Force enable crashlytics collection enabled if we're testing it.
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    } else {
      // Else only enable it in non-debug builds.
      // You could additionally extend this to allow users to opt-in.
      await FirebaseCrashlytics.instance
          .setCrashlyticsCollectionEnabled(!kDebugMode);
    }
  }

  @override
  void initState() {
    _initializeFlutterFire();

    loadPrefs();
    Timer.periodic(Duration(seconds: 1), (timer) {
      timer_func(timer);
    });
    widget.analytics.setCurrentScreen(
      screenName: 'Timer Screen',
      screenClassOverride: 'Timer_Screen',
    );
    review().setUp();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            sound ? Icons.volume_up : Icons.volume_off,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: () async {
            setState(() {
              sound = !sound;
            });
            widget.analytics.logEvent(
              name: "sound_toggled",
              parameters: <String, dynamic>{
                'sound_on': sound,
              },
            );
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setBool("sound", sound);
          },
        ),
        actions: [
          IconButton(
              icon: Icon(
                Icons.settings,
                color: Theme.of(context).iconTheme.color,
              ),
              onPressed: () async {
                _running = false;
                time = count_time.inSeconds;

                back test = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => settings(
                            rolling,
                            count_time,
                            _warning,
                            analytics: widget.analytics,
                            observer: widget.observer,
                          ),
                      fullscreenDialog: true),
                );
                setState(() {
                  rolling = test.rolling;
                  count_time = test.chosenTime;
                  _warning = test.warning;
                  time = count_time.inSeconds;

                  if (_warning) {
                    time = count_time.inSeconds + 15;
                  }
                });
              }),
        ],
      ),
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                //"01:00",
                count_time.inSeconds >= 3584
                    ? Duration(seconds: time).toString().substring(0, 7)
                    : Duration(seconds: time).toString().substring(2, 7),
                style: TextStyle(fontSize: 70, fontWeight: FontWeight.bold),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (!_running) {
                        // time = count_time.inSeconds;
                        //  _running = true;
                        HapticFeedback.selectionClick();
                        startTimer();
                        widget.analytics.logEvent(name: "Timer_Started");
                      } else {
                        setState(() {
                          _running = false;
                          time = count_time.inSeconds;
                          widget.analytics.logEvent(name: "Timer_Canceled");
                        });
                      }
                    },
                    child: Container(
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: Theme.of(context).primaryColor, width: 3),
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                      child: Center(
                          child: Text(
                        !_running ? "Start" : "Cancel",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      )),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (_running) {
                        HapticFeedback.selectionClick();
                        widget.analytics.logEvent(name: "Timer_Synced");

                        setState(() {
                          time = (time ~/ 60) * 60;

                          if (time == 0 && rolling && sound) {
                            audioCache.play(
                              'beep2.mp3',
                              mode: PlayerMode.LOW_LATENCY,
                              stayAwake: true,
                            );
                            //time=count_time.inSeconds;
                            startTimer();
                          } else {
                            if (sound) {
                              FlutterBeep.beep();
                            }
                          }
                        });
                      } else {
                        snack();
                        if (sound) {
                          FlutterBeep.beep(false);
                        }
                        widget.analytics.logEvent(name: "Timer_Synced_Failed");
                      }
                      //audioCache.play('beep.mp3', mode: PlayerMode.LOW_LATENCY);
                    },
                    child: Container(
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: Theme.of(context).primaryColor, width: 3),
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                      child: Center(
                          child: Text(
                        "Sync",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      )),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void startTimer() {
    _running = true;

    if (_warning) {
      time = count_time.inSeconds + 15;
    } else {
      time = count_time.inSeconds;
    }

    setState(() {});
  }
}
