import 'package:flutter/material.dart';

import '../constants/enum.dart';

class Responsive {
  Responsive._();

  static DeviceType deviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return DeviceType.compact;
    if (width < 1024) return DeviceType.medium;
    return DeviceType.expanded;
  }

  static bool isCompact(BuildContext c) => deviceType(c) == DeviceType.compact;
  static bool isMedium(BuildContext c) => deviceType(c) == DeviceType.medium;
  static bool isExpanded(BuildContext c) =>
      deviceType(c) == DeviceType.expanded;

  static double horizontalPadding(BuildContext context) {
    switch (deviceType(context)) {
      case DeviceType.compact:
        return 16;
      case DeviceType.medium:
        return 24;
      case DeviceType.expanded:
        return 40;
    }
  }

  static double maxContentWidth(BuildContext context) {
    switch (deviceType(context)) {
      case DeviceType.compact:
        return double.infinity;
      case DeviceType.medium:
        return 720;
      case DeviceType.expanded:
        return 980;
    }
  }
}
