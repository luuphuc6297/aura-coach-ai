/// Build-time feature flags for the app.
///
/// Flags are simple `static const bool` so the Dart compiler tree-shakes
/// disabled branches. Toggle here and rebuild — no remote config layer
/// yet. When we move to Firebase Remote Config or similar, this file
/// becomes the single point of indirection so call sites don't change.
abstract final class FeatureFlags {
  /// Tone Translator mode. Disabled in favor of Grammar Coach as of
  /// 2026-04-30. Code paths are preserved (prompts, gemini service,
  /// i18n strings, conversation-history "tone" docs) so the mode can
  /// be re-enabled cleanly.
  static const bool toneTranslatorEnabled = false;

  /// Grammar Coach mode. The replacement for Tone in the third Home
  /// slot. Toggle off to hide the Home card without removing the
  /// `/grammar*` routes — useful for surgical rollback.
  static const bool grammarCoachEnabled = true;
}
