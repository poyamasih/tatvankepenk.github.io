import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PageTransitionView extends StatefulWidget {
  final List<Widget> pages;
  final PageController controller;
  final ValueChanged<int> onPageChanged;
  final int currentPage;

  const PageTransitionView({
    Key? key,
    required this.pages,
    required this.controller,
    required this.onPageChanged,
    required this.currentPage,
  }) : super(key: key);

  @override
  State<PageTransitionView> createState() => _PageTransitionViewState();
}

class _PageTransitionViewState extends State<PageTransitionView> {
  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: widget.controller,
      scrollDirection: Axis.horizontal,
      onPageChanged: widget.onPageChanged,
      physics: const BouncingScrollPhysics(),
      itemCount: widget.pages.length,
      itemBuilder: (context, index) {
        final isActive = index == widget.currentPage;

        return Animate(
          effects: [
            // Only apply animation when page becomes active
            if (isActive) ...[
              SlideEffect(
                begin: const Offset(1.0, 0),
                end: Offset.zero,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutQuint,
              ),
              FadeEffect(
                begin: 0.5,
                end: 1.0,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOut,
              ),
            ],
          ],
          child: widget.pages[index],
        );
      },
    );
  }
}
