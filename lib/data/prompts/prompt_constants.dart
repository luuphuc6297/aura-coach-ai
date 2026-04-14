import 'dart:math';

/// CEFR level identifier used across all prompts.
/// Canonical form: 'A1-A2', 'B1-B2', 'C1-C2'.
enum CefrLevel {
  a1a2('A1-A2'),
  b1b2('B1-B2'),
  c1c2('C1-C2');

  final String code;
  const CefrLevel(this.code);

  static CefrLevel fromProficiencyId(String id) {
    switch (id.toLowerCase().trim()) {
      case 'beginner':
      case 'a1':
      case 'a2':
      case 'a1-a2':
      case 'a1 / a2':
        return CefrLevel.a1a2;
      case 'intermediate':
      case 'b1':
      case 'b2':
      case 'b1-b2':
      case 'b1 / b2':
        return CefrLevel.b1b2;
      case 'advanced':
      case 'c1':
      case 'c2':
      case 'c1-c2':
      case 'c1 / c2':
        return CefrLevel.c1c2;
      default:
        return CefrLevel.a1a2;
    }
  }
}

/// Pool of sentence types used to force variation across scenarios.
const List<String> kSentenceTypes = [
  'question',
  'exclamation',
  'complaint',
  'idiomatic expression',
  'request',
  'suggestion',
  'warning',
  'invitation',
  'apology',
  'negotiation',
];

/// Language complexity specification per CEFR level.
const Map<CefrLevel, String> kLevelSpecs = {
  CefrLevel.a1a2:
      'Sentence Length: 5-8 words. Vocabulary: High frequency. Focus: Basic needs, simple questions.',
  CefrLevel.b1b2:
      'Sentence Length: 12-18 words. Vocabulary: Idioms, phrasal verbs. Focus: Opinions, experiences, polite requests.',
  CefrLevel.c1c2:
      'Sentence Length: 15-22+ words. Vocabulary: Nuanced, abstract. Focus: Persuasion, hypothesis, subtle humor.',
};

/// Target register per CEFR level.
const Map<CefrLevel, String> kRegisterMap = {
  CefrLevel.a1a2:
      'casual everyday register (talking to friends, family, shopkeepers)',
  CefrLevel.b1b2:
      'mix of semi-formal and casual registers (coworkers, acquaintances, service staff)',
  CefrLevel.c1c2:
      'varied registers from formal business to witty casual (meetings, debates, banter)',
};

/// English-specific guidance per CEFR level.
const Map<CefrLevel, String> kEnglishLevelGuidance = {
  CefrLevel.a1a2:
      'keep it simple but still natural (avoid "I would like to...", prefer "Can I get...")',
  CefrLevel.b1b2: 'include one idiom or phrasal verb naturally woven in',
  CefrLevel.c1c2:
      'use nuanced language — hedging, understatement, or cultural references',
};

final Random _random = Random();

T pickRandom<T>(List<T> list) {
  if (list.isEmpty) {
    throw ArgumentError('pickRandom called on empty list');
  }
  return list[_random.nextInt(list.length)];
}
