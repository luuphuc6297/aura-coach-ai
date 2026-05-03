import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/clay_palette.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/app_loc_context.dart';
import '../../../shared/widgets/clay_pressable.dart';
import '../data/help_content.dart';

/// Hybrid Help Center for the AI Agent tab. Top-down structure:
///
/// 1. Hero card "Ask Aura" — primary CTA opens the live chat screen.
/// 2. Quick guides — one collapsible card per major mode.
/// 3. FAQ — accordion of common questions.
/// 4. Contact — email / hotline / send-feedback affordances.
///
/// All static content lives in [HelpContent]. The Ask AI flow lives in a
/// separate route (`/ai-agent/chat`) backed by [AIAgentChatProvider].
class AIAgentScreen extends StatelessWidget {
  const AIAgentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.clay.background,
      appBar: AppBar(
        backgroundColor: context.clay.background,
        surfaceTintColor: context.clay.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(context.loc.helpTitle, style: AppTypography.h2),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.xxl,
        ),
        children: [
          _AskAuraHero(onOpenChat: () => context.push('/ai-agent/chat')),
          const SizedBox(height: AppSpacing.lg),
          _SectionHeader(label: context.loc.helpSectionQuickGuides, count: null),
          const SizedBox(height: AppSpacing.sm),
          for (final guide in HelpContent.guides) ...[
            _GuideCard(guide: guide),
            const SizedBox(height: AppSpacing.sm),
          ],
          const SizedBox(height: AppSpacing.md),
          _SectionHeader(label: context.loc.helpSectionFaq, count: null),
          const SizedBox(height: AppSpacing.sm),
          for (final faq in HelpContent.faqs) ...[
            _FaqTile(faq: faq),
            const SizedBox(height: AppSpacing.xs),
          ],
          const SizedBox(height: AppSpacing.md),
          _SectionHeader(label: context.loc.helpSectionContact, count: null),
          const SizedBox(height: AppSpacing.sm),
          const _ContactCard(),
        ],
      ),
    );
  }
}

class _AskAuraHero extends StatelessWidget {
  final VoidCallback onOpenChat;
  const _AskAuraHero({required this.onOpenChat});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.purple, AppColors.purpleDeep],
        ),
        border: Border.all(color: context.clay.text, width: 2),
        borderRadius: AppRadius.lgBorder,
        boxShadow: AppShadows.clay(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: AppRadius.mdBorder,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.support_agent_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      context.loc.helpAskAuraTitle,
                      style: AppTypography.h3.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.loc.helpAskAuraSubtitle,
                      style: AppTypography.bodySm.copyWith(
                        color: Colors.white.withValues(alpha: 0.92),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClayPressable(
            onTap: onOpenChat,
            scaleDown: 0.97,
            builder: (context, _) => Container(
              padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: context.clay.text, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: context.clay.text,
                    offset: const Offset(2, 2),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: AppColors.purpleDeep,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    context.loc.helpAskAuraStartChat,
                    style: GoogleFonts.fredoka(
                      color: AppColors.purpleDeep,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final int? count;
  const _SectionHeader({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.fredoka(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: context.clay.text,
            ),
          ),
          if (count != null) ...[
            const SizedBox(width: 8),
            Text(
              '· $count',
              style: AppTypography.bodySm.copyWith(color: context.clay.textMuted),
            ),
          ],
        ],
      ),
    );
  }
}

class _GuideCard extends StatefulWidget {
  final HelpGuide guide;
  const _GuideCard({required this.guide});

  @override
  State<_GuideCard> createState() => _GuideCardState();
}

class _GuideCardState extends State<_GuideCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return ClayPressable(
      onTap: () => setState(() => _expanded = !_expanded),
      scaleDown: 0.99,
      builder: (context, _) => AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: context.clay.surface,
          borderRadius: AppRadius.lgBorder,
          border: Border.all(
            color: _expanded ? context.clay.text : context.clay.border,
            width: _expanded ? 2 : 1.5,
          ),
          boxShadow: _expanded ? AppShadows.clayBold(context) : AppShadows.card(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.guide.title,
                    style: GoogleFonts.fredoka(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: context.clay.text,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: context.clay.textMuted,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              widget.guide.summary,
              style: AppTypography.bodySm.copyWith(color: context.clay.textMuted),
            ),
            if (_expanded) ...[
              const SizedBox(height: AppSpacing.sm),
              Container(
                height: 1,
                color: context.clay.border,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                widget.guide.body,
                style: AppTypography.bodyMd.copyWith(
                  color: context.clay.text,
                  height: 1.55,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FaqTile extends StatefulWidget {
  final HelpFaq faq;
  const _FaqTile({required this.faq});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return ClayPressable(
      onTap: () => setState(() => _open = !_open),
      scaleDown: 0.99,
      builder: (context, _) => AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.smd,
        ),
        decoration: BoxDecoration(
          color: context.clay.surface,
          borderRadius: AppRadius.mdBorder,
          border: Border.all(color: context.clay.border, width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.faq.question,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: context.clay.text,
                      height: 1.4,
                    ),
                  ),
                ),
                Icon(
                  _open
                      ? Icons.remove_circle_outline_rounded
                      : Icons.add_circle_outline_rounded,
                  size: 18,
                  color: context.clay.textMuted,
                ),
              ],
            ),
            if (_open) ...[
              const SizedBox(height: 6),
              Text(
                widget.faq.answer,
                style: AppTypography.bodySm.copyWith(
                  color: context.clay.textMuted,
                  height: 1.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.clay.surface,
        borderRadius: AppRadius.lgBorder,
        border: Border.all(color: context.clay.border, width: 1.5),
        boxShadow: AppShadows.card(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ContactRow(
            icon: Icons.mail_outline_rounded,
            label: context.loc.helpContactEmailLabel,
            value: HelpContent.contactEmail,
            onCopyToast: context.loc.helpContactCopyEmailToast,
          ),
          const SizedBox(height: AppSpacing.sm),
          _ContactRow(
            icon: Icons.phone_outlined,
            label: context.loc.helpContactHotlineLabel,
            value: HelpContent.contactHotline,
            onCopyToast: context.loc.helpContactCopyHotlineToast,
          ),
          const SizedBox(height: AppSpacing.md),
          ClayPressable(
            onTap: () => _showFeedbackSheet(context),
            scaleDown: 0.97,
            builder: (context, _) => Container(
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(
                color: AppColors.coral,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.clay.text, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: context.clay.text,
                    offset: const Offset(2, 2),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.feedback_outlined,
                      size: 16,
                      color: context.clay.surface,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      context.loc.helpFeedbackButton,
                      style: GoogleFonts.fredoka(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: context.clay.surface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFeedbackSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: context.clay.text.withValues(alpha: 0.45),
      builder: (sheetCtx) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(sheetCtx).viewInsets.bottom),
        child: const _FeedbackSheet(),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String onCopyToast;

  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onCopyToast,
  });

  @override
  Widget build(BuildContext context) {
    return ClayPressable(
      onTap: () async {
        await Clipboard.setData(ClipboardData(text: value));
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(onCopyToast),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      scaleDown: 0.97,
      builder: (context, _) => Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: context.clay.surfaceAlt,
          borderRadius: AppRadius.mdBorder,
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: context.clay.text),
            const SizedBox(width: 10),
            SizedBox(
              width: 60,
              child: Text(
                label,
                style: AppTypography.labelMd
                    .copyWith(color: context.clay.textMuted, fontSize: 12),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: AppTypography.bodyMd.copyWith(
                  color: context.clay.text,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.content_copy_rounded,
              size: 14,
              color: context.clay.textFaint,
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedbackSheet extends StatefulWidget {
  const _FeedbackSheet();

  @override
  State<_FeedbackSheet> createState() => _FeedbackSheetState();
}

class _FeedbackSheetState extends State<_FeedbackSheet> {
  final _controller = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _submitting = true);
    // Persistence is intentionally a stub for v1 — real wiring (Firestore
    // `feedback/{uid}_{ts}` doc) lands when the team sets up the support
    // pipeline. For now we just ack receipt so users get UX feedback.
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    Navigator.of(context).maybePop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.loc.helpFeedbackThanksToast),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.clay.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        border: Border(top: BorderSide(color: context.clay.text, width: 2)),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: context.clay.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              context.loc.helpFeedbackTitle,
              style: AppTypography.h3.copyWith(color: context.clay.text),
            ),
            const SizedBox(height: 4),
            Text(
              context.loc.helpFeedbackBody,
              style:
                  AppTypography.bodySm.copyWith(color: context.clay.textMuted),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _controller,
              maxLines: 5,
              minLines: 4,
              autofocus: true,
              decoration: InputDecoration(
                hintText: context.loc.helpFeedbackHint,
                hintStyle: AppTypography.bodyMd
                    .copyWith(color: context.clay.textFaint),
                filled: true,
                fillColor: context.clay.background,
                contentPadding: const EdgeInsets.all(14),
                border: OutlineInputBorder(
                  borderRadius: AppRadius.mdBorder,
                  borderSide:
                      BorderSide(color: context.clay.border, width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppRadius.mdBorder,
                  borderSide:
                      BorderSide(color: context.clay.border, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppRadius.mdBorder,
                  borderSide:
                      const BorderSide(color: AppColors.coral, width: 2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: ClayPressable(
                    onTap: () => Navigator.of(context).maybePop(),
                    scaleDown: 0.96,
                    builder: (context, _) => Container(
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      decoration: BoxDecoration(
                        color: context.clay.surface,
                        borderRadius: BorderRadius.circular(10),
                        border:
                            Border.all(color: context.clay.border, width: 1.5),
                      ),
                      child: Center(
                        child: Text(
                          context.loc.commonCancel,
                          style: GoogleFonts.fredoka(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: context.clay.text,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: ClayPressable(
                    onTap: _submitting ? null : _submit,
                    scaleDown: 0.96,
                    builder: (context, _) => Container(
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      decoration: BoxDecoration(
                        color: _submitting
                            ? AppColors.coral.withValues(alpha: 0.55)
                            : AppColors.coral,
                        borderRadius: BorderRadius.circular(10),
                        border:
                            Border.all(color: context.clay.text, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: context.clay.text,
                            offset: const Offset(2, 2),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Center(
                        child: _submitting
                            ? SizedBox.square(
                                dimension: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(
                                      context.clay.surface),
                                ),
                              )
                            : Text(
                                context.loc.helpFeedbackSendButton,
                                style: GoogleFonts.fredoka(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: context.clay.surface,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
