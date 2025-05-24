import 'package:flutter/material.dart';

class PageIndicator extends StatelessWidget {
  final int currentPage;
  final int pageCount;
  final Color activeColor;
  final Color inactiveColor;
  final double size;
  final double spacing;

  const PageIndicator({
    Key? key,
    required this.currentPage,
    required this.pageCount,
    this.activeColor = Colors.white,
    this.inactiveColor = Colors.white38,
    this.size = 10.0,
    this.spacing = 8.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        pageCount,
        (index) => Container(
          margin: EdgeInsets.symmetric(horizontal: spacing / 2),
          width: currentPage == index ? size * 2.5 : size,
          height: size,
          decoration: BoxDecoration(
            color: currentPage == index ? activeColor : inactiveColor,
            borderRadius: BorderRadius.circular(size / 2),
          ),
        ),
      ),
    );
  }
}
