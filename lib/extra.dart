class back {
  back(this.rolling, this.chosenTime, this.warning);

  bool rolling;
  Duration chosenTime;
  bool warning;
}

class beeps {
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

  List<int> new_beeps(Duration time) {
    List<int> n = beep_times.toList();

    for (int i = 0; i < 65; i++) {
      n.add(i * 60);
    }

    for (int i = 0; i < 5; i++) {
      n.add(time.inSeconds + 10 + i);
    }

    return n;
  }
}
