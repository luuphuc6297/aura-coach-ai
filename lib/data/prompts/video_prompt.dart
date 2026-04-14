/// Build the prompt used to request a cinematic video illustration of a phrase.
String buildVideoPrompt({
  required String situation,
  required String phrase,
}) {
  return '''
Cinematic, realistic 4k video.
Context: $situation.
Action: A person clearly and naturally speaking the phrase: "$phrase".
Style: Educational, clear facial expressions, high quality, professional lighting.
''';
}
