/// Dictionary lookup for a saved phrase. Returns part-of-speech, IPA
/// pronunciation, Vietnamese explanation, 3 examples, 3 synonyms, and a
/// contextual usage note.
String buildDictionaryPrompt({
  required String phrase,
  required String context,
}) {
  return '''
You are an expert English teacher. The user wants to save the phrase/word "$phrase" from the following context:
"$context"

Please provide:
1. The part of speech of this phrase/word in this context. You MUST choose EXACTLY ONE from this list: "Noun (Danh từ)", "Verb (Động từ)", "Adjective (Tính từ)", "Adverb (Trạng từ)", "Phrasal Verb (Cụm động từ)", "Idiom (Thành ngữ)", "Expression (Cụm từ)", "Other (Khác)".
2. The IPA pronunciation wrapped in slashes, e.g. "/ɪˈfem.ər.əl/".
3. A clear, concise explanation in Vietnamese (1-2 sentences).
4. 3 practical example sentences, each with Vietnamese translation.
5. 3 common synonyms (single words or short phrases).
6. A one-line note in Vietnamese describing when to use this word versus its close synonyms.

Respond with ONLY a JSON object in this exact shape:
{
  "partOfSpeech": "One of the exact options above",
  "pronunciation": "/.../",
  "explanation": "Giải thích ý nghĩa bằng tiếng Việt...",
  "examples": [
    {"en": "English example 1", "vn": "Vietnamese translation 1"},
    {"en": "English example 2", "vn": "Vietnamese translation 2"},
    {"en": "English example 3", "vn": "Vietnamese translation 3"}
  ],
  "synonyms": ["syn1", "syn2", "syn3"],
  "contextUsage": "Dùng khi..."
}
''';
}

/// Side-by-side Compare Words prompt for the Pro sub-screen. The payload is
/// two independently rendered columns + a shared "keyDifference" blurb and
/// per-word "when to use" one-liners.
String buildWordComparisonPrompt({
  required String wordA,
  required String wordB,
}) {
  return '''
You are an expert English teacher helping a Vietnamese learner tell two near-synonyms apart. Compare the words "$wordA" and "$wordB".

For EACH word provide:
1. The IPA phonetic transcription, wrapped in slashes (e.g., "/əˈfekt/").
2. A concise Vietnamese translation (the most natural 1-3 word meaning).
3. The part of speech ("Noun", "Verb", "Adjective", "Adverb", "Phrasal Verb", "Idiom", "Expression", "Other").
4. A short English definition — one sentence.
5. The register — pick EXACTLY ONE from: "Formal", "Neutral", "Casual".
6. The connotation — pick EXACTLY ONE from: "Positive", "Neutral", "Negative".
7. ONE natural English example sentence with Vietnamese translation.
8. 3 common collocations.

Then describe the overall contrast:
- "keyDifference": one short paragraph (2-3 sentences) summarising the headline nuance between the two words.
- "whenToUseA": one sentence guiding the learner on when to pick "$wordA".
- "whenToUseB": one sentence guiding the learner on when to pick "$wordB".

Respond with ONLY a JSON object in this exact shape:
{
  "wordA": {
    "word": "$wordA",
    "phonetic": "/.../",
    "translation": "Vietnamese meaning",
    "partOfSpeech": "...",
    "definition": "...",
    "register": "Formal | Neutral | Casual",
    "connotation": "Positive | Neutral | Negative",
    "example": {"en": "...", "vn": "..."},
    "collocations": ["...", "...", "..."]
  },
  "wordB": {
    "word": "$wordB",
    "phonetic": "/.../",
    "translation": "Vietnamese meaning",
    "partOfSpeech": "...",
    "definition": "...",
    "register": "Formal | Neutral | Casual",
    "connotation": "Positive | Neutral | Negative",
    "example": {"en": "...", "vn": "..."},
    "collocations": ["...", "...", "..."]
  },
  "keyDifference": "Short paragraph...",
  "whenToUseA": "Use '$wordA' when...",
  "whenToUseB": "Use '$wordB' when..."
}
''';
}

/// Word analysis prompt for Vocab Hub deep-dive view.
String buildWordAnalysisPrompt({
  required String word,
  String? context,
}) {
  final contextLine =
      (context != null && context.isNotEmpty) ? 'Context: "$context"' : '';

  return '''
You are an expert linguist and etymologist. Analyze the English word "$word".
$contextLine

Provide a comprehensive morphological breakdown and contextual analysis.

Instructions:
1. Provide the phonetic transcription (IPA).
2. Provide the part of speech. You MUST choose EXACTLY ONE from: "Noun", "Verb", "Adjective", "Adverb", "Phrasal Verb", "Idiom", "Expression", "Other".
3. Provide a short English definition — one concise sentence (max ~20 words).
4. Provide the Vietnamese translation (the most natural 1-2 sentence rendering, not just a single-word gloss).
5. Break down the word into its morphological components (prefix, root, suffix). If a component doesn't exist, omit it.
   - Provide the morpheme and its meaning.
   - For the root, ALSO provide its origin if you are confident (e.g., Latin, Greek, Old English, Germanic, Old French, Anglo-Saxon). If the etymology is uncertain or the root is a native English word with an obvious meaning, omit the "origin" field — do NOT invent or guess.
   - Create an equation (e.g., "sym- + path + -y = sympathy" or "friend + -ly = friendly").
6. Provide THREE example sentences — one positive context, one neutral/everyday context, and one negative context — each with a Vietnamese translation.
7. List 3 common collocations (words that frequently go with this word).
8. Provide its derivatives (word family) for noun, verb, adjective, and adverb forms if they exist.
   - Each derivative MUST be a single English word only (no punctuation, no phrases, no definitions, no Vietnamese).
   - Do NOT include HTTP headers, JSON fragments, metadata, timestamps, or any non-lexical text.
   - If a form does not exist or is the same as the base word, omit that field entirely.
9. List 3 synonyms and 3 antonyms.

Respond with ONLY a JSON object matching this exact shape:
{
  "word": "$word",
  "phonetic": "/.../",
  "partOfSpeech": "Noun | Verb | Adjective | ...",
  "definition": "One-sentence English definition.",
  "translation": "Vietnamese meaning",
  "morphology": {
    "prefix": {"morpheme": "...", "meaning": "..."},
    "root":   {"morpheme": "...", "meaning": "...", "origin": "Latin | Greek | Old English | Germanic | ... (omit this field entirely if unsure)"},
    "suffix": {"morpheme": "...", "meaning": "..."},
    "equation": "prefix + root + suffix = word"
  },
  "contextualEmbedding": {
    "positiveExample": {"en": "Positive example", "vn": "Vietnamese translation"},
    "neutralExample":  {"en": "Everyday/neutral example", "vn": "Vietnamese translation"},
    "negativeExample": {"en": "Negative example", "vn": "Vietnamese translation"},
    "collocations": ["collocation 1", "collocation 2", "collocation 3"]
  },
  "derivatives": {
    "noun": "...",
    "verb": "...",
    "adjective": "...",
    "adverb": "..."
  },
  "synonyms": ["syn1", "syn2", "syn3"],
  "antonyms": ["ant1", "ant2", "ant3"]
}
''';
}

/// Flashcard batch generator for a specific onboarding topic. The learner
/// picks a topic chip (e.g. "Travel", "Business") and this prompt returns a
/// small, level-appropriate list of useful vocabulary with just enough
/// fields to avoid a follow-up enrichment call when persisting to the
/// library: phonetic, part of speech, short English definition, Vietnamese
/// gloss, and a single bilingual example.
String buildTopicFlashcardsPrompt({
  required String topic,
  required String cefrLevel,
  int count = 8,
}) {
  return '''
You are an expert English teacher building a flashcard deck for a Vietnamese learner at CEFR level $cefrLevel. Generate exactly $count useful, distinct English words or short phrases for the topic "$topic".

Rules:
1. Prioritise high-utility, everyday vocabulary the learner will actually encounter when reading, listening, or speaking about "$topic" at this CEFR level. Avoid obvious beginner words the learner almost certainly already knows (e.g. for "Travel" at B1-B2 skip "hotel", "airport").
2. No duplicates. No proper nouns (country/brand/person names). No obscure jargon.
3. Mix parts of speech where natural (nouns, verbs, adjectives, phrasal verbs).
4. Keep each "word" field to at most 3 tokens. Longer phrasing belongs in the example.

For EACH item provide:
- "word": the English headword or short phrase.
- "phonetic": IPA transcription wrapped in slashes (e.g. "/ɪˈtɪn.ər.i/").
- "partOfSpeech": EXACTLY ONE of "Noun", "Verb", "Adjective", "Adverb", "Phrasal Verb", "Idiom", "Expression", "Other".
- "definition": a concise one-sentence English definition (≤ 18 words).
- "translation": the natural Vietnamese meaning (1-2 sentences, not just one-word gloss).
- "example": a natural English sentence using the word, with Vietnamese translation.

Respond with ONLY a JSON object in this exact shape:
{
  "topic": "$topic",
  "items": [
    {
      "word": "...",
      "phonetic": "/.../",
      "partOfSpeech": "Noun | Verb | ...",
      "definition": "...",
      "translation": "Vietnamese meaning",
      "example": {"en": "...", "vn": "..."}
    }
  ]
}
''';
}
