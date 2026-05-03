import 'package:google_generative_ai/google_generative_ai.dart';

/// Gemini responseSchema definitions. Ported 1:1 from
/// aura-coach/services/gemini/schemas.ts so the AI contract matches the web
/// platform exactly. Each schema is consumed by a specific endpoint in
/// [GeminiService].
class GeminiSchemas {
  GeminiSchemas._();

  // ---------- Assessment ----------
  static final assessment = Schema.object(
    properties: {
      'score': Schema.number(
          description:
              'Overall score on a scale of 1-10 based on CEFR mapping.'),
      'accuracyScore':
          Schema.number(description: 'Score for grammatical accuracy (1-10).'),
      'naturalnessScore':
          Schema.number(description: 'Score for pragmatic naturalness (1-10).'),
      'complexityScore':
          Schema.number(description: 'Score for vocabulary complexity (1-10).'),
      'feedback': Schema.string(description: 'General constructive feedback.'),
      'grammarAnalysis': Schema.string(
          description:
              'Specific analysis of grammatical errors. Start with "Grammar Point:".'),
      'vocabularyAnalysis': Schema.string(
          description:
              'Specific analysis of vocabulary choice. Start with "Vocabulary Point:".'),
      'correction': Schema.string(
          description:
              'Corrected version if the user input is grammatically wrong. Null if correct.',
          nullable: true),
      'betterAlternative': Schema.string(
          description:
              'A more natural/native phrasing if correct but unnatural. Null if perfect.',
          nullable: true),
      'analysis': Schema.string(
          description: 'Detailed summary of why this score was given.'),
      'improvements': Schema.array(
        items: Schema.object(
          properties: {
            'original': Schema.string(
                description:
                    'The exact substring from the user input that needs improvement.'),
            'correction':
                Schema.string(description: 'The corrected word or phrase.'),
            'type': Schema.enumString(enumValues: ['grammar', 'vocabulary']),
            'explanation': Schema.string(
                description: 'Short explanation of why this change is needed.'),
          },
          requiredProperties: ['original', 'correction', 'type', 'explanation'],
        ),
      ),
      'userTone': Schema.string(
          description:
              'The detected tone/register of the user input (e.g., "Too Formal", "Casual", "Rude", "Neutral").'),
      'alternativeTones': Schema.object(
        properties: {
          'formal': Schema.string(
              description: 'A formal/business appropriate version.'),
          'friendly': Schema.string(description: 'A warm, friendly version.'),
          'informal':
              Schema.string(description: 'A very casual or slang version.'),
          'conversational': Schema.string(
              description: 'A standard, neutral conversational version.'),
        },
        requiredProperties: [
          'formal',
          'friendly',
          'informal',
          'conversational'
        ],
      ),
      'nextAgentReply': Schema.string(
          description:
              'The next logical response from the Agent to continue the story conversation.',
          nullable: true),
      'nextAgentReplyVietnamese': Schema.string(
          description: 'The Vietnamese translation of nextAgentReply.',
          nullable: true),
      'keyVocabulary': Schema.array(
        description:
            'Up to 5 noteworthy vocabulary words or phrases from the user input or the better alternative that the learner should save. Skip trivial function words.',
        items: Schema.object(
          properties: {
            'word': Schema.string(
                description: 'The vocabulary word or short phrase, lowercase.'),
            'partOfSpeech': Schema.string(
                description: 'Part of speech (noun, verb, adjective, etc.).'),
            'meaning': Schema.string(
                description:
                    'Concise Vietnamese translation or bilingual meaning of the word.'),
            'example': Schema.string(
                description:
                    'One short natural English example sentence using the word.'),
          },
          requiredProperties: ['word', 'partOfSpeech', 'meaning', 'example'],
        ),
      ),
    },
    requiredProperties: [
      'score',
      'accuracyScore',
      'naturalnessScore',
      'complexityScore',
      'feedback',
      'grammarAnalysis',
      'vocabularyAnalysis',
      'analysis',
      'improvements',
      'userTone',
      'alternativeTones',
      'keyVocabulary',
    ],
  );

  // ---------- Lesson (Scenario Coach) ----------
  static final lesson = Schema.object(
    properties: {
      'id': Schema.string(),
      'title': Schema.string(),
      'situation': Schema.string(),
      'vietnamesePhrase': Schema.string(),
      'englishPhrase': Schema.string(
          description:
              'The English translation of the Vietnamese phrase, matching the tone.'),
      'difficulty': Schema.enumString(enumValues: ['A1-A2', 'B1-B2', 'C1-C2']),
      'hints': Schema.object(
        properties: {
          'level1': Schema.string(),
          'level2': Schema.string(),
          'level3': Schema.string(),
        },
        requiredProperties: ['level1', 'level2', 'level3'],
      ),
    },
    requiredProperties: [
      'id',
      'title',
      'situation',
      'vietnamesePhrase',
      'englishPhrase',
      'difficulty',
      'hints',
    ],
  );

  // ---------- Story ----------
  static final story = Schema.object(
    properties: {
      'id': Schema.string(),
      'topic': Schema.string(),
      'situation': Schema.string(
          description: 'Detailed background of the conversation scene.'),
      'agentName': Schema.string(
          description: 'Name of the character the AI is playing.'),
      'openingLine': Schema.string(
          description: 'The first sentence spoken by the Agent (in English).'),
      'openingLineVietnamese': Schema.string(
          description: 'Vietnamese translation of the opening line.'),
      'difficulty': Schema.enumString(enumValues: ['A1-A2', 'B1-B2', 'C1-C2']),
      'hints': Schema.object(
        properties: {
          'level1': Schema.string(
              description: 'Hint about the meaning/intent of how to reply.'),
          'level2':
              Schema.string(description: 'Hint about the sentence structure.'),
          'level3':
              Schema.string(description: 'Hint about key vocabulary to use.'),
        },
        requiredProperties: ['level1', 'level2', 'level3'],
      ),
    },
    requiredProperties: [
      'id',
      'topic',
      'situation',
      'agentName',
      'openingLine',
      'openingLineVietnamese',
      'difficulty',
      'hints',
    ],
  );

  // ---------- Story Reply Hints (per-turn) ----------
  /// Generated fresh for each AI turn to help the user compose a reply. Same
  /// level1/level2/level3 shape as the opening-turn hints on [story], but
  /// standalone so it can be invoked on-demand without re-running the whole
  /// scenario generation.
  static final storyReplyHints = Schema.object(
    properties: {
      'level1':
          Schema.string(description: 'Meaning / intent hint in Vietnamese.'),
      'level2':
          Schema.string(description: 'English structure hint with a skeleton.'),
      'level3': Schema.string(
          description: 'Key vocabulary (English) with Vietnamese meanings.'),
    },
    requiredProperties: ['level1', 'level2', 'level3'],
  );

  // ---------- Simple Vietnamese translation ----------
  /// On-demand English → Vietnamese translation used by the chat screens when
  /// the user taps "Translate" on an AI bubble.
  static final vietnameseTranslation = Schema.object(
    properties: {
      'translation': Schema.string(
          description: 'Natural Vietnamese translation of the input text.'),
    },
    requiredProperties: ['translation'],
  );

  // ---------- Tone Translation ----------
  static Schema _toneEntry() => Schema.object(
        properties: {
          'text': Schema.string(),
          'quote': Schema.string(
              description: 'Vietnamese translation of this tone.'),
        },
        requiredProperties: ['text', 'quote'],
      );

  static final translation = Schema.object(
    properties: {
      'original': Schema.string(),
      'tones': Schema.object(
        properties: {
          'formal': _toneEntry(),
          'friendly': _toneEntry(),
          'informal': _toneEntry(),
          'conversational': _toneEntry(),
        },
        requiredProperties: [
          'formal',
          'friendly',
          'informal',
          'conversational'
        ],
      ),
      'grammarAnalysis': Schema.object(
        description: 'Grammar analysis of the original sentence.',
        properties: {
          'sentence':
              Schema.string(description: 'The original sentence analyzed.'),
          'components': Schema.array(
            items: Schema.object(
              properties: {
                'text': Schema.string(description: 'The word or phrase.'),
                'type': Schema.string(
                    description:
                        'Grammatical type (subject, verb, object, adjective, adverb, preposition, conjunction, other).'),
                'explanation': Schema.string(
                    description: 'Explanation of its role in the sentence.'),
              },
              requiredProperties: ['text', 'type', 'explanation'],
            ),
          ),
          'generalExplanation': Schema.string(
              description: 'Brief overall explanation of sentence structure.'),
        },
        requiredProperties: ['sentence', 'components', 'generalExplanation'],
      ),
    },
    requiredProperties: ['original', 'tones', 'grammarAnalysis'],
  );

  // ---------- Dictionary ----------
  static final dictionary = Schema.object(
    properties: {
      'partOfSpeech': Schema.string(),
      'pronunciation': Schema.string(),
      'explanation': Schema.string(),
      'examples': Schema.array(
        items: Schema.object(
          properties: {
            'en': Schema.string(),
            'vn': Schema.string(),
          },
          requiredProperties: ['en', 'vn'],
        ),
      ),
      'synonyms': Schema.array(items: Schema.string()),
      'contextUsage': Schema.string(),
    },
    requiredProperties: [
      'partOfSpeech',
      'pronunciation',
      'explanation',
      'examples',
      'synonyms',
      'contextUsage',
    ],
  );

  // ---------- Reverse Dictionary (Describe a Word) ----------
  static final reverseDictionary = Schema.object(
    properties: {
      'candidates': Schema.array(
        items: Schema.object(
          properties: {
            'en': Schema.string(),
            'vn': Schema.string(),
            'definition': Schema.string(),
            'confidence': Schema.number(),
            'example': Schema.string(),
          },
          requiredProperties: [
            'en',
            'vn',
            'definition',
            'confidence',
            'example',
          ],
        ),
      ),
    },
    requiredProperties: ['candidates'],
  );

  // ---------- Word Analysis ----------
  // Origin is informational — Gemini may not have a confident origin for
  // every word (especially native Germanic English roots). Keep it as a
  // declared property when withOrigin is true, but never require it: a
  // missing origin should never fail the whole analysis.
  static Schema _morpheme({bool withOrigin = false}) => Schema.object(
        properties: {
          'morpheme': Schema.string(),
          'meaning': Schema.string(),
          if (withOrigin) 'origin': Schema.string(),
        },
        requiredProperties: ['morpheme', 'meaning'],
      );

  static Schema _exampleEnVn() => Schema.object(
        properties: {
          'en': Schema.string(),
          'vn': Schema.string(),
        },
        requiredProperties: ['en', 'vn'],
      );

  static final wordAnalysis = Schema.object(
    properties: {
      'word': Schema.string(),
      'phonetic': Schema.string(),
      'partOfSpeech': Schema.string(
          description:
              'Part of speech — one of: "Noun", "Verb", "Adjective", "Adverb", "Phrasal Verb", "Idiom", "Expression", "Other".'),
      'definition': Schema.string(
          description:
              'Short English definition of the word — one concise sentence.'),
      'translation': Schema.string(),
      'morphology': Schema.object(
        properties: {
          'prefix': _morpheme(),
          'root': _morpheme(withOrigin: true),
          'suffix': _morpheme(),
          'equation': Schema.string(),
        },
        requiredProperties: ['root', 'equation'],
      ),
      'contextualEmbedding': Schema.object(
        properties: {
          'positiveExample': _exampleEnVn(),
          'neutralExample': _exampleEnVn(),
          'negativeExample': _exampleEnVn(),
          'collocations': Schema.array(items: Schema.string()),
        },
        requiredProperties: [
          'positiveExample',
          'neutralExample',
          'negativeExample',
          'collocations',
        ],
      ),
      'derivatives': Schema.object(
        properties: {
          'noun': Schema.string(),
          'verb': Schema.string(),
          'adjective': Schema.string(),
          'adverb': Schema.string(),
        },
        requiredProperties: [],
      ),
      'synonyms': Schema.array(items: Schema.string()),
      'antonyms': Schema.array(items: Schema.string()),
    },
    requiredProperties: [
      'word',
      'phonetic',
      'partOfSpeech',
      'definition',
      'translation',
      'morphology',
      'contextualEmbedding',
      'derivatives',
      'synonyms',
      'antonyms',
    ],
  );

  // ---------- Compare Words (Pro) ----------
  static Schema _comparisonEntry() => Schema.object(
        properties: {
          'word': Schema.string(),
          'phonetic': Schema.string(),
          'translation': Schema.string(
              description: 'Concise Vietnamese meaning of this word.'),
          'partOfSpeech': Schema.string(),
          'definition': Schema.string(
              description: 'Short English definition — 1 sentence.'),
          'register':
              Schema.enumString(enumValues: ['Formal', 'Neutral', 'Casual']),
          'connotation':
              Schema.enumString(enumValues: ['Positive', 'Neutral', 'Negative']),
          'example': _exampleEnVn(),
          'collocations': Schema.array(items: Schema.string()),
        },
        requiredProperties: [
          'word',
          'phonetic',
          'translation',
          'partOfSpeech',
          'definition',
          'register',
          'connotation',
          'example',
          'collocations',
        ],
      );

  static final wordComparison = Schema.object(
    properties: {
      'wordA': _comparisonEntry(),
      'wordB': _comparisonEntry(),
      'keyDifference': Schema.string(
          description:
              'One short paragraph explaining the headline nuance between the two words.'),
      'whenToUseA': Schema.string(
          description:
              'A single clear sentence describing when to pick the first word.'),
      'whenToUseB': Schema.string(
          description:
              'A single clear sentence describing when to pick the second word.'),
    },
    requiredProperties: [
      'wordA',
      'wordB',
      'keyDifference',
      'whenToUseA',
      'whenToUseB',
    ],
  );

  // ---------- Mind Map ----------
  static Map<String, Schema> _mindMapNodeProperties() => {
        'id': Schema.string(),
        'label': Schema.string(),
        'type': Schema.enumString(enumValues: ['topic', 'category', 'word']),
        'translation': Schema.string(),
        'partOfSpeech': Schema.string(),
        'phonetic': Schema.string(
          description:
              'IPA pronunciation in slashes for word nodes (e.g. "/ˈtræv.əl/"). Optional — return an empty string for topic/category nodes that are not single lexical items.',
        ),
        'context': Schema.string(),
      };

  // `phonetic` is intentionally NOT required: only word-type nodes carry an
  // IPA value, and forcing root/category nodes to populate it makes Gemini
  // either invent fake transcriptions or reject the schema entirely.
  static const List<String> _mindMapNodeRequired = [
    'id',
    'label',
    'type',
    'translation',
    'partOfSpeech',
    'context',
  ];

  static final mindMapRoot = Schema.object(
    properties: {
      ..._mindMapNodeProperties(),
      'children': Schema.array(
        items: Schema.object(
          properties: _mindMapNodeProperties(),
          requiredProperties: _mindMapNodeRequired,
        ),
      ),
    },
    requiredProperties: [..._mindMapNodeRequired, 'children'],
  );

  static final mindMapChildren = Schema.array(
    items: Schema.object(
      properties: _mindMapNodeProperties(),
      requiredProperties: _mindMapNodeRequired,
    ),
  );

  static final customNode = Schema.object(
    properties: {
      'status': Schema.enumString(enumValues: ['connected', 'unrelated']),
      'parentNodeId': Schema.string(
          description: 'The ID of the best parent node if connected.'),
      'message': Schema.string(description: 'Explanation if unrelated.'),
      'translation': Schema.string(),
      'partOfSpeech': Schema.string(),
      'phonetic': Schema.string(
          description: 'IPA transcription of the custom word, in slashes.'),
      'context': Schema.string(),
    },
    requiredProperties: ['status'],
  );

  // ---------- Exercises ----------
  static final exercises = Schema.array(
    items: Schema.object(
      properties: {
        'id': Schema.string(),
        'type': Schema.enumString(
            enumValues: ['fill-in-the-blank', 'sentence-construction']),
        'question': Schema.string(),
        'options': Schema.array(items: Schema.string()),
        'answer': Schema.string(),
        'hint': Schema.string(),
        'explanation': Schema.string(),
        'targetWord': Schema.string(),
      },
      requiredProperties: [
        'id',
        'type',
        'question',
        'answer',
        'explanation',
        'targetWord',
      ],
    ),
  );

  // ---------- Vocab Hub — Topic-based flashcard suggestions ----------
  static final topicFlashcards = Schema.object(
    properties: {
      'topic': Schema.string(description: 'Echoes the requested topic label.'),
      'items': Schema.array(
        items: Schema.object(
          properties: {
            'word': Schema.string(
                description:
                    'English headword or short phrase (at most 3 tokens).'),
            'phonetic':
                Schema.string(description: 'IPA wrapped in slashes.'),
            'partOfSpeech': Schema.string(
                description:
                    'One of: "Noun", "Verb", "Adjective", "Adverb", "Phrasal Verb", "Idiom", "Expression", "Other".'),
            'definition': Schema.string(
                description: 'Short English definition (≤ 18 words).'),
            'translation': Schema.string(
                description: 'Natural Vietnamese meaning (1-2 sentences).'),
            'example': Schema.object(
              properties: {
                'en': Schema.string(),
                'vn': Schema.string(),
              },
              requiredProperties: ['en', 'vn'],
            ),
          },
          requiredProperties: [
            'word',
            'phonetic',
            'partOfSpeech',
            'definition',
            'translation',
            'example',
          ],
        ),
      ),
    },
    requiredProperties: ['topic', 'items'],
  );
}
