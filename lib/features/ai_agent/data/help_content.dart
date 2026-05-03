/// Static help-center content for the AI Agent tab. Edited by hand — kept
/// in code (not Firestore) so the help is shippable in the binary and
/// available offline. Update copy here, no migration needed.
class HelpGuide {
  final String id;
  final String title;
  final String summary;
  final String body;

  const HelpGuide({
    required this.id,
    required this.title,
    required this.summary,
    required this.body,
  });
}

class HelpFaq {
  final String question;
  final String answer;

  const HelpFaq({required this.question, required this.answer});
}

class HelpContent {
  static const List<HelpGuide> guides = [
    HelpGuide(
      id: 'scenario',
      title: 'Scenario Coach',
      summary: 'Role-play real-life conversations with an AI partner.',
      body:
          'Pick a scenario from the Home grid, choose your level (A2-C2), '
          'and start chatting. The AI plays the other side of the conversation '
          '(barista, interviewer, doctor…) and corrects your English in line.\n\n'
          '• Tap any AI message to hear pronunciation.\n'
          '• Tap a phrase you don\'t know to save it to your Library.\n'
          '• End the session anytime to get an Assessment Report.',
    ),
    HelpGuide(
      id: 'story',
      title: 'Story Mode',
      summary: 'Read short AI-written stories at your level.',
      body:
          'Browse Featured stories or generate a custom one from your own topic. '
          'Tap any word in the story to see its meaning and save it. After '
          'finishing, you can chat with the AI about the story to practice '
          'comprehension.\n\nFree tier: 1 custom story / day. Pro: unlimited.',
    ),
    HelpGuide(
      id: 'tone',
      title: 'Tone Translator',
      summary: 'Rewrite any sentence in formal, neutral, or casual tone.',
      body:
          'Paste an English sentence (or write one in Vietnamese, then '
          'translate first), and the AI returns 3 versions: Formal, Neutral, '
          'and Casual. Use it for emails, chat messages, or just to learn '
          'register.',
    ),
    HelpGuide(
      id: 'vocab-hub',
      title: 'Vocab Hub',
      summary: 'Deep-dive vocabulary toolset — 6 sub-features.',
      body:
          'From Vocab Hub home you can:\n\n'
          '• Word Analysis — IPA, definition, 3 example sentences, synonyms\n'
          '• Describe Word — describe a word in Vietnamese, get English candidates\n'
          '• Flashcards — SM-2 spaced repetition for saved words\n'
          '• Compare Words — side-by-side nuance like "affect" vs "effect"\n'
          '• Learning Library — every saved word from every mode\n'
          '• Mind Maps (Pro) — visualize word relationships, drag & expand',
    ),
    HelpGuide(
      id: 'insights',
      title: 'Insight tab',
      summary: 'Library + Stats in one place.',
      body:
          'Switch between sub-tabs at the top:\n\n'
          '• Library — every saved word with filters and Practice/Listen/Mind '
          'Map quick actions.\n'
          '• Stats — daily streak heatmap, practice minutes, skill bars '
          '(Fluency / Accuracy / Naturalness / Vocabulary), and your weakest '
          'words.\n\n'
          'Pull-to-refresh forces a re-fetch.',
    ),
    HelpGuide(
      id: 'notifications',
      title: 'Notifications',
      summary: 'Daily reminders, streak alerts, due-cards prompts.',
      body:
          'The app schedules local reminders to keep your streak alive and '
          'flag flashcards waiting for review. Tap any notification card to '
          'jump straight to the relevant screen. Swipe left to dismiss. Use '
          '"Mark all read" in the header to clear the badge.\n\n'
          'You can change reminder time in Profile > Settings > Notifications.',
    ),
  ];

  static const List<HelpFaq> faqs = [
    HelpFaq(
      question: 'How do I save a word to my library?',
      answer:
          'In any chat or story, tap a word — a card pops up with the meaning '
          'and a Save button. Once saved, you can review it from Vocab Hub > '
          'Flashcards or Insight > Library.',
    ),
    HelpFaq(
      question: 'What\'s the difference between Free and Pro?',
      answer:
          'Free includes core practice: scenarios, stories, vocab tools, and '
          'flashcards with daily quotas. Pro removes quotas, unlocks Mind '
          'Maps, AI-generated illustrations, and unlimited custom story '
          'generation.',
    ),
    HelpFaq(
      question: 'My streak disappeared — what happened?',
      answer:
          'Streaks reset if you skip a calendar day without completing at '
          'least one practice session. The notification 18 hours before reset '
          'is your warning — tap it to jump back in.',
    ),
    HelpFaq(
      question: 'Can I use the app offline?',
      answer:
          'Saved words and previous sessions are cached locally and viewable '
          'offline. New AI generations (chat replies, story creation, word '
          'analysis) need an internet connection.',
    ),
    HelpFaq(
      question: 'How do flashcards know when to show me a word?',
      answer:
          'Flashcards use the SM-2 algorithm: every time you rate a card '
          'Hard / Good / Easy, the app schedules the next review. Easier '
          'cards reappear less often, harder ones more often. Cards "due '
          'today" show up first when you open Flashcards.',
    ),
    HelpFaq(
      question: 'I found a bug or have a feature request.',
      answer:
          'Tap "Send feedback" in the Contact section below. Include what '
          'you were doing and what went wrong — screenshots help a lot.',
    ),
  ];

  static const String contactEmail = 'support@auracoach.ai';
  static const String contactHotline = '+84 28 1234 5678';

  /// System prompt for the Ask AI chat. Constrains the model to answer ONLY
  /// app-usage questions (not English lessons), reply in Vietnamese, and
  /// stay short. Also reminds it not to invent features.
  static const String askAiSystemPrompt = '''
You are Aura, the in-app help assistant for "Aura Coach AI" — a Vietnamese-friendly English learning app.

YOUR JOB
- Answer questions about HOW TO USE the app, troubleshoot issues, and explain features.
- You are NOT an English tutor. For English lessons, point users to the relevant mode in the app.

THE APP HAS THESE FEATURES
1. Scenario Coach — role-play conversations in real-life situations (ordering coffee, job interview, doctor visit, etc.)
2. Story Mode — read/listen to short AI-written stories at the user's level.
3. Tone Translator — paraphrase a sentence in formal, neutral, or casual tone.
4. Vocab Hub — deep-dive vocabulary feature, with 6 sub-tools:
   - Word Analysis (IPA, definitions, examples, synonyms)
   - Describe Word (Vietnamese description → English candidates)
   - Flashcards (SM-2 spaced repetition)
   - Compare Words (side-by-side nuance, e.g. "affect" vs "effect")
   - Learning Library (saved words from all modes)
   - Mind Maps (Pro) — visualize word relationships, drag & expand nodes
5. Insight tab — Library + Stats (streak heatmap, practice time, skill bars, weak words)
6. Notifications — daily reminders, streak alerts, due-card prompts
7. Profile — edit profile, settings, subscription

GUIDELINES
- Reply in Vietnamese (the primary user base), but include English terms in parens when relevant (e.g., "Vào Vocab Hub > Word Analysis").
- Keep answers under 4 sentences unless the user explicitly asks for more detail.
- If the user asks an English-language question (grammar, vocabulary, translations), politely redirect them: "Để học từ vựng, hãy thử Vocab Hub > Word Analysis nhé."
- If a user reports a bug or asks something you can't confidently answer, suggest "Bạn có thể gửi feedback ở mục Contact trong Help screen."
- Never invent features that don't exist. If unsure, say so honestly.
- Never give legal, medical, or financial advice.
''';
}
