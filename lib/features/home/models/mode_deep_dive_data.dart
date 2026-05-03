import 'package:flutter/material.dart';
import '../../../core/constants/feature_flags.dart';
import '../../../core/theme/app_colors.dart';

class DeepDiveStep {
  final String number;
  final String title;
  final String subtitle;

  const DeepDiveStep({
    required this.number,
    required this.title,
    required this.subtitle,
  });
}

class DeepDiveFeature {
  final String iconId;
  final String title;
  final String description;

  const DeepDiveFeature({
    required this.iconId,
    required this.title,
    required this.description,
  });
}

class TonePreview {
  final String iconId;
  final String label;
  final String example;
  final Color color;

  const TonePreview({
    required this.iconId,
    required this.label,
    required this.example,
    required this.color,
  });
}

class ModeDeepDiveData {
  final String title;
  final String iconUrl;
  final Color accentColor;
  final List<String> tags;
  final String ctaText;
  final String quotaText;
  final List<DeepDiveStep> steps;
  final String featuresSectionTitle;
  final List<DeepDiveFeature> features;
  final List<TonePreview>? tonePreviews;

  const ModeDeepDiveData({
    required this.title,
    required this.iconUrl,
    required this.accentColor,
    required this.tags,
    required this.ctaText,
    required this.quotaText,
    required this.steps,
    this.featuresSectionTitle = 'Key features',
    this.features = const [],
    this.tonePreviews,
  });
}

final List<ModeDeepDiveData> modeDeepDiveList = [
  ModeDeepDiveData(
    title: 'Scenario Coach',
    iconUrl:
        'w_216,h_216,c_fill,q_90/v1774765701/aura-coach-assets/mode-icons/trophy-icon_770c25.webp',
    accentColor: AppColors.teal,
    tags: ['🎯 Roleplay', '💬 4 Tones'],
    ctaText: 'Start Practice',
    quotaText: '5 free sessions / day',
    steps: [
      DeepDiveStep(
          number: '1',
          title: 'Choose a scenario',
          subtitle: 'Hotel, restaurant, interview, meeting...'),
      DeepDiveStep(
          number: '2',
          title: 'Roleplay with AI',
          subtitle: 'Natural conversation that adapts to your level'),
      DeepDiveStep(
          number: '3',
          title: 'Get instant feedback',
          subtitle: 'Score, radar chart & improvement tips'),
    ],
    features: [
      DeepDiveFeature(
          iconId: 'feat_masks',
          title: '20+ Real Scenarios',
          description:
              'Hotel check-in, ordering food, job interviews, business meetings & more'),
      DeepDiveFeature(
          iconId: 'feat_barChart',
          title: 'Performance Radar',
          description:
              'Visual breakdown of grammar, vocabulary, fluency & tone accuracy'),
      DeepDiveFeature(
          iconId: 'feat_target',
          title: '4 Tone Variations',
          description: 'Learn formal, neutral, friendly & casual styles'),
      DeepDiveFeature(
          iconId: 'feat_save',
          title: 'Auto-Save Progress',
          description: 'Resume any session exactly where you left off'),
    ],
  ),
  ModeDeepDiveData(
    title: 'Story Mode',
    iconUrl:
        'w_216,h_216,c_fill,q_90/v1774779261/aura-coach-assets/mode-icons/national-park-icons_628f11.webp',
    accentColor: AppColors.purple,
    tags: ['📖 Narrative', '🎭 Choices'],
    ctaText: 'Begin Story',
    quotaText: '3 free stories / day',
    steps: [
      DeepDiveStep(
          number: '1',
          title: 'Pick a story',
          subtitle: 'Browse by genre, topic & difficulty'),
      DeepDiveStep(
          number: '2',
          title: 'Make choices',
          subtitle: 'Your responses drive the narrative forward'),
      DeepDiveStep(
          number: '3',
          title: 'Learn as you play',
          subtitle: 'Instant assessment after each dialogue turn'),
    ],
    features: [
      DeepDiveFeature(
          iconId: 'feat_openBook',
          title: 'Branching Narratives',
          description:
              'Every choice leads to a different outcome — no two sessions alike'),
      DeepDiveFeature(
          iconId: 'feat_masks',
          title: 'Character Interactions',
          description:
              'Engage with unique AI characters who remember your choices'),
      DeepDiveFeature(
          iconId: 'feat_barChart',
          title: 'Real-time Assessment',
          description: 'Grammar, vocabulary & tone scored after each turn'),
      DeepDiveFeature(
          iconId: 'feat_ribbonBookmark',
          title: 'Save & Resume',
          description: 'Bookmark your story and continue any time'),
    ],
  ),
  // Grammar Coach deep-dive — wins the third slot when its flag is on.
  if (FeatureFlags.grammarCoachEnabled)
    ModeDeepDiveData(
      title: 'Grammar Coach',
      iconUrl:
          'w_216,h_216,c_fill,q_90/v1774766467/aura-coach-assets/mode-icons/tone-translator_327cd6.webp',
      accentColor: AppColors.gold,
      tags: ['📚 A1–C2', '🎯 3 Modes'],
      ctaText: 'Start Drilling',
      quotaText: 'Unlimited practice',
      steps: [
        DeepDiveStep(
            number: '1',
            title: 'Pick a level',
            subtitle: 'A1 → C2 across 55 curated topics'),
        DeepDiveStep(
            number: '2',
            title: 'Pick a structure',
            subtitle: 'Tense, modal, conditional, passive…'),
        DeepDiveStep(
            number: '3',
            title: 'Drill it 3 ways',
            subtitle: 'Translate, fill the blank, transform'),
      ],
      featuresSectionTitle: 'Built for retention',
      features: [
        DeepDiveFeature(
            iconId: 'feat_magnifier',
            title: 'Cambridge + Oxford catalog',
            description:
                'Curated from authoritative grammar references'),
        DeepDiveFeature(
            iconId: 'feat_chartUp',
            title: 'Mastery scoring',
            description:
                'EWMA per topic — see the % delta after each session'),
        DeepDiveFeature(
            iconId: 'feat_brain',
            title: 'AI-graded practice',
            description:
                'Nuanced feedback on translate + transform answers'),
        DeepDiveFeature(
            iconId: 'feat_ribbonBookmark',
            title: 'Save mistakes',
            description: 'One-tap save wrong answers to your Library'),
      ],
    ),
  if (!FeatureFlags.grammarCoachEnabled && FeatureFlags.toneTranslatorEnabled)
    ModeDeepDiveData(
      title: 'Tone Translator',
      iconUrl:
          'w_216,h_216,c_fill,q_90/v1774766467/aura-coach-assets/mode-icons/tone-translator_327cd6.webp',
      accentColor: AppColors.gold,
      tags: ['🎭 4 Tones', '🔊 TTS'],
      ctaText: 'Translate Now',
      quotaText: '10 free translations / day',
    steps: [
      DeepDiveStep(
          number: '1',
          title: 'Type a sentence',
          subtitle: 'Any phrase you want to learn'),
      DeepDiveStep(
          number: '2',
          title: 'See 4 tone variations',
          subtitle: 'Formal, neutral, friendly & casual'),
      DeepDiveStep(
          number: '3',
          title: 'Listen & save',
          subtitle: 'TTS playback + save to your library'),
    ],
    featuresSectionTitle: '4 Tone styles',
    tonePreviews: [
      TonePreview(
          iconId: 'tone_formal',
          label: 'Formal',
          example: '"I would appreciate your assistance..."',
          color: AppColors.formalTone),
      TonePreview(
          iconId: 'tone_neutral',
          label: 'Neutral',
          example: '"Could you help me with this?"',
          color: AppColors.neutralTone),
      TonePreview(
          iconId: 'tone_friendly',
          label: 'Friendly',
          example: '"Hey, mind giving me a hand?"',
          color: AppColors.friendlyTone),
      TonePreview(
          iconId: 'tone_casual',
          label: 'Casual',
          example: '"Yo, can you help real quick?"',
          color: AppColors.casualTone),
    ],
  ),
  ModeDeepDiveData(
    title: 'Vocab Hub',
    iconUrl:
        'w_216,h_216,c_fill,q_90/v1774779311/aura-coach-assets/mode-icons/ringed-planet-icons_bbcaa8.webp',
    accentColor: AppColors.coral,
    tags: ['🔍 Analyze', '🧠 Mind Map', '⚖️ Compare'],
    ctaText: 'Explore Words',
    quotaText: 'Unlimited',
    steps: [],
    featuresSectionTitle: '7 Powerful tools',
    features: [
      DeepDiveFeature(
          iconId: 'feat_magnifier',
          title: 'Word Analysis',
          description:
              'Pronunciation, 3 examples, synonyms & antonyms'),
      DeepDiveFeature(
          iconId: 'feat_describe',
          title: 'Describe Word',
          description:
              'Describe in Vietnamese → get the English word'),
      DeepDiveFeature(
          iconId: 'feat_cards',
          title: 'Flashcards',
          description: 'SM-2 spaced repetition — review at the perfect time'),
      DeepDiveFeature(
          iconId: 'feat_stack',
          title: 'Learning Library',
          description: 'All saved words from every mode in one place'),
      DeepDiveFeature(
          iconId: 'feat_chartUp',
          title: 'Progress Dashboard',
          description: 'Track total, due reviews & mastered at a glance'),
      DeepDiveFeature(
          iconId: 'feat_brain',
          title: 'Mind Maps · Pro',
          description:
              'Visual word relationships — synonyms, antonyms & related'),
      DeepDiveFeature(
          iconId: 'feat_compare',
          title: 'Compare Words',
          description: 'Side-by-side nuance: "affect" vs "effect"'),
    ],
  ),
];
