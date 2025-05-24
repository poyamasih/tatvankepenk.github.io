import 'package:flutter/material.dart';

/// A widget that detects user activity and updates session timers
class SessionActivityDetector extends StatefulWidget {
  final Widget child;
  final Function() onActivityDetected;
  final Duration inactivityDuration;
  final Function()? onInactivityTimeout;

  /// Constructor for the widget
  const SessionActivityDetector({
    Key? key,
    required this.child,
    required this.onActivityDetected,
    this.inactivityDuration = const Duration(minutes: 30),
    this.onInactivityTimeout,
  }) : super(key: key);

  @override
  State<SessionActivityDetector> createState() =>
      _SessionActivityDetectorState();
}

class _SessionActivityDetectorState extends State<SessionActivityDetector> {
  // Timer to track inactivity
  DateTime _lastActivityTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _setupInactivityCheck();
  }

  void _setupInactivityCheck() {
    // This would be called periodically to check for inactivity
    // For simplicity, we are only implementing the event detection part here
    // In a real app, you would use a Timer.periodic to check for inactivity
    _resetInactivityTimer();
  }

  void _resetInactivityTimer() {
    _lastActivityTime = DateTime.now();
    widget.onActivityDetected();
  }

  void _handleUserActivity() {
    final now = DateTime.now();
    final timeSinceLastActivity = now.difference(_lastActivityTime);

    // If the activity happened after the inactivity duration,
    // and we have an inactivity handler, call it
    if (timeSinceLastActivity >= widget.inactivityDuration &&
        widget.onInactivityTimeout != null) {
      widget.onInactivityTimeout!();
    }

    _resetInactivityTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _handleUserActivity(),
      onPointerMove: (_) => _handleUserActivity(),
      onPointerUp: (_) => _handleUserActivity(),
      child: widget.child,
    );
  }
}
