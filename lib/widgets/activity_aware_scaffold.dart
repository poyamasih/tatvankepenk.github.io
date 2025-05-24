import 'package:flutter/material.dart';

/// A Scaffold wrapper that detects user activity and calls a callback
/// This helps manage session timeouts by resetting timers when user interacts with the UI
class ActivityAwareScaffold extends StatelessWidget {
  final Widget? appBar;
  final Widget? body;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final List<Widget>? persistentFooterButtons;
  final Widget? drawer;
  final Widget? endDrawer;
  final Color? backgroundColor;
  final bool? resizeToAvoidBottomInset;
  final bool primary;
  final VoidCallback onUserActivity;

  /// Constructor that takes all Scaffold parameters plus an onUserActivity callback
  const ActivityAwareScaffold({
    Key? key,
    this.appBar,
    this.body,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.persistentFooterButtons,
    this.drawer,
    this.endDrawer,
    this.backgroundColor,
    this.resizeToAvoidBottomInset,
    this.primary = true,
    required this.onUserActivity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Wrap the entire scaffold with a Listener to detect user activity
    return Listener(
      onPointerDown: (_) => onUserActivity(),
      onPointerMove: (_) => onUserActivity(),
      onPointerUp: (_) => onUserActivity(),
      child: Scaffold(
        appBar: appBar as PreferredSizeWidget?,
        body: body,
        floatingActionButton: floatingActionButton,
        floatingActionButtonLocation: floatingActionButtonLocation,
        persistentFooterButtons: persistentFooterButtons,
        drawer: drawer,
        endDrawer: endDrawer,
        backgroundColor: backgroundColor,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        primary: primary,
      ),
    );
  }
}
