import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dynamic_icon/flutter_dynamic_icon.dart';
import 'package:sailing_timer/icon%20page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:theme_provider/theme_provider.dart';
import 'package:ce_settings/ce_settings.dart';
import 'package:settings_ui/settings_ui.dart';

import 'extra.dart';

class settings extends StatefulWidget {
  settings(this.rolling, this._chosenTime, this.warning, {required this.analytics, required this.observer});

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

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  String currentIconName = "?";

  Duration _chosenTime;

  Future<void> _showDatePicker(ctx) async {
    showCupertinoModalPopup(
      context: ctx,
      builder: (_) => Container(
          height: 250,
          decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20))),
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

  Widget rollingStarts() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
        height: 100,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(25),
            ),
            border: Border.all(color: Theme.of(context).primaryColor, width: 2)),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Icon(
                Icons.refresh,
                size: 30,
                color: Theme.of(context).iconTheme.color,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Rolling Starts",
                style: TextStyle(fontSize: 20),
              ),
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: CupertinoSwitch(
                value: widget.rolling,
                onChanged: (val) async {
                  HapticFeedback.lightImpact();

                  setState(() {
                    widget.rolling = val;
                  });
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  prefs.setBool("rolling", val);
                  widget.analytics.logEvent(
                    name: "Rolling_Toggled",
                    parameters: <String, dynamic>{
                      'rolling_start': val,
                    },
                  );
                },
                activeColor: Theme.of(context).primaryColor,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget chosenTime() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: GestureDetector(
        onTap: () async {
          _showDatePicker(context);
        },
        child: Container(
          height: 100,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(25),
              ),
              border: Border.all(color: Theme.of(context).primaryColor, width: 2)),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Icon(
                  Icons.timer,
                  size: 30,
                  color: Theme.of(context).iconTheme.color,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Starts Time",
                      style: TextStyle(fontSize: 20),
                    ),
                    Text(
                      _chosenTime.toString().substring(2, 7),
                      style: TextStyle(fontSize: 17, color: Theme.of(context).primaryColor),
                    ),
                  ],
                ),
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.chevron_right,
                  size: 30,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget warningBeep() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
        height: 100,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(25),
            ),
            border: Border.all(color: Theme.of(context).primaryColor, width: 2)),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Icon(
                Icons.warning_amber_outlined,
                size: 30,
                color: Theme.of(context).iconTheme.color,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Warning Horn",
                style: TextStyle(fontSize: 20),
              ),
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: CupertinoSwitch(
                value: widget.warning,
                onChanged: (val) async {
                  HapticFeedback.lightImpact();

                  setState(() {
                    widget.warning = val;
                  });
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  prefs.setBool("warning", val);

                  widget.analytics.logEvent(
                    name: "Warning_Toggled",
                    parameters: <String, dynamic>{
                      'value': val,
                    },
                  );
                },
                activeColor: Theme.of(context).primaryColor,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget icon() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: GestureDetector(
        onTap: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => iconPage(
                      analytics: widget.analytics,
                      observer: widget.observer,
                    ),
                fullscreenDialog: true),
          );
        },
        child: Container(
          height: 100,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(25),
              ),
              border: Border.all(color: Theme.of(context).primaryColor, width: 2)),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Icon(
                  Icons.app_registration,
                  size: 30,
                  color: Theme.of(context).iconTheme.color,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Change Icon",
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Spacer(),
              Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Icon(
                    Icons.chevron_right,
                    size: 25,
                  ))
            ],
          ),
        ),
      ),
    );
  }

  Widget theme() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: GestureDetector(
        onTap: () async {
          await showCupertinoDialog(
              context: context,
              builder: (_) => ThemeConsumer(
                      child: ThemeDialog(
                    // selectedOverlayColor: Colors.grey,
                    title: Text(ThemeProvider.themeOf(context).description),
                    hasDescription: false,
                    innerCircleColorBuilder: (AppTheme date) {
                      return date.data.accentColor;
                    },
                    outerCircleColorBuilder: (AppTheme date) {
                      return Colors.grey;
                    },
                  )));

          await widget.analytics.logEvent(
            name: "Theme_Changed",
            parameters: <String, dynamic>{
              'theme': ThemeProvider.themeOf(context).id,
            },
          );
        },
        child: Container(
          height: 100,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(25),
              ),
              border: Border.all(color: Theme.of(context).primaryColor, width: 2)),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Icon(
                  Icons.dark_mode_outlined,
                  size: 30,
                  color: Theme.of(context).iconTheme.color,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Theme",
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Spacer(),
              Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Icon(
                    Icons.chevron_right,
                    size: 25,
                  ))
            ],
          ),
        ),
      ),
    );
  }

  Widget icons(IconData iconsss){

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
            child: Icon(iconsss,color: Colors.white,),
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

    return  Scaffold(

      appBar: AppBar(


        leading: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GestureDetector(
              onTap: (){
                Navigator.pop(context);

              },
              child: Icon(CupertinoIcons.chevron_left,color: CupertinoColors.activeBlue,size: 30,)),
        ),

        title: Text("Settings",style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold,),),
        centerTitle: false,
        leadingWidth: 50,
        backgroundColor: CupertinoColors.darkBackgroundGray,
        elevation: 0,
      ),



      body:   SettingsList(
        sections: [
          SettingsSection(
            title: Text('Timer Settings'),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: icons(Icons.timer),
                title: Text('Timer'),
                value: Text('English'),
              ),
              SettingsTile.switchTile(
                onToggle: (value) {
                  setState(() {
                    widget.rolling=value;
                  });
                },
                initialValue: widget.rolling,
                leading: icons(CupertinoIcons.refresh),
                title: Text('Rolling Starts'),
              ),
              SettingsTile.switchTile(
                onToggle: (value) {
                  setState(() {
                    widget.warning=value;
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

                leading: icons(Icons.dark_mode,),
                title: Text('Theme'),
                value: Text(ThemeProvider.themeOf(context).description),
                onPressed: (test) async {
                  await showCupertinoDialog(
                      context: context,
                      barrierDismissible: true,

                      builder: (_) => ThemeConsumer(
                      child: ThemeDialog(
                        // selectedOverlayColor: Colors.grey,

                        title: Text(ThemeProvider.themeOf(context).description),
                        hasDescription: false,

                        innerCircleColorBuilder: (AppTheme date) {
                          return date.data.accentColor;
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
                onPressed: (test){

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => iconPage(
                          analytics: widget.analytics,
                          observer: widget.observer,
                        ),
                        fullscreenDialog: true),
                  );

                },
              ),
            ],
          ),


        ],
      ),
    );




    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          "Settings",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25, color: Theme.of(context).primaryColorLight),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(
              context,
              back(widget.rolling, _chosenTime, widget.warning),
            );
          },
          icon: Icon(
            Icons.chevron_left,
            size: 40,
            color: Theme.of(context).iconTheme.color,
          ),
          //splashColor: Colors.lightBlueAccent,
        ),
      ),
      body: ListView(
        children: [
          chosenTime(),
          rollingStarts(),
          warningBeep(),
          theme(),
          icon(),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Container(
              height: 50,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Text("Created by"),
                  ),
                  Text("Oliver Eielson"),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
