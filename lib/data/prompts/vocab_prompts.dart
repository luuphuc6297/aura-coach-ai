/// Dictionary lookup for a saved phrase. Returns part-of-speech, explanation
/// in Vietnamese, and 3 example sentences with Vietnamese translations.
String buildDictionaryPrompt({
  required String phrase,
  required String context,
}) {
  return '''
You are an expert English teacher. The user wants to save the phrase/word "$phrase" from the following context:
"$context"

Please provide:
1. The part of speech of this phrase/word in this context. You MUST choose EXACTLY ONE from this list: "Noun (Danh từ)", "Verb (Động từ)", "Adjective (Tính từ)", "Adverb (Trạng từ)", "Phrasal Verb (Cụm động từ)", "Idiom (Thành ngữ)", "Expression (Cụm từ)", "Other (Khác)".
2. A clear, concise explanation of what this phrase means in this specific context (in Vietnamese).
3. 3 practical examples of how to use this phrase in other common situations. Each example must have an English sentence and its Vietnamese translation.

Respond with ONLY a JSON object in this exact format:
{
  "partOfSpeech": "One of the exact options above",
  "explanation": "Giải thích ý nghĩa bằng tiếng Việt...",
  "examples": [
    {"en": "English example 1", "vn": "Vietnamese translation 1"},
    {"en": "English example 2", "vn": "Vietnamese translation 2"},
    {"en": "English example 3", "vn": "Vietnamese translation 3"}
  ]
}
''';
}

/// Word analysis prompt for Vocab Hub deep-dive view.
String buildWordAnalysisPrompt({
  required String word,
  String? context,
}) {
  final contextLine = (context != null && context.isNotEmpty)
      ? 'Context: "$context"'
      : '';

  return '''
You are an expert linguist and etymologist. Analyze the English word "$word".
$contextLine

Provide a comprehensive morphological breakdown and contextual analysis.

Instructions:
1. Provide the phonetic transcription (IPA).
2. Provide the Vietnamese translation.
3. Break down the word into its morphological components (prefix, root, suffix). If a component doesn't exist, omit it.
   - Provide the morpheme, its meaning, and for the root, its origin (e.g., Latin, Greek).
   - Create an equation (e.g., "sym- + path + -y = sympathy").
4. Provide two example sentences (one positive context, one negative context) with Vietnamese translations.
5. List 3 common collocations (words that frequently go with this word).
6. Provide its derivatives (word family) for noun, verb, adjective, and adverb forms if they exist.
7. List 3 synonyms and 3 antonyms.

Respond with ONLY a JSON object:
{
  "word": "$word",
  "ipa": "/.../",
  "translation": "Vietnamese meaning",
  "morphology": {
    "prefix": {"morpheme": "...", "meaning": "..."},
    "root":   {"morpheme": "...", "meaning": "...", "origin": "Latin | Greek | ..."},
    "suffix": {"morpheme": "...", "meaning": "..."},
    "equation": "prefix + root + suffix = word"
  },
  "examples": [
    {"type": "positive", "en": "Positive example", "vn": "Vietnamese translation"},
    {"type": "negative", "en": "Negative example", "vn": "Vietnamese translation"}
  ],
  "collocations": ["collocation 1", "collocation 2", "collocation 3"],
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
