import 'dart:io';

import 'package:app_review/app_review.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dynamic_icon/flutter_dynamic_icon.dart';
import 'package:sailing_timer/icon%20page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:theme_provider/theme_provider.dart';
import 'package:settings_ui/settings_ui.dart';

import 'extra.dart';

class settings extends StatefulWidget {
  settings(this.rolling, this._chosenTime, this.warning,
      {required this.analytics, required this.observer});

  bool rolling;
  bool warning;
  Duration _chosenTime;
  FirebaseAnalytics analytics;
  FirebaseAnalyticsObserver observer;

  @override
  _settingsState createState() => _settingsState(_chosenTime);
}

class _settingsState extends State<settings> {
  _settingsState(this._chosenTime);

  String currentIconName = "?";

  Duration _chosenTime;

  Future<void> _showDatePicker(ctx) async {
    showCupertinoModalPopup(
      context: ctx,
      builder: (_) => Container(
          height: 250,
          decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius:
                  BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20))),
          child: CupertinoTimerPicker(
            onTimerDurationChanged: (Duration value) async {
              setState(() {
                _chosenTime = value;
              });
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setInt("time", _chosenTime.inSeconds);
            },
            mode: CupertinoTimerPickerMode.ms,
            initialTimerDuration: _chosenTime,
          )),
    ).then((value) {
      widget.analytics.logEvent(
        name: "Time_Set",
        parameters: <String, dynamic>{
          'time_in_seconds': _chosenTime.inSeconds,
        },
      );
      print("Time_Set logged");
    });
  }

  Widget icons(IconData iconsss) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Icon(
              iconsss,
              color: Colors.white,
            ),
          )),
    );
  }

  @override
  void initState() {
    widget.analytics.setCurrentScreen(
      screenName: 'Settings Screen',
      screenClassOverride: 'Setting_Screen',
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            CupertinoIcons.chevron_left,
            color: CupertinoColors.activeBlue,
            size: 30,
          ),
          onPressed: () {
            Navigator.pop(
              context,
              back(widget.rolling, _chosenTime, widget.warning),
            );
          },
        ),
        title: Text("Settings",style: TextStyle(fontSize: 25),),
        centerTitle: true,
        elevation: 0,
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: Text('Timer Settings'),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: icons(Icons.timer),
                title: Text('Timer'),
                value: Text(_chosenTime.toString().substring(2, 7)),
                onPressed: (test) {
                  _showDatePicker(context);
                },
              ),
              SettingsTile.switchTile(
                onToggle: (value) {
                  HapticFeedback.lightImpact();

                  setState(() {
                    widget.rolling = value;
                  });

                  widget.analytics.logEvent(
                    name: "Rolling_Toggled",
                    parameters: <String, dynamic>{
                      'rolling_start': value,
                    },
                  );

                  SharedPreferences.getInstance().then((prefs) {
                    prefs.setBool("rolling", value);
                  });
                },
                initialValue: widget.rolling,
                leading: icons(CupertinoIcons.refresh),
                title: Text('Rolling Starts'),
              ),
              SettingsTile.switchTile(
                onToggle: (value) {
                  setState(() async {
                    HapticFeedback.lightImpact();

                    setState(() {
                      widget.warning = value;
                    });
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    prefs.setBool("warning", value);

                    widget.analytics.logEvent(
                      name: "Warning_Toggled",
                      parameters: <String, dynamic>{
                        'value': value,
                      },
                    );
                  });
                },
                initialValue: widget.warning,
                leading: icons(Icons.warning),
                title: Text('Warning Horn'),
              ),
            ],
          ),
          SettingsSection(
            title: Text('App Settings'),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: icons(
                  Icons.dark_mode,
                ),
                title: Text('Theme'),
                value: Text(ThemeProvider.themeOf(context).description),
                onPressed: (test) async {
                  await showCupertinoDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (_) => ThemeConsumer(
                              child: ThemeDialog(
                            title: Text(ThemeProvider.themeOf(context).description),
                            hasDescription: false,
                            innerCircleColorBuilder: (AppTheme date) {
                              return date.data.primaryColor;
                            },
                            outerCircleColorBuilder: (AppTheme date) {
                              return Colors.grey;
                            },
                          )));

                  widget.analytics.logEvent(
                    name: "Theme_Changed",
                    parameters: <String, dynamic>{
                      'theme': ThemeProvider.themeOf(context).id,
                    },
                  );
                },
              ),
              SettingsTile.navigation(
                leading: icons(Icons.app_registration),
                title: Text('Change Icon'),
                //value: Text(ThemeProvider.themeOf(context).description),
                onPressed: (test) {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => iconPage(
                        analytics: widget.analytics,
                        observer: widget.observer,
                      ),
                      //fullscreenDialog: true
                    ),
                  );
                },
              ),
            ],
          ),
          SettingsSection(
            title: Text('Feedback'),
            tiles: <SettingsTile>[
              SettingsTile(
                title: Text("Info"),
                leading: icons(CupertinoIcons.info_circle),
                onPressed: (context) {
                  showAboutDialog(
                    context: context,
                    applicationName: "Sailing Timer",

                  );
                },
              ),
              SettingsTile.navigation(
                  leading: icons(
                    Icons.reviews,
                  ),
                  title: Text('Leave a Review'),
                  description: Text('Created By Oliver Eielson'),
                  // value: Text(ThemeProvider.themeOf(context).description),
                  onPressed: (test) {
                    if (Platform.isIOS) {
                      AppReview.requestReview;
                    }
                  }),
            ],
          ),
        ],
      ),
    );
  }
}
