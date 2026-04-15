/// Build the tone translation prompt for Tone Translator mode.
/// Response must match the translation responseSchema: {original, tones{...},
/// grammarAnalysis{sentence, components[], generalExplanation}}.
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
1. **Formal** — Business/professional register. Complete sentences, no contractions, polite hedging.
2. **Friendly** — Warm and approachable. Light contractions, positive framing, softeners.
3. **Informal** — Casual/slang. Heavy contractions, phrasal verbs, fillers, slang.
4. **Conversational** — Neutral everyday register. Natural without being overly casual or formal.

=== RULES ===
- Each variation MUST differ meaningfully in word choice, structure, and tone — not a minor swap.
- Preserve the original meaning across all 4 tones.
- Use natural collocations and idiomatic phrasing; avoid translationese.
- Adapt Vietnamese cultural idioms to equivalent English expressions, not literal translations.
- The Vietnamese 'quote' for each tone MUST reflect its specific nuance (formal → "Kính gửi...", informal → "Ê, ...").
- Break the original sentence into grammatical components with a general explanation.

Respond with a JSON object matching the translation responseSchema. Keys:
- original: echo the input text
- tones: {formal, friendly, informal, conversational} — each is {text (English), quote (Vietnamese)}
- grammarAnalysis: {sentence, components[{text, type, explanation}], generalExplanation}
No colors, no extra fields, no markdown fences.
''';
}
