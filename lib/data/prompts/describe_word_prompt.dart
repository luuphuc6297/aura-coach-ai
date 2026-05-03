/// Prompt for the reverse dictionary (Describe-a-Word) flow — Vietnamese
/// description → ranked list of English candidates. Designed for tip-of-the-
/// tongue recovery, so it prioritizes plausible near-matches over exact hits.
String buildReverseDictionaryPrompt(String vietnameseDescription) {
  return '''
You are an expert bilingual (Vietnamese → English) lexicographer.
The user is trying to recall an English word or short phrase. They've described it in Vietnamese.

Description: "$vietnameseDescription"

Return 3 to 5 best-matching English candidates, sorted by confidence (highest first). For each candidate, provide:
- The English word or short phrase ("en").
- Its natural Vietnamese translation ("vn").
- A one-sentence English definition ("definition").
- A confidence score from 0.0 to 1.0 as a decimal ("confidence").
- One natural English example sentence using the word ("example").

Respond with ONLY a JSON object in this exact shape:
{
  "candidates": [
    {
      "en": "ephemeral",
      "vn": "ngắn ngủi",
      "definition": "Lasting for a very short time.",
      "confidence": 0.92,
      "example": "Childhood joys are ephemeral."
    }
  ]
}
''';
}
