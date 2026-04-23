# Roleplay Mode (Scenario Coach) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement the full Scenario Coach roleplay flow — scenario selection, immersive chat with AI-generated prompts and assessments, session summary — matching the Phase 2-4 mockup pixel-perfectly.

**Architecture:** Feature-first clean architecture. A `ScenarioProvider` manages session state (messages, current scenario, progress). The chat screen uses a `ListView` of polymorphic message widgets (user bubble, AI bubble, assessment card, translate prompt). AI responses are stubbed with realistic mock data first — real API integration is a separate task. Navigation via GoRouter with `/scenario` and `/scenario/summary` routes.

**Tech Stack:** Flutter 3.x, Provider, GoRouter, Firestore (session persistence), Clay Design System tokens (AppColors, AppTypography, AppShadows, AppRadius).

---

## File Structure

```
lib/features/scenario/
├── models/
│   ├── scenario.dart              # Scenario data (title, category, level, prompts)
│   ├── chat_message.dart          # Polymorphic message types (user, ai, assessment, system)
│   └── assessment.dart            # Assessment data (score, metrics, toneVariations, tip)
├── data/
│   └── scenario_catalog.dart      # Hardcoded scenario list (mock data)
├── providers/
│   └── scenario_provider.dart     # Session state: messages, currentScenario, progress
├── screens/
│   ├── scenario_select_screen.dart # Scenario picker (list of scenario cards)
│   ├── scenario_chat_screen.dart   # Main chat screen (app bar + translate prompt + chat + input)
│   └── session_summary_screen.dart # End-of-session summary with stats
└── widgets/
    ├── scenario_app_bar.dart       # Custom app bar with title, category, progress bar
    ├── translate_prompt.dart        # Bold translate prompt banner
    ├── chat_bubble_user.dart        # User message bubble (teal, clay shadow, listen tag)
    ├── chat_bubble_ai.dart          # AI message bubble (avatar + white card)
    ├── inline_assessment.dart       # Inline assessment card (score circle + metrics + tip)
    ├── metric_bar.dart              # Reusable metric pill (label + bar + value)
    ├── score_circle.dart            # Animated score circle widget
    ├── chat_input_bar.dart          # Input bar with text field, mic, send button
    └── context_panel.dart           # Bottom sheet with scenario context, hints, tips
```

Also modify:
- `lib/app.dart` — add `/scenario`, `/scenario/chat`, `/scenario/summary` routes + ScenarioProvider
- `lib/features/home/screens/home_screen.dart` — wire ModeCard onTap to navigate to `/scenario`

---

## Task 1: Domain Models

**Files:**
- Create: `lib/features/scenario/models/scenario.dart`
- Create: `lib/features/scenario/models/chat_message.dart`
- Create: `lib/features/scenario/models/assessment.dart`

- [ ] **Step 1: Create Scenario model**

```dart
// lib/features/scenario/models/scenario.dart
class Scenario {
  final String id;
  final String title;
  final String emoji;
  final String category;
  final String level;
  final String description;
  final List<String> prompts;
  final List<String> hints;
  final List<String> tips;

  const Scenario({
    required this.id,
    required this.title,
    required this.emoji,
    required this.category,
    required this.level,
    required this.description,
    required this.prompts,
    required this.hints,
    required this.tips,
  });
}
```

- [ ] **Step 2: Create ChatMessage model**

```dart
// lib/features/scenario/models/chat_message.dart
enum MessageType { system, ai, user, assessment }

class ChatMessage {
  final String id;
  final MessageType type;
  final String text;
  final DateTime timestamp;
  final Assessment? assessment;
  final String? savedPhrase;

  const ChatMessage({
    required this.id,
    required this.type,
    required this.text,
    required this.timestamp,
    this.assessment,
    this.savedPhrase,
  });
}
```

- [ ] **Step 3: Create Assessment model**

```dart
// lib/features/scenario/models/assessment.dart
class Assessment {
  final int score;
  final String grade;
  final String detectedTone;
  final String feedback;
  final Map<String, double> metrics; // e.g. {"Accuracy": 0.85, "Naturalness": 0.90}
  final String? betterWay;
  final List<ToneVariation> toneVariations;

  const Assessment({
    required this.score,
    required this.grade,
    required this.detectedTone,
    required this.feedback,
    required this.metrics,
    this.betterWay,
    this.toneVariations = const [],
  });
}

class ToneVariation {
  final String label;
  final String emoji;
  final String text;
  final bool isClosest;

  const ToneVariation({
    required this.label,
    required this.emoji,
    required this.text,
    this.isClosest = false,
  });
}
```

- [ ] **Step 4: Commit**

```bash
git add lib/features/scenario/models/
git commit -m "feat(scenario): add domain models — Scenario, ChatMessage, Assessment"
```

---

## Task 2: Scenario Catalog (Mock Data)

**Files:**
- Create: `lib/features/scenario/data/scenario_catalog.dart`

- [ ] **Step 1: Create scenario catalog with 4+ scenarios**

```dart
// lib/features/scenario/data/scenario_catalog.dart
import '../models/scenario.dart';

final List<Scenario> scenarioCatalog = [
  Scenario(
    id: 'office-apology',
    title: 'Office Apology',
    emoji: '💼',
    category: 'Business',
    level: 'Beginner',
    description: 'Apologize to a colleague for spilling coffee on their report',
    prompts: [
      'Xin lỗi, tôi không để ý và vô tình làm đổ cà phê lên báo cáo của bạn.',
      'Tôi sẽ in lại cho bạn ngay. Xin lỗi thật sự.',
      'Lần sau tôi sẽ cẩn thận hơn. Cảm ơn bạn đã thông cảm.',
    ],
    hints: [
      'Use an exclamation to show genuine surprise at your mistake',
      'Offer to fix the situation — this is culturally expected',
      'End with a promise to be more careful',
    ],
    tips: [
      'Use formal-friendly register',
      'Show empathy and accountability',
      'Offer a concrete solution',
    ],
  ),
  Scenario(
    id: 'hotel-checkin',
    title: 'Hotel Check-in',
    emoji: '🏨',
    category: 'Travel',
    level: 'Beginner',
    description: 'Check into a hotel and ask about amenities',
    prompts: [
      'Xin chào, tôi đã đặt phòng trước. Tên tôi là Luu.',
      'Phòng có wifi không? Mật khẩu là gì?',
      'Cảm ơn. Nhà hàng mở cửa lúc mấy giờ?',
    ],
    hints: [
      'Start with a polite greeting',
      'State your reservation clearly',
      'Ask about amenities naturally',
    ],
    tips: [
      'Be polite but direct',
      'Use question forms correctly',
      'Thank the staff',
    ],
  ),
  Scenario(
    id: 'restaurant-order',
    title: 'Restaurant Order',
    emoji: '🍽️',
    category: 'Daily Life',
    level: 'Beginner',
    description: 'Order food at a restaurant and handle dietary requests',
    prompts: [
      'Cho tôi xem menu được không?',
      'Tôi bị dị ứng đậu phộng. Món này có đậu phộng không?',
      'Cho tôi một ly nước cam và món cá hồi nướng.',
    ],
    hints: [
      'Use polite request forms',
      'State dietary needs clearly and early',
      'Be specific with your order',
    ],
    tips: [
      'Politely get attention first',
      'Mention allergies before ordering',
      'Confirm your order at the end',
    ],
  ),
  Scenario(
    id: 'job-interview',
    title: 'Job Interview',
    emoji: '💼',
    category: 'Business',
    level: 'Intermediate',
    description: 'Answer common interview questions professionally',
    prompts: [
      'Hãy giới thiệu về bản thân bạn.',
      'Tại sao bạn muốn làm việc ở công ty chúng tôi?',
      'Điểm mạnh và điểm yếu của bạn là gì?',
    ],
    hints: [
      'Structure your answer: past → present → future',
      'Research the company beforehand',
      'Be honest but strategic about weaknesses',
    ],
    tips: [
      'Keep answers concise (1-2 minutes)',
      'Use professional vocabulary',
      'Show enthusiasm without being excessive',
    ],
  ),
];
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/scenario/data/
git commit -m "feat(scenario): add scenario catalog with 4 mock scenarios"
```

---

## Task 3: ScenarioProvider (State Management)

**Files:**
- Create: `lib/features/scenario/providers/scenario_provider.dart`

- [ ] **Step 1: Create ScenarioProvider**

```dart
// lib/features/scenario/providers/scenario_provider.dart
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/scenario.dart';
import '../models/chat_message.dart';
import '../models/assessment.dart';
import '../data/scenario_catalog.dart';

class ScenarioProvider extends ChangeNotifier {
  final _uuid = const Uuid();

  Scenario? _currentScenario;
  final List<ChatMessage> _messages = [];
  int _currentPromptIndex = 0;
  bool _isAiTyping = false;
  int _hintsRevealed = 0;
  DateTime? _sessionStartTime;

  Scenario? get currentScenario => _currentScenario;
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  int get currentPromptIndex => _currentPromptIndex;
  bool get isAiTyping => _isAiTyping;
  int get hintsRevealed => _hintsRevealed;
  double get progress => _currentScenario == null
      ? 0
      : (_currentPromptIndex + 1) / _currentScenario!.prompts.length;
  bool get isSessionComplete =>
      _currentScenario != null &&
      _currentPromptIndex >= _currentScenario!.prompts.length;
  String get currentPrompt =>
      _currentScenario?.prompts[_currentPromptIndex] ?? '';

  void startSession(Scenario scenario) {
    _currentScenario = scenario;
    _messages.clear();
    _currentPromptIndex = 0;
    _hintsRevealed = 0;
    _sessionStartTime = DateTime.now();

    _messages.add(ChatMessage(
      id: _uuid.v4(),
      type: MessageType.ai,
      text:
          "Great! Let's practice this scenario. I'll be your colleague. Go ahead and translate the sentence above.",
      timestamp: DateTime.now(),
    ));

    notifyListeners();
  }

  void sendUserMessage(String text) {
    _messages.add(ChatMessage(
      id: _uuid.v4(),
      type: MessageType.user,
      text: text,
      timestamp: DateTime.now(),
    ));
    notifyListeners();

    _simulateAssessment(text);
  }

  void _simulateAssessment(String userText) {
    _isAiTyping = true;
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 1200), () {
      final assessment = Assessment(
        score: 8,
        grade: 'Excellent',
        detectedTone: 'Friendly',
        feedback:
            'Natural translation! You captured the tone well. Consider offering to fix the situation.',
        metrics: {
          'Accuracy': 0.85,
          'Naturalness': 0.90,
          'Complexity': 0.70,
        },
        betterWay: userText.length < 80
            ? '$userText Let me reprint it for you right away.'
            : null,
        toneVariations: [
          ToneVariation(
            label: 'Formal',
            emoji: '🏛️',
            text:
                '"I sincerely apologize for my carelessness; I have inadvertently spilled coffee on your report."',
          ),
          ToneVariation(
            label: 'Neutral',
            emoji: '💬',
            text:
                '"Oh gosh, I\'m so sorry! I wasn\'t looking where I was going and spilled coffee on your report."',
            isClosest: true,
          ),
          ToneVariation(
            label: 'Friendly',
            emoji: '😊',
            text:
                '"Oh no! I\'m so sorry—I was being so clumsy and got coffee all over your report!"',
          ),
          ToneVariation(
            label: 'Casual',
            emoji: '☕',
            text:
                '"Oops, my bad! I totally spaced out and spilled my drink on your papers."',
          ),
        ],
      );

      _messages.add(ChatMessage(
        id: _uuid.v4(),
        type: MessageType.assessment,
        text: '',
        timestamp: DateTime.now(),
        assessment: assessment,
      ));

      _isAiTyping = false;
      notifyListeners();
    });
  }

  void advanceToNextPrompt() {
    if (_currentScenario == null) return;
    if (_currentPromptIndex < _currentScenario!.prompts.length - 1) {
      _currentPromptIndex++;
      _messages.add(ChatMessage(
        id: _uuid.v4(),
        type: MessageType.ai,
        text: 'Great work! Now try this next one.',
        timestamp: DateTime.now(),
      ));
      notifyListeners();
    }
  }

  void revealNextHint() {
    if (_currentScenario == null) return;
    if (_hintsRevealed < _currentScenario!.hints.length) {
      _hintsRevealed++;
      notifyListeners();
    }
  }

  int get sessionDurationMinutes {
    if (_sessionStartTime == null) return 0;
    return DateTime.now().difference(_sessionStartTime!).inMinutes;
  }

  int get totalTurns =>
      _messages.where((m) => m.type == MessageType.user).length;

  double get averageScore {
    final assessments = _messages
        .where((m) => m.type == MessageType.assessment && m.assessment != null)
        .map((m) => m.assessment!.score)
        .toList();
    if (assessments.isEmpty) return 0;
    return assessments.reduce((a, b) => a + b) / assessments.length;
  }

  void endSession() {
    // Session is complete — navigate to summary handled by screen
  }

  void reset() {
    _currentScenario = null;
    _messages.clear();
    _currentPromptIndex = 0;
    _isAiTyping = false;
    _hintsRevealed = 0;
    _sessionStartTime = null;
    notifyListeners();
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/scenario/providers/
git commit -m "feat(scenario): add ScenarioProvider with session state management"
```

---

## Task 4: Reusable Chat Widgets (ScoreCircle, MetricBar)

**Files:**
- Create: `lib/features/scenario/widgets/score_circle.dart`
- Create: `lib/features/scenario/widgets/metric_bar.dart`

- [ ] **Step 1: Create ScoreCircle widget**

Animated circle with score number inside. From mockup: 64x64 default, border 3px, Fredoka font, pop animation.

```dart
// lib/features/scenario/widgets/score_circle.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class ScoreCircle extends StatefulWidget {
  final int score;
  final int maxScore;
  final double size;
  final Color color;

  const ScoreCircle({
    super.key,
    required this.score,
    this.maxScore = 10,
    this.size = 64,
    this.color = AppColors.success,
  });

  @override
  State<ScoreCircle> createState() => _ScoreCircleState();
}

class _ScoreCircleState extends State<ScoreCircle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnim,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.color.withValues(alpha: 0.12),
          border: Border.all(
            color: widget.color,
            width: widget.size > 70 ? 4 : 3,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${widget.score}',
              style: GoogleFonts.fredoka(
                fontSize: widget.size * 0.375,
                fontWeight: FontWeight.w800,
                color: widget.color,
                height: 1,
              ),
            ),
            Text(
              '/${widget.maxScore}',
              style: GoogleFonts.fredoka(
                fontSize: widget.size * 0.14,
                fontWeight: FontWeight.w600,
                color: widget.color.withValues(alpha: 0.7),
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Create MetricBar widget**

From mockup: pill shape, label + progress bar + value text.

```dart
// lib/features/scenario/widgets/metric_bar.dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_radius.dart';

class MetricBar extends StatelessWidget {
  final String label;
  final double value; // 0.0 to 1.0
  final String displayValue;
  final Color color;

  const MetricBar({
    super.key,
    required this.label,
    required this.value,
    required this.displayValue,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.clayWhite,
        borderRadius: AppRadius.mdBorder,
        border: Border.all(color: AppColors.clayBorder, width: 1.5),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 68,
            child: Text(
              label,
              style: AppTypography.caption.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.warmDark,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.clayBeige,
                borderRadius: BorderRadius.circular(3),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: value.clamp(0, 1),
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 32,
            child: Text(
              displayValue,
              textAlign: TextAlign.right,
              style: AppTypography.caption.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 3: Commit**

```bash
git add lib/features/scenario/widgets/score_circle.dart lib/features/scenario/widgets/metric_bar.dart
git commit -m "feat(scenario): add ScoreCircle and MetricBar reusable widgets"
```

---

## Task 5: Chat Bubble Widgets

**Files:**
- Create: `lib/features/scenario/widgets/chat_bubble_user.dart`
- Create: `lib/features/scenario/widgets/chat_bubble_ai.dart`

- [ ] **Step 1: Create ChatBubbleUser**

From mockup: right-aligned, teal bg, clay shadow 3px, rounded (28px top, 4px bottom-right), listen tag + pronunciation tag.

```dart
// lib/features/scenario/widgets/chat_bubble_user.dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_radius.dart';

class ChatBubbleUser extends StatelessWidget {
  final String text;

  const ChatBubbleUser({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.teal,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.teal.withValues(alpha: 0.3),
                    offset: const Offset(3, 3),
                  ),
                ],
              ),
              child: Text(
                text,
                style: AppTypography.bodySm.copyWith(
                  color: Colors.white,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _tag('🔊 Listen', AppColors.clayBeige, AppColors.warmMuted),
                const SizedBox(width: 6),
                _tag('✓ Good pron.', AppColors.success.withValues(alpha: 0.15),
                    AppColors.success),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _tag(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.fullBorder,
      ),
      child: Text(
        text,
        style: AppTypography.caption.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Create ChatBubbleAi**

From mockup: left-aligned, avatar + name + white card, border 1.5px clayBorder, rounded (4px top-left, 28px rest).

```dart
// lib/features/scenario/widgets/chat_bubble_ai.dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/constants/cloudinary_assets.dart';
import '../../../shared/widgets/cloud_image.dart';

class ChatBubbleAi extends StatelessWidget {
  final String text;
  final String senderName;

  const ChatBubbleAi({
    super.key,
    required this.text,
    this.senderName = 'Aura Coach',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.clayBorder, width: 2),
            boxShadow: AppShadows.card,
          ),
          child: ClipOval(
            child: CloudImage(url: CloudinaryAssets.chatbot, size: 32),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                senderName,
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.teal,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.clayWhite,
                  border: Border.all(color: AppColors.clayBorder, width: 1.5),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(28),
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                  boxShadow: AppShadows.card,
                ),
                child: Text(
                  text,
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.warmDark,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 3: Commit**

```bash
git add lib/features/scenario/widgets/chat_bubble_user.dart lib/features/scenario/widgets/chat_bubble_ai.dart
git commit -m "feat(scenario): add ChatBubbleUser and ChatBubbleAi widgets"
```

---

## Task 6: TranslatePrompt + InlineAssessment Widgets

**Files:**
- Create: `lib/features/scenario/widgets/translate_prompt.dart`
- Create: `lib/features/scenario/widgets/inline_assessment.dart`

- [ ] **Step 1: Create TranslatePrompt**

From mockup: gradient bg (teal→gold), bottom border 2.5px teal, badge "🌐 Scenario", translate/hint action buttons, bold quote text with left border, context line with location icon.

```dart
// lib/features/scenario/widgets/translate_prompt.dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';

class TranslatePrompt extends StatelessWidget {
  final String promptText;
  final String location;
  final String contextDescription;
  final VoidCallback? onTranslate;
  final VoidCallback? onHint;

  const TranslatePrompt({
    super.key,
    required this.promptText,
    required this.location,
    required this.contextDescription,
    this.onTranslate,
    this.onHint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.teal.withValues(alpha: 0.12),
            AppColors.gold.withValues(alpha: 0.08),
          ],
        ),
        border: Border(
          bottom: BorderSide(color: AppColors.teal, width: 2.5),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.teal,
                  borderRadius: AppRadius.fullBorder,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.teal.withValues(alpha: 0.4),
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
                child: Text(
                  '🌐 Scenario',
                  style: AppTypography.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onTranslate,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.teal,
                    borderRadius: AppRadius.fullBorder,
                    border: Border.all(color: AppColors.teal),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.teal.withValues(alpha: 0.3),
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    '🔄 Translate',
                    style: AppTypography.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: onHint,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.1),
                    borderRadius: AppRadius.fullBorder,
                    border: Border.all(
                      color: AppColors.gold.withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                  child: Text(
                    '💡 Hint',
                    style: AppTypography.caption.copyWith(
                      color: const Color(0xFF9A7B3D),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.clayWhite,
              border: Border.all(color: AppColors.clayBorder, width: 2),
              borderRadius: AppRadius.mdBorder,
              boxShadow: AppShadows.card,
            ),
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: AppColors.teal, width: 4),
                ),
              ),
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                promptText,
                style: AppTypography.bodyMd.copyWith(
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Nunito',
                  fontSize: 17,
                  height: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.gold.withValues(alpha: 0.15),
                ),
                child: const Center(
                  child: Text('📍', style: TextStyle(fontSize: 12)),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                location,
                style: AppTypography.labelSm.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.warmDark,
                  fontSize: 12,
                ),
              ),
              Text(
                ' — $contextDescription',
                style: AppTypography.caption.copyWith(
                  color: AppColors.warmMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Create InlineAssessment**

From mockup: assess-card with shadow-lifted, score circle + badges + feedback, metric bars, tip box.

```dart
// lib/features/scenario/widgets/inline_assessment.dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/constants/cloudinary_assets.dart';
import '../../../shared/widgets/cloud_image.dart';
import '../models/assessment.dart';
import 'score_circle.dart';
import 'metric_bar.dart';

class InlineAssessment extends StatelessWidget {
  final Assessment assessment;
  final VoidCallback? onContinue;

  const InlineAssessment({
    super.key,
    required this.assessment,
    this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.clayBorder, width: 2),
            boxShadow: AppShadows.card,
          ),
          child: ClipOval(
            child: CloudImage(url: CloudinaryAssets.chatbot, size: 32),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Aura Coach',
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.teal,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.clayWhite,
                  border: Border.all(color: AppColors.clayBorder, width: 2),
                  borderRadius: AppRadius.lgBorder,
                  boxShadow: AppShadows.lifted,
                ),
                child: Column(
                  children: [
                    _buildScoreSection(),
                    _divider(),
                    _buildMetricsSection(),
                    if (assessment.betterWay != null) ...[
                      _divider(),
                      _buildTipSection(),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScoreSection() {
    final gradeColor =
        assessment.score >= 7 ? AppColors.success : AppColors.gold;
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          ScoreCircle(score: assessment.score, color: gradeColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 4,
                  children: [
                    _badge(assessment.grade, gradeColor),
                    _badge(assessment.detectedTone, AppColors.warmMuted,
                        bgColor: AppColors.clayBeige,
                        borderColor: AppColors.clayBorder),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  assessment.feedback,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.warmMuted,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsSection() {
    final metricColors = [AppColors.teal, AppColors.success, AppColors.purple];
    final entries = assessment.metrics.entries.toList();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        children: List.generate(entries.length, (i) {
          final e = entries[i];
          return Padding(
            padding: EdgeInsets.only(bottom: i < entries.length - 1 ? 6 : 0),
            child: MetricBar(
              label: e.key,
              value: e.value,
              displayValue: '${(e.value * 100).round()}%',
              color: metricColors[i % metricColors.length],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTipSection() {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.gold.withValues(alpha: 0.08),
          borderRadius: AppRadius.mdBorder,
          border: Border.all(
            color: AppColors.gold.withValues(alpha: 0.25),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('💡', style: TextStyle(fontSize: 13)),
                const SizedBox(width: 4),
                Text(
                  'BETTER WAY',
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF9A7B3D),
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              assessment.betterWay!,
              style: AppTypography.caption.copyWith(
                fontSize: 12,
                color: AppColors.warmDark,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String text, Color color,
      {Color? bgColor, Color? borderColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor ?? color.withValues(alpha: 0.1),
        borderRadius: AppRadius.fullBorder,
        border: Border.all(
          color: borderColor ?? color.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Text(
        text,
        style: AppTypography.caption.copyWith(
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _divider() {
    return Container(
      height: 2,
      color: AppColors.clayBorder,
    );
  }
}
```

- [ ] **Step 3: Commit**

```bash
git add lib/features/scenario/widgets/translate_prompt.dart lib/features/scenario/widgets/inline_assessment.dart
git commit -m "feat(scenario): add TranslatePrompt and InlineAssessment widgets"
```

---

## Task 7: ScenarioAppBar + ChatInputBar + ContextPanel

**Files:**
- Create: `lib/features/scenario/widgets/scenario_app_bar.dart`
- Create: `lib/features/scenario/widgets/chat_input_bar.dart`
- Create: `lib/features/scenario/widgets/context_panel.dart`

- [ ] **Step 1: Create ScenarioAppBar**

From mockup: back button, title (teal, Nunito 15px w700), subtitle (emoji + category · level), action icons (💡🔊⋯), progress bar (3px, teal fill).

```dart
// lib/features/scenario/widgets/scenario_app_bar.dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class ScenarioAppBar extends StatelessWidget {
  final String title;
  final String emoji;
  final String category;
  final String level;
  final double progress;
  final VoidCallback? onBack;
  final VoidCallback? onHint;
  final VoidCallback? onMore;

  const ScenarioAppBar({
    super.key,
    required this.title,
    required this.emoji,
    required this.category,
    required this.level,
    required this.progress,
    this.onBack,
    this.onHint,
    this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      color: AppColors.cream,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onBack,
                child: Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  child: Text(
                    '‹',
                    style: AppTypography.h1.copyWith(fontSize: 22),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.bodySm.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.teal,
                        fontFamily: 'Nunito',
                      ),
                    ),
                    Text(
                      '$emoji $category · $level',
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
              _actionIcon('💡', onHint),
              _actionIcon('🔊', null),
              _actionIcon('⋯', onMore),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 3,
              backgroundColor: AppColors.clayBeige,
              valueColor: AlwaysStoppedAnimation(AppColors.teal),
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _actionIcon(String emoji, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 32,
        height: 32,
        child: Center(
          child: Text(emoji, style: const TextStyle(fontSize: 14)),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Create ChatInputBar**

From mockup: border-top 2px clayBorder, bg clayWhite, pill-shaped input row, mic button (32px circle, light red bg), send button (40px circle, teal bg, white arrow).

```dart
// lib/features/scenario/widgets/chat_input_bar.dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_radius.dart';

class ChatInputBar extends StatefulWidget {
  final ValueChanged<String> onSend;
  final String placeholder;

  const ChatInputBar({
    super.key,
    required this.onSend,
    this.placeholder = 'Type your translation...',
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final has = _controller.text.trim().isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.clayWhite,
        border: Border(
          top: BorderSide(color: AppColors.clayBorder, width: 2),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.clayWhite,
          border: Border.all(color: AppColors.clayBorder, width: 2),
          borderRadius: AppRadius.fullBorder,
        ),
        padding: const EdgeInsets.fromLTRB(18, 6, 6, 6),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                style: AppTypography.bodySm,
                decoration: InputDecoration(
                  hintText: widget.placeholder,
                  hintStyle: AppTypography.bodySm.copyWith(
                    color: AppColors.warmLight,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.error.withValues(alpha: 0.1),
              ),
              child: const Center(
                child: Text('🎤', style: TextStyle(fontSize: 12)),
              ),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: _hasText ? _send : null,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _hasText ? AppColors.teal : AppColors.clayBorder,
                ),
                child: const Center(
                  child: Text('➤',
                      style: TextStyle(fontSize: 14, color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Create ContextPanel**

From mockup: bottom sheet with drag handle, scenario info card, hints with left border, tips card.

```dart
// lib/features/scenario/widgets/context_panel.dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../models/scenario.dart';

class ContextPanel extends StatelessWidget {
  final Scenario scenario;
  final int hintsRevealed;
  final VoidCallback? onRevealHint;

  const ContextPanel({
    super.key,
    required this.scenario,
    required this.hintsRevealed,
    this.onRevealHint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      decoration: BoxDecoration(
        color: AppColors.clayWhite,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(color: AppColors.clayBorder, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.clayBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          Flexible(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shrinkWrap: true,
              children: [
                Text(
                  'Context Details',
                  style: AppTypography.h2.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 12),
                _infoCard(),
                const SizedBox(height: 10),
                _hintsCard(),
                const SizedBox(height: 10),
                _tipsCard(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.clayWhite,
        border: Border.all(color: AppColors.clayBorder, width: 2),
        borderRadius: AppRadius.lgBorder,
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CURRENT SCENARIO',
            style: AppTypography.caption.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.teal,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            scenario.description,
            style: AppTypography.bodySm.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'Level: ${scenario.level} · Topic: ${scenario.category}',
            style: AppTypography.caption.copyWith(color: AppColors.warmMuted),
          ),
        ],
      ),
    );
  }

  Widget _hintsCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.clayWhite,
        border: Border.all(color: AppColors.clayBorder, width: 2),
        borderRadius: AppRadius.lgBorder,
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💡', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(
                'Hints ($hintsRevealed/${scenario.hints.length})',
                style: AppTypography.labelSm.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF9A7B3D),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...List.generate(hintsRevealed, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Container(
                padding: const EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: AppColors.teal, width: 3),
                  ),
                ),
                child: Text(
                  scenario.hints[i],
                  style: AppTypography.caption.copyWith(
                    color: AppColors.warmMuted,
                    fontSize: 12,
                  ),
                ),
              ),
            );
          }),
          if (hintsRevealed < scenario.hints.length)
            GestureDetector(
              onTap: onRevealHint,
              child: Text(
                '▶ Reveal next hint',
                style: AppTypography.caption.copyWith(
                  color: AppColors.teal,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _tipsCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.clayWhite,
        border: Border.all(color: AppColors.clayBorder, width: 2),
        borderRadius: AppRadius.lgBorder,
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🎯', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(
                'Tips for Success',
                style: AppTypography.labelSm.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF9A7B3D),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ...scenario.tips.map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '• $tip',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.warmMuted,
                    fontSize: 12,
                    height: 1.6,
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Commit**

```bash
git add lib/features/scenario/widgets/scenario_app_bar.dart lib/features/scenario/widgets/chat_input_bar.dart lib/features/scenario/widgets/context_panel.dart
git commit -m "feat(scenario): add ScenarioAppBar, ChatInputBar, ContextPanel widgets"
```

---

## Task 8: Scenario Select Screen

**Files:**
- Create: `lib/features/scenario/screens/scenario_select_screen.dart`

- [ ] **Step 1: Create ScenarioSelectScreen**

From mockup: app bar "Scenario Coach" (teal), scrollable list of scenario cards with emoji icon, title, level badge, description. Each card: clayWhite bg, 2px clayBorder, r-lg, soft shadow, 48x48 emoji icon box.

```dart
// lib/features/scenario/screens/scenario_select_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../data/scenario_catalog.dart';
import '../models/scenario.dart';
import '../providers/scenario_provider.dart';

class ScenarioSelectScreen extends StatelessWidget {
  const ScenarioSelectScreen({super.key});

  Color _levelColor(String level) {
    switch (level.toLowerCase()) {
      case 'beginner':
        return AppColors.success;
      case 'intermediate':
        return const Color(0xFF9A7B3D);
      case 'advanced':
        return AppColors.error;
      default:
        return AppColors.warmMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.cream,
                border: Border(
                  bottom: BorderSide(color: AppColors.clayBorder, width: 2),
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      child: Text('‹',
                          style: AppTypography.h1.copyWith(fontSize: 22)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Scenario Coach',
                    style: AppTypography.bodyMd.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Nunito',
                      color: AppColors.teal,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(14),
                itemCount: scenarioCatalog.length,
                itemBuilder: (context, index) {
                  final scenario = scenarioCatalog[index];
                  final levelColor = _levelColor(scenario.level);
                  return GestureDetector(
                    onTap: () {
                      context.read<ScenarioProvider>().startSession(scenario);
                      context.push('/scenario/chat');
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.clayWhite,
                        border: Border.all(
                            color: AppColors.clayBorder, width: 2),
                        borderRadius: AppRadius.lgBorder,
                        boxShadow: AppShadows.soft,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: levelColor.withValues(alpha: 0.15),
                              borderRadius: AppRadius.mdBorder,
                            ),
                            child: Center(
                              child: Text(scenario.emoji,
                                  style: const TextStyle(fontSize: 28)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      scenario.title,
                                      style: AppTypography.bodySm.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: levelColor
                                            .withValues(alpha: 0.1),
                                        borderRadius: AppRadius.fullBorder,
                                        border: Border.all(
                                          color: levelColor
                                              .withValues(alpha: 0.3),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Text(
                                        scenario.level,
                                        style:
                                            AppTypography.caption.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: levelColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  scenario.description,
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.warmMuted,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/scenario/screens/scenario_select_screen.dart
git commit -m "feat(scenario): add ScenarioSelectScreen with scenario list"
```

---

## Task 9: Scenario Chat Screen

**Files:**
- Create: `lib/features/scenario/screens/scenario_chat_screen.dart`

- [ ] **Step 1: Create ScenarioChatScreen**

Assembles: ScenarioAppBar + TranslatePrompt + chat ListView + ChatInputBar. Typing indicator with 3 animated dots.

```dart
// lib/features/scenario/screens/scenario_chat_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_shadows.dart';
import '../providers/scenario_provider.dart';
import '../models/chat_message.dart';
import '../widgets/scenario_app_bar.dart';
import '../widgets/translate_prompt.dart';
import '../widgets/chat_bubble_user.dart';
import '../widgets/chat_bubble_ai.dart';
import '../widgets/inline_assessment.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/context_panel.dart';

class ScenarioChatScreen extends StatelessWidget {
  const ScenarioChatScreen({super.key});

  void _showContextPanel(BuildContext context) {
    final provider = context.read<ScenarioProvider>();
    if (provider.currentScenario == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: provider,
        child: Consumer<ScenarioProvider>(
          builder: (_, p, __) => ContextPanel(
            scenario: p.currentScenario!,
            hintsRevealed: p.hintsRevealed,
            onRevealHint: () => p.revealNextHint(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        bottom: false,
        child: Consumer<ScenarioProvider>(
          builder: (context, provider, _) {
            final scenario = provider.currentScenario;
            if (scenario == null) {
              return const Center(child: Text('No scenario selected'));
            }

            return Column(
              children: [
                ScenarioAppBar(
                  title: scenario.title,
                  emoji: scenario.emoji,
                  category: scenario.category,
                  level: scenario.level,
                  progress: provider.progress,
                  onBack: () => context.pop(),
                  onHint: () => _showContextPanel(context),
                  onMore: () => _showContextPanel(context),
                ),
                if (!provider.isSessionComplete)
                  TranslatePrompt(
                    promptText: provider.currentPrompt,
                    location: scenario.category,
                    contextDescription: scenario.description,
                    onHint: () => _showContextPanel(context),
                  ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    itemCount: provider.messages.length +
                        (provider.isAiTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == provider.messages.length &&
                          provider.isAiTyping) {
                        return _TypingIndicator();
                      }
                      final msg = provider.messages[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _buildMessage(msg, provider),
                      );
                    },
                  ),
                ),
                SafeArea(
                  top: false,
                  child: ChatInputBar(
                    onSend: (text) {
                      provider.sendUserMessage(text);
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMessage(ChatMessage msg, ScenarioProvider provider) {
    switch (msg.type) {
      case MessageType.ai:
      case MessageType.system:
        return ChatBubbleAi(text: msg.text);
      case MessageType.user:
        return ChatBubbleUser(text: msg.text);
      case MessageType.assessment:
        return InlineAssessment(
          assessment: msg.assessment!,
          onContinue: () => provider.advanceToNextPrompt(),
        );
    }
  }
}

class _TypingIndicator extends StatefulWidget {
  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 46),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.clayWhite,
            border: Border.all(color: AppColors.clayBorder, width: 1.5),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(28),
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
            boxShadow: AppShadows.card,
          ),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (_, __) => Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                final delay = i * 0.2;
                final t = (_controller.value - delay).clamp(0.0, 1.0);
                final y = t < 0.3
                    ? -6 * (t / 0.3)
                    : t < 0.6
                        ? -6 * (1 - (t - 0.3) / 0.3)
                        : 0.0;
                return Container(
                  margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
                  child: Transform.translate(
                    offset: Offset(0, y),
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.clayShadow
                            .withValues(alpha: y < -2 ? 1 : 0.4),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/scenario/screens/scenario_chat_screen.dart
git commit -m "feat(scenario): add ScenarioChatScreen with full chat flow"
```

---

## Task 10: Session Summary Screen

**Files:**
- Create: `lib/features/scenario/screens/session_summary_screen.dart`

- [ ] **Step 1: Create SessionSummaryScreen**

From mockup: celebration emoji, "Session Complete!" Fredoka 24px, scenario subtitle, summary card with 2x3 stat grid, streak card, daily progress bar, "Next Scenario" teal CTA + "Back to Home" outline button.

```dart
// lib/features/scenario/screens/session_summary_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../providers/scenario_provider.dart';

class SessionSummaryScreen extends StatelessWidget {
  const SessionSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Consumer<ScenarioProvider>(
          builder: (context, provider, _) {
            return Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          provider.reset();
                          context.go('/home');
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          alignment: Alignment.center,
                          child: Text('‹',
                              style: AppTypography.h1.copyWith(fontSize: 22)),
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          provider.reset();
                          context.go('/home');
                        },
                        child: Text(
                          'Done',
                          style: AppTypography.bodySm.copyWith(
                            color: AppColors.warmMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      const SizedBox(height: 8),
                      const Center(
                        child:
                            Text('🎉', style: TextStyle(fontSize: 56)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Session Complete!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.fredoka(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.warmDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${provider.currentScenario?.title ?? ''} · ${provider.currentScenario?.level ?? ''}',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.warmMuted,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildSummaryCard(provider),
                      const SizedBox(height: 12),
                      _buildStreakCard(),
                      const SizedBox(height: 12),
                      _buildProgressCard(),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          provider.reset();
                          context.go('/scenario');
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.teal,
                            borderRadius: AppRadius.xlBorder,
                            boxShadow: AppShadows.clay,
                          ),
                          child: Text(
                            'Next Scenario ▶',
                            textAlign: TextAlign.center,
                            style: AppTypography.button.copyWith(
                              fontFamily: 'Nunito',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          provider.reset();
                          context.go('/home');
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.clayWhite,
                            borderRadius: AppRadius.xlBorder,
                            border: Border.all(
                                color: AppColors.clayBorder, width: 2),
                          ),
                          child: Text(
                            'Back to Home',
                            textAlign: TextAlign.center,
                            style: AppTypography.bodySm.copyWith(
                              color: AppColors.warmMuted,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Nunito',
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSummaryCard(ScenarioProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.teal.withValues(alpha: 0.08),
            AppColors.purple.withValues(alpha: 0.08),
          ],
        ),
        border: Border.all(color: AppColors.clayBorder, width: 2),
        borderRadius: AppRadius.lgBorder,
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        children: [
          Row(
            children: [
              _stat('${provider.averageScore.toStringAsFixed(1)}', 'Avg Score',
                  AppColors.teal),
              const SizedBox(width: 8),
              _stat('${provider.totalTurns}', 'Turns', AppColors.purple),
              const SizedBox(width: 8),
              _stat('0', 'Words Saved', AppColors.gold),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _stat('${provider.sessionDurationMinutes}m', 'Duration',
                  AppColors.success),
              const SizedBox(width: 8),
              _stat('92%', 'Grammar', AppColors.formalTone),
              const SizedBox(width: 8),
              _stat('88%', 'Fluency', AppColors.teal),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.clayWhite,
          border: Border.all(color: AppColors.clayBorder, width: 1.5),
          borderRadius: AppRadius.mdBorder,
          boxShadow: AppShadows.card,
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.fredoka(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTypography.caption.copyWith(fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.clayWhite,
        border: Border.all(color: AppColors.clayBorder, width: 2),
        borderRadius: AppRadius.lgBorder,
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '1 Day Streak!',
                  style: AppTypography.bodySm.copyWith(
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Nunito',
                    fontSize: 15,
                  ),
                ),
                Text(
                  'Keep it up — you\'re on fire!',
                  style: AppTypography.caption.copyWith(
                      color: AppColors.warmMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          Text('+1',
              style: AppTypography.bodySm
                  .copyWith(color: AppColors.warmLight, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildProgressCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.clayWhite,
        border: Border.all(color: AppColors.clayBorder, width: 2),
        borderRadius: AppRadius.lgBorder,
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          const Text('⭐', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Progress',
                  style: AppTypography.bodySm.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.clayBeige,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: 0.2,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.teal, AppColors.purple],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '1/5 scenarios today',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.warmMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/scenario/screens/session_summary_screen.dart
git commit -m "feat(scenario): add SessionSummaryScreen with stats and navigation"
```

---

## Task 11: Wire Routes + Provider + Home Navigation

**Files:**
- Modify: `lib/app.dart`
- Modify: `lib/features/home/screens/home_screen.dart`

- [ ] **Step 1: Add ScenarioProvider and routes to app.dart**

Add imports at top:
```dart
import 'features/scenario/providers/scenario_provider.dart';
import 'features/scenario/screens/scenario_select_screen.dart';
import 'features/scenario/screens/scenario_chat_screen.dart';
import 'features/scenario/screens/session_summary_screen.dart';
```

Add `_scenarioProvider` field in `_AuraCoachAppState`:
```dart
late final ScenarioProvider _scenarioProvider;
```

Initialize in `initState()` after `_homeProvider`:
```dart
_scenarioProvider = ScenarioProvider();
```

Dispose in `dispose()` before `_router.dispose()`:
```dart
_scenarioProvider.dispose();
```

Add to `providers` list in `MultiProvider`:
```dart
ChangeNotifierProvider<ScenarioProvider>.value(value: _scenarioProvider),
```

Add routes after `/home` route:
```dart
GoRoute(path: '/scenario', builder: (_, __) => const ScenarioSelectScreen()),
GoRoute(path: '/scenario/chat', builder: (_, __) => const ScenarioChatScreen()),
GoRoute(path: '/scenario/summary', builder: (_, __) => const SessionSummaryScreen()),
```

- [ ] **Step 2: Wire ModeCard onTap in home_screen.dart**

In `_buildModePageView`, add `onTap` to the first ModeCard (Scenario Coach, index 0):

```dart
ModeCard(
  // ...existing props...
  onTap: () => context.push('/scenario'),
),
```

The `context` is available from `itemBuilder`. Wrap the method to accept context or use `Builder`.

In `_buildModePageView`, change the signature to accept BuildContext:

Replace `Widget build(BuildContext context)` in `_ModePageView` — since it's already a widget with `build`, just use `context` from `itemBuilder`:

```dart
itemBuilder: (context, modeIndex) {
  // ...
  overviewCard: ModeCard(
    // ...existing props...
    onTap: modeIndex == 0 ? () => context.push('/scenario') : null,
  ),
```

- [ ] **Step 3: Commit**

```bash
git add lib/app.dart lib/features/home/screens/home_screen.dart
git commit -m "feat(scenario): wire routes, provider, and home navigation"
```

---

## Task 12: Final Verification

- [ ] **Step 1: Run Flutter analyze**

```bash
cd /path/to/aura-coach-ai && flutter analyze
```

Expected: no errors (warnings acceptable).

- [ ] **Step 2: Run the app and verify the full flow**

1. Tap "Start Practice →" on Scenario Coach mode card → navigates to `/scenario`
2. Scenario select screen shows 4 scenario cards with correct styling
3. Tap a scenario → navigates to `/scenario/chat`
4. Chat screen shows: ScenarioAppBar + TranslatePrompt + AI greeting
5. Type a message → user bubble appears → typing indicator → assessment card appears
6. Tap 💡 → context panel bottom sheet opens with hints and tips
7. Flow is fully functional with mock data

- [ ] **Step 3: Commit any fixes**

```bash
git add -A && git commit -m "fix(scenario): address analysis warnings and UI polish"
```
