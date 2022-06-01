import 'dart:io';
import 'dart:math';

import 'package:app_review/app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

class review {
  int _timesVisited = 0;

  void setUp() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey("startUp")) {
      _timesVisited = prefs.getInt("startUp")!;
      _timesVisited++;
      prefs.setInt("startUp", _timesVisited);
    } else {
      prefs.setInt("startUp", 0);
    }

    int random = Random().nextInt(100);

    print("random Number: $random     times visited:$_timesVisited");

    if (_timesVisited > 20 && random < 20) {
      if (Platform.isIOS) {
        AppReview.requestReview.then((onValue) {
          prefs.setInt("startUp", -100);
        });
      }
    }
  }
}
