import 'package:flutter/material.dart';
import 'action_painters.dart';
import 'nav_painters.dart';
import 'mode_painters.dart';
import 'learning_painters.dart';
import 'status_painters.dart';
import 'profile_painters.dart';
import 'topic_painters.dart';
import 'daily_time_painters.dart';
import 'tone_painters.dart';
import 'feature_painters.dart';

typedef IconPainterFn = void Function(
  Canvas canvas,
  Size size,
  double t,
  Color? color,
);

final Map<String, IconPainterFn> iconRegistry = {};

void initIconRegistry() {
  registerActionPainters(iconRegistry);
  registerNavPainters(iconRegistry);
  registerModePainters(iconRegistry);
  registerLearningPainters(iconRegistry);
  registerStatusPainters(iconRegistry);
  registerProfilePainters(iconRegistry);
  registerTopicPainters(iconRegistry);
  registerDailyTimePainters(iconRegistry);
  registerTonePainters(iconRegistry);
  registerFeaturePainters(iconRegistry);
}
