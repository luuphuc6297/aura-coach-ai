import 'package:flutter/widgets.dart';
import 'app_localizations.dart';

/// Ergonomic accessor for AppLocalizations. Use `context.loc.someKey` instead
/// of `AppLocalizations.of(context)!.someKey` so call sites stay short.
///
/// Falls back to the English bundle when `AppLocalizations.of(context)` is
/// null — guards against widget-tree edge cases where the localization
/// delegate hasn't installed yet (rare; happens during a hot-reload spike).
extension AppLocContext on BuildContext {
  AppLocalizations get loc =>
      AppLocalizations.of(this) ?? lookupAppLocalizations(const Locale('en'));
}
