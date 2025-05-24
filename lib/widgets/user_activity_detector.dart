import 'package:flutter/material.dart';

/// A widget that detects user activity (taps, scrolls, etc.) and calls a callback when detected.
class UserActivityDetector extends StatelessWidget {
  final Widget child;
  final VoidCallback onUserActivity;

  const UserActivityDetector({
    Key? key,
    required this.child,
    required this.onUserActivity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => onUserActivity(),
      onPointerMove: (_) => onUserActivity(),
      onPointerUp: (_) => onUserActivity(),
      child: child,
    );
  }
}
