import 'package:flutter/material.dart';

// Enum of swipe directions.
enum SwipingDirection { left, right, none }

class CardPositionProvider extends ChangeNotifier {
  // X-axis deviation and swiping direction.
  double _dx = 0.0;
  SwipingDirection _swipingDirection = SwipingDirection.none;

  // Swiping direction getter.
  SwipingDirection get swipingDirection {
    return _swipingDirection;
  }

  // When card is put back in place (mouse let go event).
  void resetPosition() {
    _dx = 0.0;
    _swipingDirection = SwipingDirection.none;
    notifyListeners();
  }

  // When card is dragged (mouse drag event).
  void updatePosition(double changeInX) {
    _dx = _dx + changeInX;
    if (_dx > 0) {
      _swipingDirection = SwipingDirection.right;
    } else if (_dx < 0) {
      _swipingDirection = SwipingDirection.left;
    } else {
      _swipingDirection = SwipingDirection.none;
    }
    notifyListeners();
  }
}
