import 'package:flutter/material.dart';

class LivesCollectionProvider extends ChangeNotifier {
  int myLives = 50;
  int johnLives = 30;
  int collectedLives = 0;
  bool isAnimating = false;
  Exception? fetchLivesError;

  bool fetchingLives = false;
  void startFetchingLives() {
    fetchingLives = true;
    johnLives = 0;
    notifyListeners();
    Future.delayed(const Duration(seconds: 2), () {
      fetchingLives = false;
      johnLives = 30;
      notifyListeners();
      fetchLivesError = Exception('Failed to fetch lives');
    });
  }

  bool canCollectLives() => myLives > 0 && johnLives > 0 && !isAnimating;
  bool canReturnLives() => collectedLives > 0 && !isAnimating;

  void _setAnimating() {
    isAnimating = true;
    notifyListeners();
    Future.delayed(const Duration(milliseconds: 600), () {
      isAnimating = false;
      notifyListeners();
    });
  }

  void collectLives() {
    if (canCollectLives()) {
      myLives--;
      johnLives--;
      collectedLives += 2;
      _setAnimating();
    }
  }

  void returnLives() {
    if (canReturnLives()) {
      myLives++;
      johnLives++;
      collectedLives -= 2;
      _setAnimating();
    }
  }
}

final globalProvider = LivesCollectionProvider();
