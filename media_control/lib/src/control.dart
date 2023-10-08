import 'package:flutter/widgets.dart' show ChangeNotifier;
import 'package:meta/meta.dart';

abstract base class PlaybackController extends ChangeNotifier {
  static const int IDLE_INDEX = -1;

  int _index = IDLE_INDEX;
  
  PlaybackController();

  int get total;

  @nonVirtual
  set index(int value) {
    if (value < IDLE_INDEX || value >= total) {
      throw IndexError.withLength(value, total,
          message:
              "The index must be non-negative integer except '-1' denoted as idle state.");
    }

    _index = value;
    notifyListeners();
  }

  @nonVirtual
  int get index => _index;
}
