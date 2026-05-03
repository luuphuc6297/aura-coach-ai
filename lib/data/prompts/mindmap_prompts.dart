import 'dart:convert';
import 'prompt_constants.dart';

/// Build the root node prompt for the Vocab Hub mind map.
String buildMindMapRootPrompt({
  required String topic,
  required CefrLevel level,
}) {
  return '''
Create an initial vocabulary mind map for the topic "$topic" at the ${level.code} level.

The root node should be the topic itself.
It should have exactly 2 highly concrete, common, and direct vocabulary words as children.
For example, if the topic is "Family", the children MUST be concrete words like "Mother" and "Father", NOT abstract concepts like "Family dynamics" or "Extended family".
Keep the words simple, direct, and highly relevant to everyday usage.

For the root node AND each child node, provide:
1. The English word (label)
2. The Vietnamese translation (translation)
3. The part of speech (partOfSpeech) - e.g., "Noun", "Verb", "Adjective"
4. The IPA phonetic transcription wrapped in slashes (phonetic), e.g. "/ˈtrævəl/". For topic/category nodes that aren't single words, return an empty string.
5. A short English sentence explaining its context or usage (context)

Respond with ONLY a JSON object:
{
  "root": {
    "label": "$topic",
    "translation": "Vietnamese translation of topic",
    "partOfSpeech": "Noun",
    "phonetic": "/IPA/",
    "context": "Example sentence using the topic"
  },
  "children": [
    {
      "label": "ConcreteWord1",
      "translation": "Vietnamese translation",
      "partOfSpeech": "Noun",
      "phonetic": "/IPA/",
      "context": "Example sentence"
    },
    {
      "label": "ConcreteWord2",
      "translation": "Vietnamese translation",
      "partOfSpeech": "Noun",
      "phonetic": "/IPA/",
      "context": "Example sentence"
    }
  ]
}
''';
}

/// Build the expansion prompt for a clicked mind map node.
String buildMindMapExpandPrompt({
  required String nodeLabel,
  required String rootTopic,
  required CefrLevel level,
}) {
  final levelHint = switch (level) {
    CefrLevel.a1a2 =>
      'are high-frequency and essential for daily communication',
    CefrLevel.b1b2 =>
      'expand vocabulary breadth with useful near-synonyms or related terms',
    CefrLevel.c1c2 =>
      'include nuanced distinctions, formal/informal variants, or less common but precise terms',
  };

  return '''
You are building a vocabulary mind map for a ${level.code} English learner studying "$rootTopic".
The user clicked on the node "$nodeLabel" to expand it.

=== YOUR TASK ===
Generate exactly 2 new vocabulary words that are **semantically close relatives** of "$nodeLabel" within the topic "$rootTopic".

=== WHAT "SEMANTICALLY CLOSE" MEANS ===
The new words must belong to the **same semantic family or category** as "$nodeLabel". Think: "If I'm learning about $nodeLabel, what other words do I NEED to know that are in the same group?"

Examples of GOOD expansions:
- "Mother" → "Grandmother", "Aunt" (same category: female family members)
- "Dog" → "Puppy", "Bark" (same entity: life stage + core action)
- "Kitchen" → "Stove", "Fridge" (same space: objects found there)
- "Run" → "Sprint", "Jog" (same action: variations of running)

Examples of BAD expansions (DO NOT do this):
- "Mother" → "Apron", "Nurture" (loosely associated objects/concepts, NOT same semantic group)
- "Dog" → "Loyalty", "Leash" (abstract traits or loosely related objects)
- "Kitchen" → "Hunger", "Recipe" (abstract concepts, not concrete vocabulary in the same group)

=== RULES ===
1. **Same semantic group**: Both words must be in the same category/family as "$nodeLabel" — siblings, subtypes, or direct components.
2. **1-2 words maximum** per node. No phrases or explanations as labels.
3. **Level-appropriate**: For ${level.code}, choose words that $levelHint.
4. **Learner-useful**: A student learning "$nodeLabel" would naturally want to learn these words next.

=== OUTPUT PER NODE ===
1. **label**: The English word (1-2 words)
2. **translation**: Vietnamese translation
3. **partOfSpeech**: "Noun", "Verb", "Adjective", "Adverb", etc.
4. **phonetic**: IPA transcription wrapped in slashes, e.g. "/ˈtrævəl/"
5. **context**: A natural example sentence using this word in the context of "$rootTopic" (max 15 words)

Respond with ONLY a JSON array of exactly 2 objects:
[
  {"label": "Word1", "translation": "...", "partOfSpeech": "Noun", "phonetic": "/IPA/", "context": "Example sentence"},
  {"label": "Word2", "translation": "...", "partOfSpeech": "Noun", "phonetic": "/IPA/", "context": "Example sentence"}
]
''';
}

/// Build the prompt that checks whether a user-added custom word is related to
/// the existing mind map. [existingNodes] is a list of `{id, label}` pairs.
String buildCustomNodePrompt({
  required String customWord,
  required List<Map<String, String>> existingNodes,
}) {
  final nodesJson = jsonEncode(existingNodes);
  return '''
The user wants to add the word "$customWord" to their current vocabulary mind map.
Here are the existing nodes in the mind map:
$nodesJson

Determine if "$customWord" is related to any of these existing nodes.
If it is related, find the BEST parent node for it and return status "connected" with the parentNodeId.
Also provide:
1. The Vietnamese translation (translation)
2. The part of speech (partOfSpeech) - e.g., "Noun", "Verb", "Adjective"
3. The IPA phonetic transcription wrapped in slashes (phonetic), e.g. "/ˈtrævəl/"
4. A short English sentence explaining its context or usage (context)

If it is NOT related to ANY of the nodes (including the root), return status "unrelated" and a brief message explaining why.

Respond with ONLY a JSON object:
{
  "status": "connected | unrelated",
  "parentNodeId": "id of parent node if connected, else null",
  "label": "$customWord",
  "translation": "Vietnamese translation if connected, else null",
  "partOfSpeech": "Part of speech if connected, else null",
  "phonetic": "/IPA/ if connected, else null",
  "context": "Example sentence if connected, else null",
  "message": "Explanation if unrelated, else null"
}
''';
}
