import 'package:flutter/material.dart';

import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/clay_palette.dart';
import '../../../shared/widgets/clay_back_button.dart';

/// Static "Data & privacy" screen surfaced from Settings. Lays out the data
/// we collect, where it lives, and the user's rights. Copy is a sensible
/// baseline — Legal will refine before public launch.
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.clay.background,
      appBar: AppBar(
        backgroundColor: context.clay.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.only(left: AppSpacing.sm),
          child: ClayBackButton(),
        ),
        title: Text('Data & privacy', style: AppTypography.h2),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.xxl,
        ),
        children: const [
          // Using const here is safe — _Section.build resolves theme tokens
          // from BuildContext at runtime.
          _Section(
            title: 'What we collect',
            body:
                'Your account profile (name, avatar, learning level, selected '
                'topics), conversations and stories you create, vocabulary '
                'items you save, mind maps, and aggregate practice metrics '
                '(streak, time, skill scores).',
          ),
          _Section(
            title: 'Where it lives',
            body:
                'Profile + content data is stored on Google Firestore, scoped '
                'to your account. AI generations (chat replies, story text, '
                'word lookups) are processed via Gemini and not retained on '
                'our servers beyond the chat session.',
          ),
          _Section(
            title: 'Your rights',
            body:
                'You can edit your profile any time from Profile > Edit '
                'profile. You can delete your account from Settings > Delete '
                'account; this permanently removes every record tied to your '
                'uid. Email support@auracoach.ai for data export requests.',
          ),
          _Section(
            title: 'Notifications',
            body:
                'When you enable Daily reminders, the app schedules local '
                'notifications on your device — no push token is sent to a '
                'server. You can revoke notification permission anytime from '
                'your device Settings.',
          ),
          _Section(
            title: 'Third parties',
            body:
                'Google (Sign-in, Firebase, Gemini), Apple (Sign in with '
                'Apple). No advertising trackers. We do not sell or share '
                'your data with marketers.',
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String body;
  const _Section({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: context.clay.surface,
          borderRadius: AppRadius.lgBorder,
          border: Border.all(color: context.clay.border, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTypography.h3.copyWith(color: context.clay.text),
            ),
            const SizedBox(height: 6),
            Text(
              body,
              style: AppTypography.bodyMd.copyWith(
                color: context.clay.textMuted,
                height: 1.55,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
