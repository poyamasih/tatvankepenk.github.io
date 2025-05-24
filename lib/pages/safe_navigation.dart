// A helper file with safe navigation methods for the HomePage

import 'package:flutter/material.dart';

/// Extension to safely navigate between pages
extension SafeNavigation on StatefulWidget {
  /// Returns a safe index that won't go out of bounds
  static int getSafePageIndex(int currentIndex, List<Widget> pages) {
    if (pages.isEmpty) return 0;
    return currentIndex.clamp(0, pages.length - 1);
  }

  /// Returns the title for a given page index with safety checks
  static String getPageTitle(int currentIndex, [List<String>? customTitles]) {
    final titles =
        customTitles ??
        [
          'Ana Sayfa',
          'Kepenk Sistemleri',
          'Endüstriyel Kapılar',
          'Hakkımızda',
          'İletişim',
        ];

    if (currentIndex < 0 || currentIndex >= titles.length) {
      return '';
    }
    return titles[currentIndex];
  }

  /// Checks if navigation to next page is possible
  static bool canNavigateNext(int currentIndex, List<Widget> pages) {
    return pages.isNotEmpty && currentIndex < (pages.length - 1);
  }

  /// Checks if navigation to previous page is possible
  static bool canNavigatePrevious(int currentIndex) {
    return currentIndex > 0;
  }
}
