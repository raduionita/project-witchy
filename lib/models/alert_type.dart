import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../theme/app_colors.dart';
import '../theme/app_icons.dart';

enum AlertType { periodPredicted, fertileWindow, logMissing, lunarMilestone }

extension AlertTypePresentation on AlertType {
  String toJson() => name;

  static AlertType fromJson(Object? raw) =>
      AlertType.values.firstWhere((t) => t.name == raw, orElse: () => AlertType.periodPredicted);

  FaIconData get icon => switch (this) {
    AlertType.periodPredicted => AppIcons.drop,
    AlertType.fertileWindow => AppIcons.moon,
    AlertType.logMissing => AppIcons.quill,
    AlertType.lunarMilestone => AppIcons.star,
  };

  Color get badgeBg => switch (this) {
    AlertType.periodPredicted => AppColors.pinkBg,
    AlertType.fertileWindow => AppColors.goldBg,
    AlertType.logMissing => AppColors.lav,
    AlertType.lunarMilestone => AppColors.lav,
  };

  Color get badgeFg => switch (this) {
    AlertType.periodPredicted => AppColors.pink,
    AlertType.fertileWindow => AppColors.gold,
    AlertType.logMissing => AppColors.pur,
    AlertType.lunarMilestone => AppColors.pur,
  };
}
