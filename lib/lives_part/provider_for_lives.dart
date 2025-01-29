import 'package:flutter/material.dart';

class LivesCollectionProvider extends ChangeNotifier {
  int myLives = 5;
  int johnLives = 3;
  int collectedLives = 0;

  bool canCollectLives() {
    return myLives > 0 && johnLives > 0;
  }

  bool canReturnLives() {
    return collectedLives > 0;
  }

  void collectLives() {
    if (canCollectLives()) {
      myLives--;
      johnLives--;
      collectedLives += 2;
      notifyListeners();
    }
  }

  void returnLives() {
    if (canReturnLives()) {
      myLives++;
      johnLives++;
      collectedLives -= 2;
      notifyListeners();
    }
  }
}

final globalProvider = LivesCollectionProvider();
