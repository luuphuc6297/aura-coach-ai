/// Build the tone translation prompt for Tone Translator mode.
String buildToneTranslationPrompt(String text) {
  return '''
You are a bilingual English-Vietnamese language expert specializing in tone, register, and pragmatics.

=== TASK ===
1. Translate the input text into 4 English tonal variations. If the input is already English, rephrase it into 4 distinct variations.
2. For each English variation, provide a Vietnamese quote/translation that captures the exact tone and meaning of that specific variation.
3. Provide a detailed grammatical analysis of the original input text (or its closest English equivalent if the input is in Vietnamese).

=== INPUT ===
"$text"

=== TONE DEFINITIONS ===
1. **Formal** — Business/professional register. Use complete sentences, no contractions, appropriate hedging (e.g., "I would appreciate it if...", "Could you kindly..."). Suitable for emails, meetings, official communication.
2. **Friendly** — Warm and polite but approachable. Use light contractions, positive framing, softeners (e.g., "Hey, would you mind...", "That sounds great!"). Suitable for coworkers, acquaintances, friendly strangers.
3. **Informal** — Casual/slang register. Use heavy contractions, phrasal verbs, filler words, slang (e.g., "gonna", "kinda", "no worries", "my bad"). Suitable for close friends, texting, social media.
4. **Conversational** — Neutral everyday register. Natural but not overly casual or formal (e.g., "Can you help me with...?", "I think we should..."). Suitable for daily interactions with anyone.

=== RULES ===
- Each variation MUST be meaningfully different in word choice, sentence structure, and tone — not just minor word swaps.
- Preserve the original meaning and intent accurately across all 4 tones.
- Use natural collocations and idiomatic phrasing for each register — avoid translationese.
- If the input contains Vietnamese cultural context or idioms, adapt them to culturally equivalent English expressions rather than literal translation.
- The Vietnamese 'quote' for each tone MUST reflect the specific nuance of that English variation (e.g., a formal English sentence should have a formal Vietnamese translation like "Kính gửi...", an informal one should be "Ê, ...").
- For the grammar analysis, break down the sentence into components (subject, verb, object, etc.) and explain their roles.

Respond with ONLY a JSON object:
{
  "originalText": "$text",
  "tones": {
    "formal":          {"english": "Formal English version",        "vietnamese": "Formal Vietnamese quote",        "color": "#6366F1"},
    "friendly":        {"english": "Friendly English version",      "vietnamese": "Friendly Vietnamese quote",      "color": "#9A7B3D"},
    "informal":        {"english": "Informal English version",      "vietnamese": "Informal Vietnamese quote",      "color": "#D98A8A"},
    "conversational":  {"english": "Conversational English version","vietnamese": "Conversational Vietnamese quote","color": "#7BC6A0"}
  },
  "grammarAnalysis": {
    "components": [
      {"part": "Subject", "text": "...", "explanation": "..."},
      {"part": "Verb", "text": "...", "explanation": "..."},
      {"part": "Object", "text": "...", "explanation": "..."}
    ],
    "summary": "Overall sentence structure explanation"
  }
}
''';
}
