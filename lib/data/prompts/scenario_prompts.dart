import 'prompt_constants.dart';

/// Result of [buildGenerateNextLessonPrompt]: the raw prompt plus the topic
/// that was randomly picked from the user's topic pool (so the caller can
/// persist it alongside the generated scenario).
class NextLessonPrompt {
  final String prompt;
  final String chosenTopic;
  final String chosenSentenceType;

  const NextLessonPrompt({
    required this.prompt,
    required this.chosenTopic,
    required this.chosenSentenceType,
  });
}

/// Build the prompt that asks Gemini to generate ONE micro-scenario matching
/// the student's CEFR level and topic domain. [previousTitles] is used to
/// enforce uniqueness across recent generations. [excludeVietnamesePhrases]
/// is only non-empty on a retry after a duplicate was detected locally —
/// the list goes into an extra "AVOID REPETITION" block so the LLM stops
/// regenerating the exact same Vietnamese sentence it just produced.
NextLessonPrompt buildGenerateNextLessonPrompt({
  required CefrLevel userLevel,
  required List<String> userTopics,
  required List<String> previousTitles,
  List<String> excludeVietnamesePhrases = const [],
}) {
  final recentContext = previousTitles.length > 20
      ? previousTitles.sublist(previousTitles.length - 20)
      : previousTitles;
  final recentContextStr = recentContext.join(' | ');

  final targetSpec = kLevelSpecs[userLevel]!;
  final targetRegister = kRegisterMap[userLevel]!;
  final levelGuidance = kEnglishLevelGuidance[userLevel]!;
  final chosenTopic = userTopics.isEmpty ? 'General' : pickRandom(userTopics);
  final chosenType = pickRandom(kSentenceTypes);

  final avoidBlock = excludeVietnamesePhrases.isEmpty
      ? ''
      : '''
6. **AVOID REPETITION**: The Vietnamese sentences below were just generated but duplicate content the student has already practiced. Produce a Vietnamese sentence that is semantically AND lexically different — different verbs, different nouns, different situation:
${excludeVietnamesePhrases.map((s) => '   - "$s"').join('\n')}
''';

  final prompt = '''
You are a creative scenario designer for a Vietnamese English learner. Your goal is to produce ONE hyper-specific, culturally grounded micro-scenario that feels like a real moment from daily life — not a textbook exercise.

=== STUDENT PROFILE ===
- CEFR Level: ${userLevel.code}
- Language Specs: $targetSpec
- Topic Domain: $chosenTopic
- Target Register: $targetRegister
- Required Sentence Type: $chosenType

=== SCENARIO DESIGN RULES ===
1. **Micro-moment, not generic scene**: Pick a hyper-specific moment (e.g., not "at a restaurant" but "asking the waiter why your phở has no herbs"). The situation must include WHO is speaking, WHERE exactly, and WHAT just happened.
2. **Vietnamese phrase rules**:
   - Must sound like real spoken Vietnamese, not written/formal Vietnamese.
   - Use natural particles and fillers: nhỉ, à, ạ, nha, với, hộ mình, cái, đi, thôi, chứ, mà, etc.
   - Match the emotional tone of the situation (frustrated → stronger particles, polite → softer particles).
   - Avoid dictionary-style translations. Write how a Vietnamese person would actually say it out loud.
3. **English phrase rules**:
   - Must match the $targetRegister.
   - Use contractions, phrasal verbs, and natural collocations — not textbook grammar.
   - For ${userLevel.code}: $levelGuidance.
4. **Sentence type**: Generate a **$chosenType**. Do NOT fall back to a plain declarative statement.
5. **STRICT UNIQUENESS**: These scenarios were already generated — you MUST create something completely different in sub-topic, setting, characters, and sentence structure: [$recentContextStr]
$avoidBlock
=== HINT DESIGN RULES ===
- level1 (Meaning): Describe the communicative intent in Vietnamese (e.g., "Bạn muốn hỏi lý do tại sao..."). Do NOT reveal any English words.
- level2 (Structure): Give the sentence skeleton with blanks (e.g., "Why didn't you ___ the ___?"). Reveal structure, not vocabulary.
- level3 (Key vocabulary): List 2-3 key English words/phrases the student needs, with brief Vietnamese meanings (e.g., "herbs = rau thơm, complain = phàn nàn").

=== OUTPUT FORMAT ===
Respond with ONLY a JSON object, no extra text, no markdown fences:
{
  "situation": "Specific micro-moment. Who speaks to whom, where, what just happened.",
  "topic": "$chosenTopic",
  "sentenceType": "$chosenType",
  "difficulty": "${userLevel.code}",
  "vietnamesePhrase": "Câu tiếng Việt tự nhiên, có particles phù hợp",
  "englishPhrase": "Natural English translation matching the register",
  "title": "Short 3-6 word headline summarizing the scenario for uniqueness tracking",
  "hints": {
    "level1": "Mô tả intent bằng tiếng Việt, KHÔNG chứa từ tiếng Anh nào",
    "level2": "English sentence skeleton with ___ for blanks",
    "level3": "word1 = nghĩa1, word2 = nghĩa2, word3 = nghĩa3"
  },
  "vocabularyPrep": ["word1", "word2", "word3"]
}
''';

  return NextLessonPrompt(
    prompt: prompt,
    chosenTopic: chosenTopic,
    chosenSentenceType: chosenType,
  );
}

/// Build the evaluation prompt. [direction] must be 'vn-to-en' or 'en-to-vn'.
String buildEvaluateResponsePrompt({
  required String userInput,
  required String sourcePhrase,
  required String situation,
  required CefrLevel targetLevel,
  required String direction,
}) {
  final isVnToEn = direction == 'vn-to-en';
  final sourceLang = isVnToEn ? 'Vietnamese' : 'English';
  final targetLang = isVnToEn ? 'English' : 'Vietnamese';

  return '''
Role: You are a strict linguistic expert and CEFR assessor.
Task: Evaluate the User's $targetLang translation of a $sourceLang source sentence based on a specific Context.

Scoring Rubric (Scale 1-10):
9-10: Native-like, idiomatically perfect for the context. (C2)
7-8: Grammatically correct, fluent, but slightly textbook-like. (B2-C1)
5-6: Grammatically correct but stiff/formal or slight unnatural phrasing. (B1)
3-4: Understandable but with grammatical errors. (A2)
1-2: Incomprehensible or completely wrong meaning. (A1)

Formula: Final Score = 0.4 * Accuracy + 0.4 * Naturalness + 0.2 * Complexity.

Input Context:
Source $sourceLang: "$sourcePhrase"
Situation: "$situation"
Target CEFR Level: "${targetLevel.code}"
User Input to Evaluate ($targetLang): "$userInput"

Instructions:
1. Analyze Grammatical Accuracy in $targetLang.
2. Analyze Pragmatic Naturalness. Is this how a native speaker sounds in this context?
3. Analyze Vocabulary. Are the words precise?
4. **Identify Specific Improvements**: Find exact substrings in the user's input that are wrong or unnatural. Provide corrections and explanations for each.
5. **Tone Analysis**: Identify the tone of the user's input.
6. **Generate Variations**: Provide 4 distinct versions of the translation in $targetLang:
   - Formal
   - Friendly
   - Informal
   - Conversational
7. **Key Vocabulary**: Extract up to 5 noteworthy content words or short phrases from the user's input OR the better alternative that a Vietnamese learner should save for review. Skip trivial function words (articles, pronouns, simple verbs like "be", "have", "do" unless idiomatic). For each item return {word, partOfSpeech, meaning (Vietnamese), example (one short English sentence)}.
8. Provide scores and detailed feedback.

Respond with a JSON object matching the response schema. Key fields:
- improvements[] — each item: {original, correction, type: 'grammar' | 'vocabulary', explanation}
- alternativeTones — flat map {formal, friendly, informal, conversational}; each value is the translated sentence as a plain string.
- userTone — one of 'Neutral', 'Formal', 'Friendly', 'Informal', 'Conversational', 'Rude', 'Too Formal'.
- keyVocabulary — array of {word, partOfSpeech, meaning, example}. May be empty if the input has no meaningful content words.
Do not invent extra fields. Do not emit markdown fences.
''';
}

/// Build a progressive hints prompt that enforces the reference hint design.
String buildProgressiveHintsPrompt({
  required String situation,
  required String vietnamesePhrase,
  required CefrLevel targetLevel,
}) {
  return '''
You are helping a ${targetLevel.code} Vietnamese student who is stuck translating a sentence.

Situation: $situation
Vietnamese sentence to translate: "$vietnamesePhrase"

Generate 3 progressive hints following these rules:
- level1 (Meaning): Describe the communicative intent in Vietnamese ONLY. Do NOT include any English words.
- level2 (Structure): Give the English sentence skeleton with ___ blanks (e.g., "Why didn't you ___ the ___?"). Reveal structure, not vocabulary.
- level3 (Key vocabulary): List 2-3 key English words with brief Vietnamese meanings.

Respond with ONLY a JSON object:
{
  "hints": {
    "level1": "Tiếng Việt mô tả intent, không có từ tiếng Anh",
    "level2": "English skeleton with ___ blanks",
    "level3": "word1 = nghĩa1, word2 = nghĩa2"
  }
}
''';
}
