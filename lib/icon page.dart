import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dynamic_icon/flutter_dynamic_icon.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class iconPage extends StatefulWidget {
  iconPage({required this.analytics, required this.observer});

  FirebaseAnalytics analytics;
  FirebaseAnalyticsObserver observer;

  @override
  _iconPageState createState() => _iconPageState();
}

class _iconPageState extends State<iconPage> {

  int iconIndex= -1;

  List<String> iconName = [
    "assets/images/helm.png",
    "assets/images/clock.png",
    "assets/images/hourglass.png",
    "assets/images/watch.png",
    "assets/images/boat.png"
  ];
  List<String> iconfile = ["helm", "clock", "hourglass", "watch", "boat"];
  List<String> iconScreenNames = ["Helm Icon", "Clock Icon", "Hourglass Icon", "Watch Icon", "Boat Icon"];

  @override
  void initState() {
    checkIcon();
    widget.analytics.setCurrentScreen(
      screenName: 'Icon Screen',
      screenClassOverride: 'Icon_Screen',
    );
    super.initState();
  }

  void snack() {
    final snackBar = SnackBar(
      content: Text(
        'Error Changing Icon!',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      // backgroundColor: Color.fromRGBO(50, 50, 50, 1),
      backgroundColor: Theme.of(context).primaryColor,
      action: SnackBarAction(
        label: "Ok",
        textColor: Colors.white,
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
    // ScaffoldMessenger.of(context).showSnackBar(snackBar);
    showTopSnackBar(
      context,
      CustomSnackBar.error(
        message: "Error Changing Icon",
      ),
    );
  }

  Widget old() {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Change App Icon",
          style: TextStyle(color: Theme.of(context).primaryColorLight),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 15, right: 15, top: 30),
        child: GridView.builder(
          itemCount: iconName.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () async {
                try {
                  if (await FlutterDynamicIcon.supportsAlternateIcons) {
                    await FlutterDynamicIcon.setAlternateIconName(
                        iconfile[index]);
                    print("App icon change successful");
                    return;
                  }
                } on PlatformException {
                } catch (e) {
                  snack();
                  widget.analytics.logEvent(
                    name: "app_icon_change_failed",
                    parameters: <String, dynamic>{
                      'Icon': iconfile[index],
                    },
                  );
                }

                widget.analytics.logEvent(
                  name: "app_icon_changed",
                  parameters: <String, dynamic>{
                    'icon': iconfile[index],
                  },
                );
              },
              child: Container(
                decoration: BoxDecoration(
                    color: Color.fromRGBO(47, 48, 48, 1),
                    borderRadius: BorderRadius.all(
                      Radius.circular(25),
                    ),
                    border: Border.all(
                        color: Theme.of(context).primaryColor, width: 4)),
                child: Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Image.asset(iconName[index]),
                ),
              ),
            );
          },
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 25.0,
            mainAxisSpacing: 25.0,
          ),
        ),
      ),
    );
  }

  Future<void> checkIcon() async {
    String? s = await FlutterDynamicIcon.getAlternateIconName();
    setState(() {
      iconIndex=iconfile.indexOf(s!);
    });
  }

  Future<void> changeIcon(int index) async {

    try {
      if (await FlutterDynamicIcon.supportsAlternateIcons) {
        await FlutterDynamicIcon.setAlternateIconName(
            iconfile[index]);
        print("App icon change successful");
        setState(() {
          iconIndex=index;
          print(index);
        });
        return;
      }
    } on PlatformException {
    } catch (e) {
      snack();
      widget.analytics.logEvent(
        name: "app_icon_change_failed",
        parameters: <String, dynamic>{
          'Icon': iconfile[index],
        },
      );
    }

    widget.analytics.logEvent(
      name: "app_icon_changed",
      parameters: <String, dynamic>{
        'icon': iconfile[index],
      },
    );
    //checkIcon();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(
                CupertinoIcons.chevron_left,
                color: CupertinoColors.activeBlue,
                size: 30,
              )),
        ),
        title: Text(
          "Change App Icon",
          style: TextStyle(fontSize: 20),
        ),
      ),
      body: SettingsList(sections: [
        SettingsSection(
            title: Text('Icon Settings'),
            tiles: List.generate(
                iconName.length,
                (index) => SettingsTile(
                      title: Text(iconScreenNames[index]),
                      onPressed: (test){

                        changeIcon(index);
                      },
                      leading: Padding(
                        padding: const EdgeInsets.all(8.0),

                        child: Container(
                          decoration: BoxDecoration(
                              color: Color.fromRGBO(47, 48, 48, 1),
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                              border: Border.all(
                                  color: iconIndex==index?Theme.of(context).primaryColor:Colors.transparent, width: 2)),
                          child: ClipRRect(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              child: Image.asset(
                                iconName[index],
                                width: 60,
                              )),
                        ),
                      ),
                    )))
      ]),
    );
  }
}
