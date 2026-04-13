# Aura Coach Mobile — Complete Business Flows

---

## Table of Contents

1. [System Architecture Overview](#1-system-architecture-overview)
2. [Authentication & Onboarding Flows](#2-authentication--onboarding-flows)
   - 2.1 Authentication (Google / Apple / Guest)
   - 2.2 Onboarding (Name + Avatar + Level → Topic Selection)
   - 2.3 Guest → Authenticated Migration
3. [Core AI Service Flows](#3-core-ai-service-flows)
   - 3.1 Gemini API Integration (14 Functions via Dart SDK)
   - 3.2 Retry & Fallback Strategy
   - 3.3 Response Parsing Pipeline
4. [Scenario Coach (Roleplay) Flow](#4-scenario-coach-roleplay-flow)
   - 4.1 Lesson Generation
   - 4.2 User Response → Evaluation
   - 4.3 Assessment Card Display (4 Sections)
   - 4.4 Difficulty Adjustment
   - 4.5 Progressive Hints (3 Levels)
   - 4.6 Direction Toggle (VN↔EN)
5. [Story Mode Flow](#5-story-mode-flow)
   - 5.1 Dialogue Selection (Search/Filter/Custom)
   - 5.2 Story Generation
   - 5.3 User Reply → Evaluation
   - 5.4 Continue Story / End & New Story
   - 5.5 Story-Specific UI Elements
6. [Tone Translator Flow](#6-tone-translator-flow)
   - 6.1 Input Text
   - 6.2 4 Tone Variations
   - 6.3 Audio Playback
   - 6.4 Save to Dictionary
7. [Vocab Hub Flow](#7-vocab-hub-flow)
   - 7.1 Overview Tab (Saved Items List)
   - 7.2 Word Analysis Tab
   - 7.3 Mind Map Tab
   - 7.4 Flashcards Tab (SM-2 Spaced Repetition)
   - 7.5 Exercises Tab
8. [Mind Map Flow](#8-mind-map-flow)
   - 8.1 Generate New Map
   - 8.2 Expand Nodes
   - 8.3 Add Custom Node
   - 8.4 Remove Node
   - 8.5 Persistence & Export
9. [Save to Dictionary Flow](#9-save-to-dictionary-flow)
   - 9.1 Long-press Text → Save
   - 9.2 Dictionary Enrichment
   - 9.3 SM-2 Review Scheduling
10. [Audio & Video Flows](#10-audio--video-flows)
    - 10.1 Text-to-Speech
    - 10.2 Video Generation
    - 10.3 Visualize Native Context
11. [Data Persistence Flow](#11-data-persistence-flow)
    - 11.1 Dual-Write Strategy (SharedPreferences + Supabase)
    - 11.2 Conversation History (Auto-save)
    - 11.3 Sync Indicator States
12. [Subscription & Usage Flow](#12-subscription--usage-flow)
    - 12.1 Tier Definitions (Free/Pro/Premium)
    - 12.2 Usage Tracking
    - 12.3 Usage Gate
    - 12.4 Upgrade Prompt UX
    - 12.5 In-App Purchase Flow
    - 12.6 Usage Dashboard in Profile
13. [Database Schema](#13-database-schema)
    - 13.1 Tables
    - 13.2 RLS Policies
    - 13.3 Indexes
14. [Navigation Map](#14-navigation-map)
    - 14.0 Bottom Navigation Bar
    - 14.1 Route Map
15. [Flutter Project Structure](#15-flutter-project-structure)
16. [Design System & Asset Reference](#16-design-system-reference)
17. [Clean Code Principles](#17-clean-code-principles)
18. [Cross-Cutting Concerns](#18-cross-cutting-concerns)
    - 18.1 Error Handling
    - 18.2 Loading States
    - 18.3 Offline Behavior
    - 18.4 Profile Management

---

## 1. System Architecture Overview

**High-Level Architecture:**
- **Frontend:** Flutter mobile app (iOS/Android) using Clean Architecture
- **Backend:** Supabase PostgreSQL database + Realtime API
- **AI Engine:** Google Gemini API (14 core functions via `google_generative_ai` Dart SDK — direct calls, no Edge Functions)
- **Authentication:** Supabase Auth (Google, Apple, Guest)
- **Storage:** SharedPreferences (local) + Supabase (cloud) + SecureStorage (credentials)
- **In-App Purchases:** Apple IAP + Google Play Billing

**Layered Architecture:**
```
Presentation Layer (UI/Navigation)
  ↓
Features Layer (Feature-specific logic)
  ↓
Domain Layer (Entities, Repositories, UseCases)
  ↓
Data Layer (Repositories, Datasources)
```

**Technology Stack:**
- Flutter 3.x + Dart
- Provider (state management)
- GoRouter (navigation)
- Supabase SDK + PostgreSQL
- Google Gemini API via `google_generative_ai` Dart SDK (direct calls, no backend proxy)
- Clay Design System (Fredoka logo, Nunito headings, Inter body)

---

## 2. Authentication & Onboarding Flows

### 2.1 Authentication (Google / Apple / Guest)

**Entry Point:** SplashScreen / AuthScreen

**OAuth Flow (Google/Apple):**
1. User taps "Sign in with Google/Apple"
2. Supabase SDK initiates OAuth redirect
3. User authenticates in browser/native WebView
4. Callback returns `user.id`, `user.email`, `user.identities`
5. Supabase session stored in SecureStorage
6. App redirects to OnboardingScreen if first-time user

**Guest Flow:**
1. User taps "Continue as Guest"
2. Supabase creates anonymous session
3. User can onboard but without auth persistence
4. All data stored locally in SharedPreferences
5. Option to "Sign Up Later" converts guest → authenticated

**Post-Authentication Check:**
```dart
// AuthProvider monitors Supabase session
final user = supabase.auth.currentUser;
if (user == null) → AuthScreen
if (user.isNewUser && !completedOnboarding) → OnboardingScreen
else → HomeScreen
```

### 2.2 Onboarding (Name + Avatar + Level → Topic Selection)

**Step 1: Profile Setup**
- Input: Full name
- Avatar Selection: 5 clay 3D animal avatars hosted on Cloudinary (cat, rabbit, penguin, fox, owl). See [`aura-coach-mobile-asset-registry.md` §1.4](./aura-coach-mobile-asset-registry.md) for full URLs and dimensions.
- Proficiency Level selection (3 CEFR tiers):

| Level | Title | Description |
|-------|-------|-------------|
| `A1-A2` | Beginner / Elementary | Basic phrases, everyday needs. Short sentences (5-8 words). |
| `B1-B2` | Intermediate | Travel, work, personal interests. Complex sentences, idioms. |
| `C1-C2` | Advanced / Mastery | Fluent, understands nuance. Native speed, abstract topics. |

- Save to `user_profiles` table

**Step 2: Topic & Interest Selection (16 Predefined Topics)**

| # | ID | Label | Icon |
|---|-----|-------|------|
| 1 | `travel` | Travel & Survival | Airplane |
| 2 | `business` | Business & Work | Briefcase |
| 3 | `social` | Socializing | Clinking Glasses |
| 4 | `daily` | Daily Life | House |
| 5 | `tech` | Technology | Laptop |
| 6 | `food` | Food & Dining | Steaming Bowl |
| 7 | `medical` | Medical & Health | Hospital |
| 8 | `shopping` | Shopping & Fashion | Shopping Bags |
| 9 | `entertainment` | Movies & Music | Clapper Board |
| 10 | `sports` | Sports & Fitness | Soccer Ball |
| 11 | `education` | Education & Academic | Graduation Cap |
| 12 | `environment` | Nature & Environment | Herb |
| 13 | `finance` | Money & Finance | Money Bag |
| 14 | `relationships` | Love & Relationships | Red Heart |
| 15 | `legal` | Law & Politics | Balance Scale |
| 16 | `property` | Housing & Real Estate | Key |

- Allow: Multiple selections (minimum 1)
- Custom Topics: User can add custom topics via text input
- Icons: Fluent Emoji icons via `fluentui_emoji_icon` package. See [`aura-coach-mobile-asset-registry.md` §2](./aura-coach-mobile-asset-registry.md) for per-topic icon mapping.
- Save to `user_progress` table with `selected_topics` array
- Set initial learning statistics to `0`

**Data Shape (user_profiles):**
```json
{
  "user_id": "uuid",
  "name": "string",
  "avatar_url": "string",
  "proficiency_level": "beginner|intermediate|advanced",
  "created_at": "timestamp",
  "updated_at": "timestamp"
}
```

### 2.3 Guest → Authenticated Migration

**Trigger:** User taps "Sign Up" while logged in as guest

**Process:**
1. Open OAuth flow (Google/Apple)
2. On successful auth, migrate local SharedPreferences data:
   - conversation_history (array)
   - saved_items (array)
   - mind_maps (array)
3. Create corresponding Supabase records
4. Clear local guest data
5. Persist auth token in SecureStorage

---

## 3. Core AI Service Flows

### 3.1 Gemini API Integration (14 Functions via Dart SDK)

**SDK:** `google_generative_ai` (Dart/Flutter) — direct API calls, NO Edge Functions, NO backend proxy.

**Model Constants (from web codebase — authoritative):**

| Constant | Model String | Tier | Use Case |
|----------|-------------|------|----------|
| `MODEL_FLASH` | `gemini-3-flash-preview` | Fast/cheap | Most text-based evaluations & generation |
| `MODEL_PRO` | `gemini-3.1-pro-preview` | Advanced reasoning | Story generation, story evaluation, dictionary |
| `MODEL_TTS` | `gemini-2.5-flash-preview-tts` | Audio output | Text-to-speech pronunciation |
| `MODEL_VEO` | `veo-3.1-fast-generate-preview` | Video generation | Scenario video clips |
| `MODEL_IMAGE` | `gemini-2.5-flash-image` | Image generation | Word illustrations |
| `MODEL_LIVE_AUDIO` | `gemini-2.5-flash-native-audio-preview` | Real-time audio | Live conversation mode |

**14 Core AI Functions — Correct Model Mapping:**

| # | Function | Model | Temperature | Input | Output | Quota |
|---|----------|-------|-------------|-------|--------|-------|
| 1 | `evaluateResponse` | **MODEL_FLASH** | 0.3 | user_input, lesson, direction | JSON: score, feedback, metrics | Daily |
| 2 | `evaluateStoryTurn` | **MODEL_PRO** | 0.4 | scenario, agent_message, user_reply | JSON: score, assessment | Daily |
| 3 | `evaluateQuizAnswer` | **MODEL_FLASH** | 0.4 | saved_item, user_answer | JSON: is_correct, explanation | Daily |
| 4 | `generateNextLesson` | **MODEL_FLASH** | 0.9 | previous_titles, level, topics | JSON: lesson, scenario | Daily |
| 5 | `generateStoryScenario` | **MODEL_PRO** | 0.8 | level, topic, previous_titles, custom_context | JSON: story, dialogue, context | Daily |
| 6 | `generateToneTranslations` | **MODEL_FLASH** | 0.7 | text | JSON: 4 tone variations | Daily |
| 7 | `generateDictionaryExplanation` | **MODEL_PRO** | 0.7 | phrase, context | JSON: explanation, examples, partOfSpeech | Lifetime (Free: 5) |
| 8 | `generateWordAnalysis` | **MODEL_FLASH** | 0.2 | word, context | JSON: etymology, morphology, examples | Daily |
| 9 | `generateTopicMindMap` | **MODEL_FLASH** | 0.2 | topic, level | JSON: nodes hierarchy | Daily |
| 10 | `expandMindMapNode` | **MODEL_FLASH** | 0.2 | node_label, root_topic, level | JSON: children nodes | Daily |
| 11 | `analyzeCustomNode` | **MODEL_FLASH** | 0.1 | custom_word, mind_map_data | JSON: analysis, suggestions | Daily |
| 12 | `generateNativeSpeech` | **MODEL_TTS** | — | text | Base64 audio (WAV) | Daily |
| 13 | `generateScenarioVideo` | **MODEL_VEO** | — | situation, phrase | Video blob URL (MP4) | Daily (Pro/Premium: 3/5/day) |
| 14 | `generateExercises` | **MODEL_FLASH** | 0.7 | saved_items[], count | JSON: exercises with answers | Daily |
| — | `generateIllustration` | **MODEL_IMAGE** | — | word, context | Base64 image (PNG) | Daily |
| — | Live Conversation | **MODEL_LIVE_AUDIO** | — | real-time audio stream | real-time audio response | Daily |

> **Note:** `generateIllustration` and Live Conversation are bonus functions beyond the 14 core.
> Story-related functions use **MODEL_PRO** for advanced reasoning quality.
> Most evaluation/generation functions use **MODEL_FLASH** for speed.

**Flutter SDK Integration Pattern:**
```dart
// lib/data/datasources/gemini_datasource.dart
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiDatasource {
  static const _modelFlash = 'gemini-3-flash-preview';
  static const _modelPro = 'gemini-3.1-pro-preview';
  static const _modelTts = 'gemini-2.5-flash-preview-tts';
  static const _modelVeo = 'veo-3.1-fast-generate-preview';
  static const _modelImage = 'gemini-2.5-flash-image';

  late final GenerativeModel _flashModel;
  late final GenerativeModel _proModel;

  GeminiDatasource(String apiKey) {
    _flashModel = GenerativeModel(model: _modelFlash, apiKey: apiKey);
    _proModel = GenerativeModel(model: _modelPro, apiKey: apiKey);
  }

  /// Evaluate roleplay response — uses FLASH for speed
  Future<AssessmentResult> evaluateResponse(
    String userInput,
    LessonContext lesson,
    String direction,
  ) async {
    final prompt = buildEvaluatePrompt(userInput, lesson, direction);
    final response = await _callWithRetry(
      () => _flashModel.generateContent(
        [Content.text(prompt)],
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          temperature: 0.3,
        ),
      ),
    );
    return AssessmentResult.fromJson(parseJsonResponse(response));
  }

  /// Generate story scenario — uses PRO for quality
  Future<StoryScenario> generateStory(
    CEFRLevel level,
    String topic,
  ) async {
    final prompt = buildStoryPrompt(level, topic);
    final response = await _callWithRetry(
      () => _proModel.generateContent(
        [Content.text(prompt)],
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          temperature: 0.8,
        ),
      ),
    );
    return StoryScenario.fromJson(parseJsonResponse(response));
  }
}
```

**API Key Storage (Flutter):**
```dart
// API key stored in flutter_secure_storage, NOT hardcoded
// Loaded from environment at build time via --dart-define
const geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');
// Or from SecureStorage for runtime configuration
```

### 3.2 Retry & Fallback Strategy

**Retry Logic (Exponential Backoff — matches web codebase pattern):**
```dart
// lib/core/utils/retry_operation.dart
// Retry on transient errors: 429 (rate limit), 503 (unavailable), RESOURCE_EXHAUSTED
Future<T> retryOperation<T>(
  Future<T> Function() operation, {
  int maxRetries = 3,
  Duration initialDelay = const Duration(seconds: 1),
}) async {
  Object? lastError;
  var delay = initialDelay;

  for (var i = 0; i < maxRetries; i++) {
    try {
      return await operation();
    } catch (error) {
      lastError = error;
      final msg = error.toString();
      final isTransient = msg.contains('429') ||
          msg.contains('RESOURCE_EXHAUSTED') ||
          msg.contains('quota') ||
          msg.contains('503') ||
          msg.contains('UNAVAILABLE');

      if (isTransient) {
        await Future.delayed(delay);
        delay *= 2; // exponential backoff
      } else {
        rethrow; // non-transient error, fail immediately
      }
    }
  }
  throw lastError!;
}
```

**Fallback Data (API Quota Exhaustion):**
```dart
// For each function, maintain mock response
const fallbackEvaluationResult = {
  'score': 75,
  'feedback': 'Great effort! Focus on pronunciation.',
  'metrics': {
    'grammar': 85,
    'vocabulary': 70,
    'pronunciation': 65,
    'fluency': 80,
  },
  'betterWayToSayIt': 'Alternative phrasing...',
};

// On API error, return fallback + show "Offline Mode" banner
if (apiError) {
  return FallbackDataRepository.get(functionName);
}
```

### 3.3 Response Parsing Pipeline

**Generic Parser Pattern:**
```dart
abstract class ResponseParser<T> {
  T parse(Map<String, dynamic> rawResponse);

  // Validation
  T _validate(T data) {
    // Check required fields
    // Check data types
    // Return or throw ParseException
  }
}

// Usage
final evaluationParser = EvaluationResponseParser();
final result = evaluationParser.parse(geminiResponse);
```

**Example: EvaluationResponseParser**
```dart
class EvaluationResponseParser extends ResponseParser<EvaluationResult> {
  @override
  EvaluationResult parse(Map<String, dynamic> json) {
    return EvaluationResult(
      score: (json['score'] as num?)?.toInt() ?? 0,
      feedback: json['feedback'] as String? ?? '',
      metrics: GrammarMetrics.fromJson(json['metrics'] as Map),
      betterWayToSayIt: json['betterWayToSayIt'] as String? ?? '',
      toneVariations: (json['toneVariations'] as List?)
          ?.map((e) => ToneVariation.fromJson(e))
          .toList() ?? [],
    );
  }
}
```

---

## 4. Scenario Coach (Roleplay) Flow

### 4.1 Lesson Generation

**Trigger:** User selects "Scenario Coach" from Home, chooses topic & difficulty

**Process:**
1. Call `generate-lesson` with:
   ```json
   {
     "topic": "business-meeting",
     "level": "intermediate",
     "direction": "en-to-vn" // or "vn-to-en"
   }
   ```
2. Gemini returns lesson structure:
   ```json
   {
     "lessonId": "uuid",
     "scenario": "You're in a job interview...",
     "nativeLanguageContext": "[Vietnamese translation/explanation]",
     "vocabularyPrep": ["interview", "qualifications"],
     "expectedResponses": ["I'm interested in...", "My experience..."],
     "difficulty": "intermediate"
   }
   ```
3. Display LessonCard showing scenario, vocab prep, direction indicator
4. Save lesson_id to conversation_history
5. Await user response

### 4.2 User Response → Evaluation

**Trigger:** User submits response via Chat screen

**Process:**
1. User types response in chat input
2. Taps "Submit" or sends message
3. Show loading spinner ("Evaluating...")
4. Call `evaluate-roleplay-response`:
   ```json
   {
     "userResponse": "[text user typed]",
     "expectedDirection": "en-to-vn",
     "context": {
       "scenario": "[original scenario]",
       "nativeLanguageContext": "[prep info]"
     }
   }
   ```
5. Parse response into EvaluationResult
6. Show AssessmentCard (4 sections)
7. Save assessment to conversation_history with timestamp

### 4.3 Assessment Card Display (4 Sections)

**Shared component:** Used by BOTH Roleplay and Story Mode (same `AssessmentCard` widget).

**AssessmentResult data shape (from `types/index.ts:109-130`):**
```dart
class AssessmentResult {
  final int score;                  // 1-10
  final int accuracyScore;          // 1-10
  final int naturalnessScore;       // 1-10
  final int complexityScore;        // 1-10
  final String feedback;
  final String? correction;
  final String? betterAlternative;
  final String analysis;
  final String grammarAnalysis;
  final String vocabularyAnalysis;
  final List<Improvement> improvements;
  final String userTone;
  final AlternativeTones alternativeTones; // formal, friendly, informal, conversational
  final String? nextAgentReply;            // Story Mode only: agent continuation
  final String? nextAgentReplyVietnamese;  // Story Mode only: translation
}
```

**Section 1: Header**
- Score circle (1-10, color-coded: red < 5, yellow 5-8, green 8+)
- Badge (e.g., "Great Grammar!" / "Good Flow")
- Short `feedback` snippet ("Nice sentence structure!")
- `correction` — shows corrected version if different from user input
- `betterAlternative` — expandable "Better Way to Say It"

**Section 2: RadarScore + Detailed Metrics**

**RadarScore Component (from `components/shared/RadarScore.tsx`):**
- **3-axis radar chart** (NOT 5 axes):
  - **Accuracy** (`accuracyScore`, 0-10)
  - **Naturalness** (`naturalnessScore`, 0-10)
  - **Complexity** (`complexityScore`, 0-10)
- Uses Recharts `RadarChart` on web → Flutter equivalent: `fl_chart` or custom `CustomPainter`
- Teal fill (#4ed9cc) with 40% opacity, teal stroke
- Renders inside a responsive container

```dart
// Flutter implementation for RadarScore
// Uses fl_chart package or CustomPainter
class RadarScore extends StatelessWidget {
  final AssessmentResult assessment;

  // Renders 3-point radar: Accuracy, Naturalness, Complexity
  // Each axis 0-10 scale
  // Fill: tealClay.withOpacity(0.4), stroke: tealClay
}
```

- `grammarAnalysis` — text breakdown of grammar points
- `vocabularyAnalysis` — vocabulary usage feedback
- `improvements` — structured list of errors/suggestions with specific fixes

**Section 3: Tone Variations**
- 4 tone alternatives from `alternativeTones`: Formal, Friendly, Informal, Conversational
- Each shows alternative version of their response
- `userTone` — detected tone of user's original input
- Play audio (generateNativeSpeech → MODEL_TTS)
- Save button (→ saved_items + dictionary)

**Section 4: Footer (Mode-Specific)**
- Roleplay: "Easier" / "Same Difficulty" / "Harder" buttons
- Story: "Continue Story" / "End & New Story" buttons (uses `nextAgentReply` + `nextAgentReplyVietnamese`)

### 4.4 Difficulty Adjustment (Easier/Same/Harder)

**Trigger:** User taps difficulty button in AssessmentCard footer

**Process:**
1. Update lesson difficulty in conversation_history
2. Call `generate-lesson` with new difficulty
3. Show transition screen ("Loading next scenario...")
4. Display new LessonCard
5. Reset chat input, awaiting new response

**Difficulty Levels:** Beginner < Intermediate < Advanced

### 4.5 Progressive Hints (3 Levels)

**Trigger:** User taps "Need Help?" or "Hint" during scenario

**Process:**
1. **Hint Level 1:** Vocab words related to scenario
2. **Hint Level 2:** Grammar structure ("Use past tense + modal verb")
3. **Hint Level 3:** Complete example sentence (same scenario, different speaker)

**Implementation:**
```dart
// In lesson_context, pre-compute hints
const hints = [
  "Vocabulary to use: interview, qualifications, experience",
  "Grammar hint: Try conditional + present perfect (e.g., 'If I were...')",
  "Example: 'I'd appreciate the opportunity to contribute to your team.'"
];

// Show one hint at a time, track hint_count in conversation_history
```

### 4.6 Direction Toggle (VN↔EN)

**Trigger:** User taps language toggle icon in lesson header

**Process:**
1. Switch `expectedDirection` (en-to-vn ↔ vn-to-en)
2. Regenerate lesson with new direction (call `generate-lesson`)
3. Update scenario display (swap native/target language positions)
4. Clear conversation history for this lesson (or offer "Keep previous responses")
5. Reset chat, await new response

---

## 5. Story Mode Flow

### 5.1 Dialogue Selection (Search/Filter/Custom)

**Entry Point:** Story Mode card on Home screen

**Screen: Dialogue List**
- Search bar (full-text search on story title + characters)
- Filter buttons: By topic (Business, Travel, Casual, etc.), By difficulty
- Pre-defined stories (20-30 curated dialogues)
- Custom Story button ("Create New Story")

**Pre-defined Story Metadata:**
```json
{
  "storyId": "uuid",
  "title": "Ordering at a Restaurant",
  "topic": "casual",
  "difficulty": "beginner",
  "characters": ["Waiter", "Customer"],
  "duration": "5-10 min",
  "thumbnail": "url"
}
```

**Custom Story Creation:**
1. User taps "Create New Story"
2. Input: Story theme (what's the situation?)
3. Choose 1-2 characters
4. Set difficulty
5. Call `generate-story` with inputs
6. Gemini generates dialogue + context
7. Save to user-defined list (stored locally + Supabase)

### 5.2 Story Generation

**Trigger:** User selects a story (pre-defined or custom)

**Process:**
1. Call `generate-story`:
   ```json
   {
     "topic": "restaurant-ordering",
     "level": "beginner",
     "characters": ["Waiter", "Customer"],
     "customContext": "[optional user input]"
   }
   ```
2. Response structure:
   ```json
   {
     "storyId": "uuid",
     "initialDialogue": "[Waiter: 'Welcome! What can I get you?']",
     "characters": {
       "Waiter": { "personality": "friendly", "tone": "casual" },
       "Customer": { "role": "you", "background": "tourist" }
     },
     "storyContext": "[Situation: You're at a restaurant......]",
     "nextCharacterTurn": "Customer"
   }
   ```
3. Display Story Chat screen with character context
4. Show first dialogue line
5. Await user response as "Customer"

### 5.3 User Reply → Evaluation (SAME AssessmentCard as Roleplay)

**Process:**
1. User types reply in Chat input
2. Call `evaluate-story-turn`:
   ```json
   {
     "userReply": "[text user typed]",
     "storyContext": "[full story state]",
     "expectedCharacter": "Customer",
     "characterPersonality": {...}
   }
   ```
3. Parse into EvaluationResult
4. Display AssessmentCard (identical to Roleplay's 4 sections)
5. Save turn to conversation_history with storyId

### 5.4 Continue Story / End & New Story

**Section 4 Footer (Story-Specific):**
- "Continue Story" button:
  - Generate next NPC turn
  - Show NPC response + new prompt for user
  - Increment turn_count
- "End & New Story" button:
  - Mark story as completed
  - Save final assessment to story_progress
  - Return to Story List
  - Show "Story Completed!" badge

### 5.5 Story-Specific UI Elements

**Sticky Context Header:**
- Character images/names (left side)
- Story title (center)
- Progress indicator (turn count, e.g., "Turn 3/8")
- Context toggle (expand/collapse story background)

**Context Panel (Bottom Sheet):**
- Story background ("You're a tourist in Vietnam...")
- Character personality traits
- Cultural notes (if applicable)
- Vocab glossary for this story

---

## 6. Tone Translator Flow

### 6.1 Input Text

**Entry Point:** "Tone Translator" card on Home screen

**Screen: Tone Input**
- Large text area ("Enter English text to translate into different tones")
- Placeholder: "I'm very interested in this opportunity..."
- Character counter (max 500 chars)
- Tone Translator button

### 6.2 4 Tone Variations (Formal/Friendly/Informal/Conversational)

**Trigger:** User enters text and taps "Translate"

**Process:**
1. Call `generateToneTranslations` (MODEL_FLASH, temp 0.7):
   ```dart
   final result = await geminiDatasource.generateToneTranslations(userInputText);
   ```
2. Gemini returns `TranslationResult` (actual shape from `types/index.ts`):
   ```json
   {
     "original": "I'm really interested in this opportunity.",
     "tones": {
       "formal": {
         "text": "Tôi rất quan tâm đến cơ hội này.",
         "quote": "I am highly interested in this opportunity."
       },
       "friendly": {
         "text": "Tôi thích lắm cơ hội này!",
         "quote": "I really like this opportunity!"
       },
       "informal": {
         "text": "Ê tôi khoái vụ này.",
         "quote": "Hey I'm into this thing."
       },
       "conversational": {
         "text": "Tôi chắc chắn thích vụ này đó.",
         "quote": "I'm definitely into this one."
       }
     },
     "grammarAnalysis": {
       "sentence": "I'm really interested in this opportunity.",
       "components": [
         { "text": "I", "type": "subject", "explanation": "First person singular pronoun" },
         { "text": "'m", "type": "verb", "explanation": "Contraction of 'am' (linking verb)" },
         { "text": "really", "type": "adverb", "explanation": "Intensifier modifying 'interested'" },
         { "text": "interested", "type": "adjective", "explanation": "Past participle used as adjective" },
         { "text": "in", "type": "preposition", "explanation": "Required preposition after 'interested'" },
         { "text": "this opportunity", "type": "object", "explanation": "Noun phrase — object of preposition" }
       ],
       "generalExplanation": "Simple present sentence using 'be + interested in' pattern. The adverb 'really' intensifies the adjective."
     }
   }
   ```
3. Display 4 tone cards in vertical list
4. Display Grammar Analysis panel in ContextPanel (side panel on web, bottom sheet on mobile)

**Grammar Analysis UI (from `ContextPanel.tsx`):**
- Shows sentence with each `GrammarComponent` color-coded by type:
  - Subject → blue, Verb → green, Object → orange, Adjective → purple, Adverb → cyan, Preposition → pink, Conjunction → yellow, Other → gray
- Each component shows its `text`, `type` badge, and `explanation`
- Top: original `sentence` + `generalExplanation`

**`GrammarComponent` type (from `types/index.ts:132-136`):**
```dart
class GrammarComponent {
  final String text;
  final String type; // 'subject' | 'verb' | 'object' | 'adjective' | 'adverb' | 'preposition' | 'conjunction' | 'other'
  final String explanation;
}
```

### 6.3 Audio Playback (generate-speech)

**Trigger:** User taps speaker icon on tone card

**Process:**
1. Call `generate-speech`:
   ```json
   {
     "text": "[tone variation result]",
     "tone": "[tone name]",
     "language": "vi"
   }
   ```
2. Stream audio file (MP3 URL)
3. Show audio player UI:
   - Play/pause button
   - Progress slider
   - Duration display
   - Playback speed selector (0.75x, 1.0x, 1.25x, 1.5x)

### 6.4 Save to Dictionary

**Trigger:** User taps "Save" button on tone card

**Process:**
1. Check usage quota: Free tier (5 saves/day), Pro (15/day), Premium (unlimited)
2. If quota exceeded, show upgrade prompt
3. Otherwise, save to saved_items table:
   ```json
   {
     "userId": "uuid",
     "type": "tone-variation",
     "originalText": "...",
     "tone": "formal",
     "savedText": "Tôi rất quan tâm đến cơ hội này.",
     "audioUrl": "...",
     "savedAt": "timestamp"
   }
   ```
4. Show confirmation ("Saved to My Learning Hub!")
5. Add to Vocab Hub → Overview tab

---

## 7. Vocab Hub Flow

### 7.1 Overview Tab (Saved Items List)

**Screen: Saved Items**
- List of all saved words, phrases, tone variations
- Sort: By date saved, By frequency, By type
- Filter: Words, Phrases, Tone Variations, Flashcards
- Search bar
- Item card shows:
  - Original text + translation/tone
  - Save date
  - Review count
  - Next review date (if in spaced repetition)
  - Delete button

**Data Shape (saved_items):**
```json
{
  "itemId": "uuid",
  "userId": "uuid",
  "type": "word|phrase|tone-variation",
  "originalText": "string",
  "savedText": "string (translation/enrichment)",
  "audioUrl": "string (optional)",
  "createdAt": "timestamp",
  "nextReviewAt": "timestamp (SM-2)",
  "reviewCount": "integer",
  "difficulty": "easy|medium|hard"
}
```

**Item Actions:**
- **Delete:** Remove from saved_items
- **Edit:** Update saved text
- **Practice (→ Roleplay):** Generate a focused roleplay lesson from a saved item

### 7.1.1 Practice Item Flow (Saved Item → Roleplay Lesson)

**Source:** `useSavedItemsManager.ts:62-85` → `handlePracticeItem()`

**Trigger:** User taps "Practice" button on a saved item card in Vocab Hub

**Process:**
1. Close Saved Items modal/sheet
2. Switch chat mode to `roleplay`
3. Set session as started
4. Generate a new lesson focused on the saved item's `correction` field:
   ```dart
   // The saved item becomes the topic for a targeted roleplay
   final focusTopic = 'Practicing: "${savedItem.correction}"';
   final newLesson = await generateNextLesson(
     previousLessonTitles,
     userLevel,        // e.g., 'A1-A2'
     [focusTopic],     // topics array with single focused topic
   );
   ```
5. Add the new lesson to generated lessons list
6. Clear messages and start fresh conversation with this lesson
7. User is now in a full Roleplay session practicing their saved word/phrase

**UX Flow:**
```
Vocab Hub → Overview Tab → Saved Item Card
  → [Practice] button
  → Loading spinner ("Generating practice lesson...")
  → Chat Roleplay Screen with lesson focused on saved word
  → Normal roleplay flow (evaluate, hints, assessment)
```

**Why this matters:** Bridges passive vocabulary (saved items) with active practice (roleplay). Users can immediately practice words they've saved from Tone Translator, Dictionary, or Story Mode.

### 7.2 Word Analysis Tab

**Trigger:** User taps on a saved word item

**Screen: Word Analysis**
1. **Word Header:** Word + pronunciation + part of speech
2. **Definition:** Primary meaning + 2-3 alternate meanings
3. **Etymology:** Word origin + related words
4. **Examples:** 3-5 usage examples
5. **Collocation:** Common phrases ("take advantage", "do damage")
6. **Morphology:** Prefix/root/suffix breakdown

**Data Source:**
- Generated via `generate-word-analysis` at save time
- Cached in saved_items table (analysis_json field)
- Refreshable via "Refresh Analysis" button

### 7.3 Mind Map Tab

**Trigger:** User taps Mind Map tab

**Screen: Mind Map View**
1. Display mind map centered on selected word
2. Node hierarchy:
   - Center: Word (emerald color)
   - Level 1: Categories (blue) - e.g., "Synonyms", "Related Concepts"
   - Level 2: Related words (violet) - e.g., individual synonym variants
3. Layout: BuchheimWalker (tree layout)
4. Interaction:
   - Tap node → Expand (load children)
   - Tap node → "Details" bottom sheet (definition + usage)
   - Long-press → "Remove Node" (delete from map)
   - Pinch-zoom with InteractiveViewer
5. "Add Custom Node" button (bottom-right) → Input dialog

**Mind Map Data (mind_maps table):**
```json
{
  "mapId": "uuid",
  "userId": "uuid",
  "rootWord": "advantage",
  "nodes": [
    {
      "nodeId": "uuid",
      "label": "advantage",
      "depth": 0,
      "color": "#10b981",
      "children": ["node-2", "node-3"]
    },
    {
      "nodeId": "uuid",
      "label": "Synonyms",
      "depth": 1,
      "color": "#3b82f6",
      "children": ["node-4", "node-5", "node-6"]
    }
  ],
  "createdAt": "timestamp",
  "lastUpdated": "timestamp"
}
```

### 7.4 Flashcards Tab (SM-2 Spaced Repetition)

**Screen: Flashcard Review**
1. Display flashcard (word → tap to flip → translation)
2. User rates response: "Again" (easy), "Hard", "Good", "Easy"
3. SM-2 Algorithm calculates next review interval:
   ```
   if (rating === "again") interval = 1 day
   else if (rating === "hard") interval = 3 days
   else if (rating === "good") interval = nextInterval * 1.3
   else if (rating === "easy") interval = nextInterval * 1.5
   ```
4. Save updated next_review_at to saved_items
5. Show progress (e.g., "4/20 cards today", "Streak: 5 days")
6. "Study All" vs "Study Due" mode toggle

**Implementation:**
```dart
class FlashcardProvider extends ChangeNotifier {
  List<SavedItem> get dueCards => items
    .where((item) => item.nextReviewAt.isBefore(DateTime.now()))
    .toList();

  void rateCard(SavedItem item, String rating) {
    final interval = SM2Algorithm.calculate(
      easeFactor: item.sm2EaseFactor,
      interval: item.sm2Interval,
      rating: rating,
    );
    item.nextReviewAt = DateTime.now().add(interval);
    updateItem(item);
  }
}
```

### 7.5 Exercises Tab

**Screen: Exercises List**
1. Display exercise cards for saved words
2. Exercise types:
   - Fill-in-the-blank
   - Multiple choice
   - Pronunciation (compare user voice to native audio)
   - Collocation matching
3. Tap exercise → Start quiz
4. Show question + options
5. User selects answer
6. Check correctness via `evaluate-quiz-answer`
7. Show explanation + next question
8. Track score per exercise

**Exercise Generation:**
```dart
// On saving a word, optionally generate exercises
final exercises = await aiRepository.generateExercises(
  word: word,
  proficiencyLevel: userLevel,
);
// Save to saved_items.exercisesJson
```

---

## 8. Mind Map Flow

### 8.1 Generate New Map

**Trigger:** User taps "Generate Mind Map" (from Vocab Hub or Lesson)

**Process:**
1. Input: Root word/topic + depth (2-4 levels)
2. Call `generate-mind-map`:
   ```json
   {
     "topic": "advantage",
     "depth": 3,
     "context": "[optional - where word came from]"
   }
   ```
3. Gemini returns:
   ```json
   {
     "mapId": "uuid",
     "rootWord": "advantage",
     "nodes": [
       {
         "nodeId": "1",
         "label": "advantage",
         "depth": 0,
         "definition": "...",
         "parentId": null,
         "children": ["2", "3", "4"]
       },
       {
         "nodeId": "2",
         "label": "Synonyms",
         "depth": 1,
         "definition": "Words with similar meaning",
         "parentId": "1",
         "children": ["5", "6", "7"]
       }
     ]
   }
   ```
4. Save to mind_maps table
5. Display MindMapView with BuchheimWalker layout

### 8.2 Expand Nodes

**Trigger:** User taps collapsed node (indicated by "+" icon)

**Process:**
1. Call `expand-mind-map`:
   ```json
   {
     "parentNodeId": "2",
     "parentLabel": "Synonyms",
     "expansionType": "detail" // or "examples", "usage"
   }
   ```
2. Gemini returns child nodes
3. Add children to mind_maps.nodes array
4. Animate node expansion in UI
5. Show new children branching from parent

### 8.3 Add Custom Node

**Trigger:** User taps "+" button → "Add Custom Node"

**Process:**
1. Show input dialog:
   - Input: Custom text (e.g., "my personal example")
   - Link to: Select parent node from tree
2. Call `analyze-custom-node`:
   ```json
   {
     "customText": "use advantage in a sentence I wrote",
     "parentTopic": "advantage",
     "context": "[lesson/word context]"
   }
   ```
3. Gemini returns analysis + suggested placement
4. Add custom node to mind_maps.nodes (mark as custom: true)
5. Update UI with new node in tree

### 8.4 Remove Node

**Trigger:** User long-presses node → "Remove"

**Process:**
1. Show confirmation dialog
2. Delete node from mind_maps.nodes
3. Remove all children of deleted node (cascade)
4. Update UI (re-render tree)

### 8.5 Persistence & Export

**Persistence:**
- Auto-save mind map to Supabase mind_maps table after each edit
- Also cache in SharedPreferences for offline access
- Show "Saving..." indicator during sync

**Export to PNG:**
```dart
// User taps "Share" on mind map
Future<void> exportAndShare() async {
  final boundary = globalKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
  final image = await boundary?.toImage(pixelRatio: 2.0);
  final byteData = await image?.toByteData(format: ImageByteFormat.png);
  final pngBytes = byteData?.buffer.asUint8List();

  // Share via share_plus
  await Share.shareXFiles(
    [XFile.fromData(pngBytes, name: 'mind-map.png')],
  );
}
```

---

## 9. Save to Dictionary Flow

### 9.1 Long-press Text → Save

**Trigger:** User long-presses any text in Chat screen (lesson, story, translator)

**Process:**
1. Show context menu with "Save to Dictionary" option
2. User taps "Save"
3. Check quota:
   - Free: 5 dictionary saves/day
   - Pro: 15 saves/day
   - Premium: unlimited
4. If quota exceeded, show upgrade prompt with option to "Continue as Free"
5. Proceed to enrichment

### 9.2 Dictionary Enrichment (generate-dictionary)

**Process:**
1. Extract selected text (word or phrase)
2. Extract context sentence
3. Call `generate-dictionary`:
   ```json
   {
     "word": "serendipity",
     "contextSentence": "It was pure serendipity that I found this book.",
     "language": "en"
   }
   ```
4. Gemini returns:
   ```json
   {
     "word": "serendipity",
     "partOfSpeech": "noun",
     "definition": "The occurrence of events by chance in a happy or beneficial way",
     "pronunciation": "/ˌserənˈdɪpɪti/",
     "examples": ["...", "..."],
     "synonyms": ["luck", "fortune"],
     "contextUsage": "Your context sentence shows...",
     "nativeLanguageTranslation": "sự trùng hợp may mắn"
   }
   ```
5. Save to saved_items table:
   ```json
   {
     "itemId": "uuid",
     "userId": "uuid",
     "type": "word",
     "originalText": "serendipity",
     "dictionaryData": "[full JSON from Gemini]",
     "audioUrl": "[from TTS if available]",
     "createdAt": "timestamp",
     "nextReviewAt": "timestamp (SM-2)"
   }
   ```
6. Show confirmation toast ("Saved to My Learning Hub!")

### 9.3 SM-2 Review Scheduling

**First Save:**
- Set `nextReviewAt = now + 1 day`
- Set `sm2Interval = 1`
- Set `sm2EaseFactor = 2.5` (default)

**After First Review:**
- User rates card (Again/Hard/Good/Easy)
- Calculate new interval:
  ```
  newEaseFactor = easeFactor + (0.1 - (5-rating) * (0.08 + (5-rating) * 0.02))
  if (newEaseFactor < 1.3) newEaseFactor = 1.3

  if (rating < 3) newInterval = 1 day
  else newInterval = previousInterval * newEaseFactor
  ```
- Update saved_items

---

## 10. Audio & Video Flows

### 10.1 Text-to-Speech (generate-speech)

**Trigger:** User taps speaker icon (Tone Translator, Assessment, Exercises)

**Request:**
```json
{
  "text": "I would appreciate the opportunity...",
  "tone": "formal",
  "language": "en",
  "speed": 1.0,
  "gender": "neutral" // or "male", "female"
}
```

**Response:**
```json
{
  "audioUrl": "https://storage.googleapis.com/audio-file.mp3",
  "durationMs": 3200
}
```

**UI Display:**
- Play/pause button
- Progress slider with current time / total duration
- Speed buttons (0.75x, 1.0x, 1.25x, 1.5x)
- Download button (optional)

### 10.2 Video Generation (generate-video)

**Trigger:** User taps "Generate Video" (Premium feature, limited to 5/day)

**Process:**
1. Check subscription tier:
   - Free: 0 videos/day
   - Pro: 3 videos/day
   - Premium: 5 videos/day
2. Check daily usage (tracking in usage_daily.video_count)
3. If quota exceeded, show upgrade prompt
4. Call `generate-video`:
   ```json
   {
     "text": "The quick brown fox jumps over the lazy dog",
     "scenario": "business-presentation",
     "style": "animated"
   }
   ```
5. Gemini returns:
   ```json
   {
     "videoUrl": "https://storage.googleapis.com/video.mp4",
     "durationSeconds": 15,
     "hasSubtitles": true
   }
   ```
6. Display video player with controls
7. Option to save/share video

### 10.3 Visualize Native Context

**Trigger:** User explores vocabulary/lesson and wants visual context

**Content:** Custom-generated visual explanations (via video or image)
- Example: "advantage" → animation showing two scenarios, one with and one without the advantage
- Helps with pronunciation and context understanding

---

## 11. Data Persistence Flow

### 11.1 Dual-Write Strategy (SharedPreferences + Supabase)

**Architecture:**
```
User Action
  ↓
Save to LocalDataSource (SharedPreferences) → Immediate response
  ↓
Queue to SyncQueue
  ↓
(Background) Sync to RemoteDataSource (Supabase)
  ↓
Mark as synced
```

**Implementation:**
```dart
class PersistenceProvider extends ChangeNotifier {
  final localSource = SharedPreferencesDataSource();
  final remoteSource = SupabaseDataSource();
  final syncQueue = SyncQueue();

  Future<void> saveItem(SavedItem item) async {
    // 1. Write locally
    await localSource.saveItem(item);
    notifyListeners();

    // 2. Queue remote sync
    await syncQueue.add(SyncOperation.saveItem(item));

    // 3. Background sync
    _backgroundSync();
  }

  Future<void> _backgroundSync() async {
    final operations = await syncQueue.pending;
    for (final op in operations) {
      try {
        await remoteSource.perform(op);
        await syncQueue.markCompleted(op.id);
      } on Exception catch (e) {
        await syncQueue.markFailed(op.id, e.toString());
      }
    }
  }
}
```

**Sync Indicator States:**
```dart
enum SyncState {
  synced,         // Green checkmark
  syncing,        // Spinner
  failed,         // Red exclamation
  offline,        // Offline icon
}

// Display in UI
widget.syncState == SyncState.synced ? Icon(Icons.check_circle, color: Colors.green) : ...
```

### 11.2 Conversation History (Auto-save)

**Data Model (conversation_history table):**
```json
{
  "conversationId": "uuid",
  "userId": "uuid",
  "mode": "roleplay|story|translator",
  "featureType": "scenario|story|translator|vocab|mindmap",
  "topic": "business-english",
  "difficulty": "intermediate",
  "turns": [
    {
      "turnId": "uuid",
      "speaker": "system|user",
      "text": "...",
      "timestamp": "2025-01-15T10:30:00Z",
      "assessment": {
        "score": 85,
        "feedback": "..."
      }
    }
  ],
  "totalScore": 85,
  "status": "in-progress|completed",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

**Auto-Save Trigger:**
- After each user message submission
- Every 30 seconds (if conversation active)
- On app backgrounding

**Implementation:**
```dart
class ConversationTracker extends ChangeNotifier {
  Timer? _autoSaveTimer;

  void startTracking(String conversationId) {
    _autoSaveTimer = Timer.periodic(Duration(seconds: 30), (_) {
      _saveConversation();
    });
  }

  Future<void> _saveConversation() async {
    await persistence.saveConversation(currentConversation);
  }
}
```

### 11.3 Sync Indicator States

**Visual Feedback:**
- During save: "Saving..." spinner (bottom-right corner)
- On success: Brief green checkmark
- On failure: Red error icon + "Retry" button
- Offline: "Offline Mode" banner (auto-hide when back online)

**User Experience:**
- App remains responsive during sync (non-blocking)
- Data available locally even if sync fails
- Retry mechanism with exponential backoff

---

## 12. Subscription & Usage Flow

### 12.1 Tier Definitions (Free/Pro/Premium)

**Tier Comparison:**

| Feature | Free | Pro | Premium |
|---------|------|-----|---------|
| **Daily Limits** |
| Roleplay/day | 5 | 15 | Unlimited |
| Story/day | 1 | 3 | Unlimited |
| Tone Translator/day | 5 | 15 | Unlimited |
| Mind Map/day | 1 | 3 | Unlimited |
| Audio/day (TTS) | 5 | 15 | Unlimited |
| Video/day | 0 | 3 | 5 |
| **Lifetime Limits** |
| Dictionary saves | 5 | Unlimited | Unlimited |
| Custom topics | 1 | 3 | Unlimited |

### 12.2 Usage Tracking (Daily + Lifetime)

**Data Model (usage_daily table):**
```json
{
  "usageId": "uuid",
  "userId": "uuid",
  "date": "2025-01-15",
  "roleplayCount": 3,
  "storyCount": 1,
  "translatorCount": 4,
  "mindmapCount": 1,
  "audioCount": 5,
  "videoCount": 2,
  "dictionaryCount": 2,
  "createdAt": "timestamp"
}
```

**Tracking Implementation:**
```dart
class UsageTrackingProvider extends ChangeNotifier {
  Future<void> trackUsage(String featureType) async {
    final today = DateTime.now();
    final usageRecord = await database.fetchUsageForDate(today);

    usageRecord.increment(featureType);
    await database.updateUsage(usageRecord);

    notifyListeners();
  }
}
```

### 12.3 Usage Gate (Before Quota-Limited Actions)

**Trigger:** User initiates action (e.g., "Start Roleplay")

**Process:**
```dart
// In feature handler
Future<void> startRoleplay() async {
  final canUse = await usageGate.canUseFeature(
    feature: 'roleplay',
    userId: currentUser.id,
  );

  if (!canUse) {
    showUsageExceededDialog(
      feature: 'Roleplay',
      tier: currentUser.tier,
      nextResetTime: DateTime.now().add(Duration(days: 1)),
      upgradePrompt: true,
    );
    return;
  }

  // Proceed with roleplay
  await startNewRoleplaySession();
}
```

**Usage Quota Check (Local + Supabase — NO Edge Function):**
```dart
// lib/domain/usecases/check_usage_quota.dart
// Quota checked locally first, then synced with Supabase
class CheckUsageQuota {
  final UsageRepository _usageRepo;

  Future<bool> call(String userId, String featureType) async {
    final user = await _usageRepo.getUserProfile(userId);
    final todayUsage = await _usageRepo.getTodayUsage(userId);

    const quotaConfig = {
      'Free': {'roleplay': 5, 'story': 1, 'translate': 10, 'dictionary': 5},
      'Pro': {'roleplay': 15, 'story': 3, 'translate': -1, 'dictionary': -1},
      'Premium': {'roleplay': -1, 'story': -1, 'translate': -1, 'dictionary': -1},
    };

    final limit = quotaConfig[user.tier]?[featureType] ?? 0;
    final used = todayUsage[featureType] ?? 0;

    return limit == -1 || used < limit;
  }
}
```

### 12.4 Upgrade Prompt UX

**Trigger:** Quota exceeded or feature unavailable

**Dialog: Upgrade Sheet**
1. **Header:** "Upgrade to Pro to unlock Roleplay"
2. **Tier Cards (3 columns):**
   - Free: "Current Plan" badge
   - Pro: "Most Popular" badge + price (69,000 VNĐ/month)
   - Premium: price (99,000 VNĐ/month)
3. Each card shows:
   - Tier name
   - Price + billing period
   - Feature list (checkmarks for included, X for excluded)
   - CTA button ("Upgrade" or "View Details")
4. **Footer:** "Compare Plans" link

**Dialog Actions:**
- "Upgrade": Proceed to purchase flow
- "Cancel": Return to app
- "View Details": Open full pricing page

### 12.5 In-App Purchase Flow

**Tech Stack:**
- iOS: Apple IAP (StoreKit 2 via Flutter package)
- Android: Google Play Billing (in-app-purchase package)
- Receipt Validation: Platform-native verification (StoreKit 2 / Google Play Billing library) — NO Edge Function

**Purchase UI Screen:**
```
┌─ Subscription Screen ────────────────┐
│                                      │
│ Free              Pro          Premium│
│ $0               $2.33/mo     $3.30/mo
│ ─────────────────────────────────   │
│ [  Pricing Cards (3 columns)  ]     │
│ ─────────────────────────────────   │
│                                      │
│           [Subscribe] button         │
│           [Restore Purchase]         │
│           [Terms of Service]         │
└──────────────────────────────────────┘
```

**Purchase Flow:**
1. User taps "Subscribe" on Pro card
2. System fetches available products from app store
3. Show loading spinner
4. User sees native purchase dialog (Apple/Google)
5. User confirms with Face ID/Touch ID
6. Receipt returned
7. Platform-native receipt verification (StoreKit 2 / Google Play Billing — handled by Flutter IAP package)
8. On verified purchase, update `user_profiles.subscription_tier` in Supabase
9. Update user tier to "Pro" in local state + Supabase
10. Show "Upgrade Successful!" confirmation
11. Reload tier limits in app

**Purchase Verification (Flutter-native, NO Edge Function):**
```dart
// lib/data/repositories/purchase_repository_impl.dart
// Uses in_app_purchase Flutter package — receipt verification handled
// by platform (StoreKit 2 server-to-server / Google Play RTDN)
class PurchaseRepositoryImpl implements PurchaseRepository {
  final SupabaseClient _supabase;
  final InAppPurchase _iap = InAppPurchase.instance;

  @override
  Future<bool> completePurchase(PurchaseDetails details) async {
    // Platform already verified receipt via StoreKit 2 / Play Billing
    if (details.status == PurchaseStatus.purchased) {
      // Update tier in Supabase
      await _supabase.from('user_profiles').update({
        'subscription_tier': _tierFromProductId(details.productID),
        'subscription_expires_at': _expirationFromPurchase(details),
      }).eq('user_id', _supabase.auth.currentUser!.id);

      await _iap.completePurchase(details);
      return true;
    }
    return false;
  }
}
```

### 12.6 Usage Dashboard in Profile

**Trigger:** User taps profile icon → "View Usage"

**Screen: Usage Dashboard**
1. **Current Tier Badge:** "Pro" with renewal date
2. **Progress Bars (Daily Limits):**
   - Roleplay: [====>  ] 8/15 used
   - Story: [====>  ] 2/3 used
   - Translator: [========] 15/15 used (quota exceeded)
   - Audio: [===>   ] 4/15 used
   - Video: [=>    ] 1/3 used
3. **Lifetime Stats:**
   - Dictionary Saves: 47/unlimited
   - Custom Topics: 2/3
4. **Reset Information:**
   - "Daily limits reset at midnight"
5. **Upgrade Button:**
   - "Upgrade to Premium" (if not Premium)

---

## 13. Database Schema

### 13.1 Tables

**user_profiles**
```sql
CREATE TABLE user_profiles (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id),
  name TEXT NOT NULL,
  avatar_url TEXT,
  proficiency_level TEXT CHECK (proficiency_level IN ('beginner', 'intermediate', 'advanced')),
  tier TEXT DEFAULT 'free' CHECK (tier IN ('free', 'pro', 'premium')),
  subscription_end_date TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- RLS
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own profile"
  ON user_profiles FOR SELECT
  USING (auth.uid() = user_id);
CREATE POLICY "Users can update own profile"
  ON user_profiles FOR UPDATE
  USING (auth.uid() = user_id);
```

**user_progress**
```sql
CREATE TABLE user_progress (
  progress_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES user_profiles(user_id),
  selected_topics JSONB DEFAULT '[]',
  custom_topics JSONB DEFAULT '[]',
  total_lessons_completed INTEGER DEFAULT 0,
  total_stories_completed INTEGER DEFAULT 0,
  average_score NUMERIC,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(user_id)
);

ALTER TABLE user_progress ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own progress"
  ON user_progress FOR SELECT
  USING (auth.uid() = user_id);
```

**conversation_history**
```sql
CREATE TABLE conversation_history (
  conversation_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES user_profiles(user_id),
  mode TEXT CHECK (mode IN ('roleplay', 'story', 'translator')),
  topic TEXT,
  difficulty TEXT,
  turns JSONB DEFAULT '[]',
  total_score NUMERIC,
  status TEXT DEFAULT 'in-progress' CHECK (status IN ('in-progress', 'completed')),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

ALTER TABLE conversation_history ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own history"
  ON conversation_history FOR SELECT
  USING (auth.uid() = user_id);
```

**saved_items**
```sql
CREATE TABLE saved_items (
  item_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES user_profiles(user_id),
  type TEXT CHECK (type IN ('word', 'phrase', 'tone-variation')),
  original_text TEXT NOT NULL,
  saved_text TEXT,
  audio_url TEXT,
  dictionary_data JSONB,
  exercises JSONB,
  review_count INTEGER DEFAULT 0,
  next_review_at TIMESTAMP,
  sm2_interval INTEGER DEFAULT 1,
  sm2_ease_factor NUMERIC DEFAULT 2.5,
  difficulty TEXT DEFAULT 'medium',
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

ALTER TABLE saved_items ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own saved items"
  ON saved_items FOR SELECT
  USING (auth.uid() = user_id);

CREATE INDEX idx_user_next_review ON saved_items(user_id, next_review_at);
```

**mind_maps**
```sql
CREATE TABLE mind_maps (
  map_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES user_profiles(user_id),
  root_word TEXT NOT NULL,
  nodes JSONB NOT NULL,
  is_custom BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

ALTER TABLE mind_maps ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own mind maps"
  ON mind_maps FOR SELECT
  USING (auth.uid() = user_id);
```

**usage_daily**
```sql
CREATE TABLE usage_daily (
  usage_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES user_profiles(user_id),
  date DATE NOT NULL,
  roleplay_count INTEGER DEFAULT 0,
  story_count INTEGER DEFAULT 0,
  translator_count INTEGER DEFAULT 0,
  mindmap_count INTEGER DEFAULT 0,
  audio_count INTEGER DEFAULT 0,
  video_count INTEGER DEFAULT 0,
  dictionary_count INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(user_id, date)
);

ALTER TABLE usage_daily ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own usage"
  ON usage_daily FOR SELECT
  USING (auth.uid() = user_id);

CREATE INDEX idx_user_date ON usage_daily(user_id, date DESC);
```

**purchase_receipts**
```sql
CREATE TABLE purchase_receipts (
  receipt_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES user_profiles(user_id),
  platform TEXT CHECK (platform IN ('ios', 'android')),
  receipt_data TEXT NOT NULL,
  tier TEXT NOT NULL,
  verified_at TIMESTAMP DEFAULT NOW(),
  created_at TIMESTAMP DEFAULT NOW()
);

ALTER TABLE purchase_receipts ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own receipts"
  ON purchase_receipts FOR SELECT
  USING (auth.uid() = user_id);
```

### 13.2 RLS Policies

All tables use auth.uid() isolation:
- SELECT: Users see only their own rows
- INSERT: Users can only insert with their own user_id
- UPDATE/DELETE: Users can only modify their own rows

**Admin bypass (optional):**
```sql
-- For admin service calls with service role key
CREATE POLICY "Service role bypasses RLS"
  ON user_profiles FOR ALL
  USING (auth.role() = 'authenticated')
  WITH CHECK (true);
```

### 13.3 Indexes

```sql
-- Performance indexes
CREATE INDEX idx_user_profiles_tier ON user_profiles(tier);
CREATE INDEX idx_conversation_history_user_mode ON conversation_history(user_id, mode);
CREATE INDEX idx_saved_items_user_type ON saved_items(user_id, type);
CREATE INDEX idx_usage_daily_user_date ON usage_daily(user_id, date DESC);
```

---

## 14. Navigation Map

### 14.0 Bottom Navigation Bar (Standard Mobile Pattern)

The app uses a persistent **Bottom Navigation Bar** on all top-level and tab-child screens. This is the primary navigation mechanism, following standard iOS/Android mobile patterns.

**3 Tabs:**

| Tab | Icon | Label | Route | Description |
|-----|------|-------|-------|-------------|
| 1 | 🏠 (Cloudinary: `home-icon`) | Home | `/home` | Mode selection grid + learning overview |
| 2 | 👤 (emoji fallback — `user_profile` not yet on Cloudinary) | User | `/user` | User profile, learning history, saved items |
| 3 | ⚙️ (Cloudinary: `setting-icon`) | Setting | `/setting` | App settings, subscription, usage dashboard |

> **Asset details:** See [`aura-coach-mobile-asset-registry.md` §1.5](./aura-coach-mobile-asset-registry.md) for Cloudinary nav icon URLs and dimensions.

**Bottom Nav Visibility Rules:**
- **Visible on:** Home, User, Setting (top-level tab screens)
- **Hidden on:** Chat screens (Roleplay, Story, Translator) — full-screen immersive experiences with their own AppBar + back button
- **Hidden on:** Auth, Onboarding, Splash — pre-authenticated screens
- **Hidden on:** Vocab Hub sub-screens, Mind Map — navigated from within features
- **Hidden on:** Upgrade Prompt, Context Panel — overlay bottom sheets

**Active State:** Active tab has teal-clay color, scale(1.15) icon, bold label, and a 20px indicator dot underneath.

**GoRouter Configuration:**

```dart
final appRouter = GoRouter(
  redirect: (context, state) async {
    final user = supabase.auth.currentUser;
    final isLoggingIn = state.matchedLocation == '/auth';

    if (user == null) {
      return isLoggingIn ? null : '/auth';
    }

    final hasCompletedOnboarding = await checkOnboarding(user.id);
    if (!hasCompletedOnboarding && state.matchedLocation != '/onboarding') {
      return '/onboarding';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => SplashScreen(),
    ),
    GoRoute(
      path: '/auth',
      builder: (context, state) => AuthScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => OnboardingScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => HomeScreen(),
      routes: [
        GoRoute(
          path: 'scenario/:lessonId',
          builder: (context, state) => ScenarioCoachScreen(
            lessonId: state.pathParameters['lessonId']!,
          ),
        ),
        GoRoute(
          path: 'story/:storyId',
          builder: (context, state) => StoryModeScreen(
            storyId: state.pathParameters['storyId']!,
          ),
        ),
        GoRoute(
          path: 'translator',
          builder: (context, state) => ToneTranslatorScreen(),
        ),
        GoRoute(
          path: 'vocab-hub',
          builder: (context, state) => VocabHubScreen(),
          routes: [
            GoRoute(
              path: 'word-analysis/:itemId',
              builder: (context, state) => WordAnalysisScreen(
                itemId: state.pathParameters['itemId']!,
              ),
            ),
            GoRoute(
              path: 'mind-map/:mapId',
              builder: (context, state) => MindMapScreen(
                mapId: state.pathParameters['mapId']!,
              ),
            ),
            GoRoute(
              path: 'flashcards',
              builder: (context, state) => FlashcardsScreen(),
            ),
          ],
        ),
        GoRoute(
          path: 'profile',
          builder: (context, state) => ProfileSheet(),
        ),
        GoRoute(
          path: 'conversation-history',
          builder: (context, state) => ConversationHistoryScreen(),
        ),
      ],
    ),
  ],
);
```

**Route Descriptions:**
- `/splash` → App startup, session check
- `/auth` → Login/signup screen
- `/onboarding` → Name, avatar, level, topics
- `/home` → Main dashboard (4 mode cards)
- `/home/scenario/:lessonId` → Roleplay chat
- `/home/story/:storyId` → Story dialogue chat
- `/home/translator` → Tone input + variations
- `/home/vocab-hub` → Saved items + tabs
- `/home/vocab-hub/word-analysis/:itemId` → Word details
- `/home/vocab-hub/mind-map/:mapId` → Mind map view
- `/home/vocab-hub/flashcards` → Spaced repetition review
- `/home/profile` → User settings + usage dashboard
- `/home/conversation-history` → Past conversations list

---

## 15. Flutter Project Structure

**Architecture:** Clean Architecture with feature-first organization.

```
aura_coach_mobile/
├── android/                          # Android platform
├── ios/                              # iOS platform
├── assets/
│   ├── icons/
│   │   ├── mode/                     # Clay-style mode icons (PNG @1x, @2x, @3x)
│   │   └── ui/                       # UI icons (Lucide fallbacks)
│   ├── avatars/                      # Clay 3D animal avatars (Cloudinary cached)
│   ├── fonts/                        # Fredoka, Nunito, Inter (bundled)
│   └── animations/                   # Lottie/Rive loading animations
│
├── lib/
│   ├── main.dart                     # App entry point
│   ├── app.dart                      # MaterialApp + GoRouter + Provider setup
│   │
│   ├── core/                         # Shared infrastructure
│   │   ├── constants/
│   │   │   ├── app_constants.dart    # Onboarding topics, levels, avatars
│   │   │   ├── api_constants.dart    # Gemini model strings, endpoints
│   │   │   └── quota_constants.dart  # Tier limits per feature
│   │   ├── theme/
│   │   │   ├── app_theme.dart        # ThemeData assembly
│   │   │   ├── app_colors.dart       # ClayUI color tokens
│   │   │   ├── app_typography.dart   # Fredoka / Nunito / Inter type scale
│   │   │   ├── app_shadows.dart      # Clay shadow presets
│   │   │   ├── app_spacing.dart      # 4px-based spacing tokens
│   │   │   └── app_radius.dart       # Border radius tokens
│   │   ├── utils/
│   │   │   ├── retry_operation.dart  # Exponential backoff (429, 503, RESOURCE_EXHAUSTED)
│   │   │   ├── json_parser.dart      # Safe JSON parse with fallback
│   │   │   └── date_utils.dart       # SM-2 interval calculations
│   │   ├── errors/
│   │   │   ├── app_exception.dart    # Base exception types
│   │   │   └── error_handler.dart    # Global error → user message mapping
│   │   └── network/
│   │       └── connectivity.dart     # Online/offline detection
│   │
│   ├── domain/                       # Business rules (no dependencies)
│   │   ├── entities/
│   │   │   ├── user_profile.dart
│   │   │   ├── lesson_context.dart
│   │   │   ├── story_scenario.dart
│   │   │   ├── assessment_result.dart
│   │   │   ├── translation_result.dart
│   │   │   ├── saved_item.dart
│   │   │   ├── mind_map_node.dart
│   │   │   ├── exercise.dart
│   │   │   └── subscription_tier.dart
│   │   ├── repositories/            # Abstract interfaces
│   │   │   ├── ai_repository.dart
│   │   │   ├── auth_repository.dart
│   │   │   ├── persistence_repository.dart
│   │   │   ├── purchase_repository.dart
│   │   │   └── usage_repository.dart
│   │   └── usecases/
│   │       ├── evaluate_response.dart
│   │       ├── generate_lesson.dart
│   │       ├── generate_story.dart
│   │       ├── check_usage_quota.dart
│   │       └── save_to_dictionary.dart
│   │
│   ├── data/                         # Implementation of domain interfaces
│   │   ├── datasources/
│   │   │   ├── gemini_datasource.dart      # GoogleGenAI SDK calls
│   │   │   ├── supabase_datasource.dart    # Supabase CRUD
│   │   │   └── local_datasource.dart       # SharedPreferences
│   │   ├── repositories/
│   │   │   ├── ai_repository_impl.dart
│   │   │   ├── auth_repository_impl.dart
│   │   │   ├── persistence_repository_impl.dart
│   │   │   ├── purchase_repository_impl.dart
│   │   │   └── usage_repository_impl.dart
│   │   └── models/                   # JSON serializable DTOs
│   │       ├── assessment_model.dart
│   │       ├── lesson_model.dart
│   │       ├── story_model.dart
│   │       └── saved_item_model.dart
│   │
│   ├── features/                     # Feature-first UI modules
│   │   ├── auth/
│   │   │   ├── screens/
│   │   │   │   ├── splash_screen.dart
│   │   │   │   ├── auth_screen.dart
│   │   │   │   └── onboarding_screen.dart
│   │   │   └── providers/
│   │   │       └── auth_provider.dart
│   │   │
│   │   ├── home/
│   │   │   ├── screens/
│   │   │   │   └── home_screen.dart         # Mode selection grid
│   │   │   └── widgets/
│   │   │       ├── mode_card.dart
│   │   │       └── stats_summary.dart
│   │   │
│   │   ├── roleplay/
│   │   │   ├── screens/
│   │   │   │   └── chat_roleplay_screen.dart
│   │   │   ├── widgets/
│   │   │   │   ├── assessment_card.dart     # Shared with story mode
│   │   │   │   ├── chat_bubble.dart
│   │   │   │   ├── chat_input.dart
│   │   │   │   └── progressive_hint.dart
│   │   │   └── providers/
│   │   │       └── roleplay_provider.dart
│   │   │
│   │   ├── story/
│   │   │   ├── screens/
│   │   │   │   ├── dialogue_list_screen.dart
│   │   │   │   └── chat_story_screen.dart
│   │   │   └── providers/
│   │   │       └── story_provider.dart
│   │   │
│   │   ├── translator/
│   │   │   ├── screens/
│   │   │   │   └── tone_translator_screen.dart
│   │   │   └── widgets/
│   │   │       └── tone_card.dart
│   │   │
│   │   ├── vocab/
│   │   │   ├── screens/
│   │   │   │   └── vocab_hub_screen.dart    # Tab controller: Overview/Analysis/MindMap/Flashcards/Exercises
│   │   │   ├── widgets/
│   │   │   │   ├── saved_item_card.dart
│   │   │   │   ├── word_analysis_view.dart
│   │   │   │   ├── flashcard_widget.dart
│   │   │   │   └── exercise_widget.dart
│   │   │   └── providers/
│   │   │       └── vocab_provider.dart
│   │   │
│   │   ├── mind_map/
│   │   │   ├── screens/
│   │   │   │   └── mind_map_screen.dart
│   │   │   └── widgets/
│   │   │       ├── mind_map_canvas.dart     # graphview rendering
│   │   │       └── node_detail_sheet.dart
│   │   │
│   │   ├── profile/
│   │   │   ├── screens/
│   │   │   │   └── profile_screen.dart
│   │   │   └── widgets/
│   │   │       ├── usage_dashboard.dart
│   │   │       └── settings_section.dart
│   │   │
│   │   └── subscription/
│   │       ├── screens/
│   │       │   └── subscription_screen.dart
│   │       └── providers/
│   │           └── subscription_provider.dart
│   │
│   └── shared/                       # Cross-feature shared widgets
│       ├── widgets/
│       │   ├── bottom_nav.dart              # 3-tab bottom navigation
│       │   ├── clay_card.dart               # Base clay-styled card
│       │   ├── clay_button.dart             # Primary/Secondary/Ghost buttons
│       │   ├── loading_indicator.dart       # Clay loading dots
│       │   ├── error_banner.dart            # Offline/error banner
│       │   ├── audio_player_widget.dart     # TTS playback
│       │   └── radar_score.dart             # Assessment radar chart
│       └── providers/
│           └── connectivity_provider.dart
│
├── test/                             # Tests mirror lib/ structure
│   ├── unit/
│   ├── widget/
│   └── integration/
│
├── pubspec.yaml
├── analysis_options.yaml
└── .env.example                      # GEMINI_API_KEY, SUPABASE_URL, SUPABASE_ANON_KEY
```

**Key Architecture Decisions:**
- `domain/` has ZERO external dependencies — pure Dart
- `data/` implements domain interfaces, depends on packages
- `features/` organized by screen/feature, each has screens + widgets + providers
- `shared/` for cross-feature widgets (BottomNav, ClayCard, etc.)
- `core/theme/` centralizes the full ClayUI design system

---

## 16. Design System Reference

> **Full design system specification:** See [`aura-coach-mobile-design-system.md`](./aura-coach-mobile-design-system.md)
> **Wireframes:** See [`aura-coach-mobile-wireframes.jsx`](./aura-coach-mobile-wireframes.jsx) (v5.3)
> **Asset Registry:** See [`aura-coach-mobile-asset-registry.md`](./aura-coach-mobile-asset-registry.md) — All Cloudinary icons, Fluent topic icons, Lucide UI icons, Flutter implementation

**Design System:** ClayUI v2.0 — Claymation-inspired, warm, tactile design language.

**Summary of tokens implemented in `core/theme/`:**

| File | Contents |
|------|----------|
| `app_colors.dart` | Surface (cream, clay-white, clay-beige), Text (warm-dark/muted/light), Accent (teal/purple/gold), Semantic (success/warning/error), Mode-specific accent mapping |
| `app_typography.dart` | Fredoka (logo only), Nunito (headings 600-800), Inter (body/data 400-700). Full type scale: logo → display → h1-h3 → body → bodySm → caption → label → data → button |
| `app_shadows.dart` | `shadow-clay` (3px 3px 0px #D4C9BB), hover, pressed, soft, card variants |
| `app_spacing.dart` | 4px base unit: space-1 (4px) through space-16 (64px) |
| `app_radius.dart` | sm (8px), md (12px), lg (20px), xl (28px), full (9999px) |
| `app_theme.dart` | Assembles ThemeData from all tokens above |

**Font Stack:**

| Token | Font | Weights | Role |
|-------|------|---------|------|
| `font-logo` | Fredoka | 600, 700 | Logo "AURA COACH" only |
| `font-heading` | Nunito | 600, 700, 800 | Titles, headings, card names |
| `font-body` | Inter | 400, 500, 600, 700 | Body text, data, captions, labels, scores, buttons |

**Component Library (Flutter widgets in `shared/widgets/`):**
- `ClayCard` — Standard / Interactive / Stat card variants
- `ClayButton` — Primary (teal), Secondary (purple border), Danger (error), Ghost, Pill
- `BottomNav` — 3-tab navigation (Home, User, Setting)
- `ChatBubble` — AI (clay-white + teal left border) / User (teal bg)
- `LoadingIndicator` — Clay bouncing dots (stop-motion feel)

---

## 17. Clean Code Principles

**These rules apply to ALL Flutter implementation code.**

### 17.1 Architecture Rules

- **Clean Architecture boundaries:** `domain/` NEVER imports from `data/` or `features/`
- **Dependency inversion:** Features depend on domain interfaces, not concrete implementations
- **Single Responsibility:** Each file does ONE thing — one widget, one provider, one use case
- **No God Widgets:** If a widget exceeds ~150 lines, extract sub-widgets

### 17.2 Naming Conventions

| Element | Convention | Example |
|---------|-----------|---------|
| Files | `snake_case` | `chat_roleplay_screen.dart` |
| Classes | `PascalCase` | `ChatRoleplayScreen` |
| Variables/Functions | `camelCase` | `evaluateResponse()` |
| Constants | `camelCase` (Dart convention) | `maxRetries`, `tealClay` |
| Providers | `PascalCase` + `Provider` suffix | `RoleplayProvider` |
| Entities | `PascalCase` (no suffix) | `AssessmentResult` |
| Repositories | `PascalCase` + `Repository` suffix | `AIRepository` (abstract), `AIRepositoryImpl` (concrete) |

### 17.3 Code Quality Rules

- **No unused imports** — enforced by `analysis_options.yaml`
- **No unused variables** — enforced by lint
- **English only** for code identifiers and comments (Vietnamese in user-facing strings only)
- **No explanatory comments** unless logic is genuinely non-obvious
- **Prefer `const` constructors** for stateless widgets
- **Prefer `final`** over `var` for local variables
- **Prefer named parameters** for functions with 3+ params

### 17.4 Complexity Reduction

- **Guard clauses / early returns** over deep nesting
- **Named predicate booleans:** `final isQuotaExceeded = usage >= limit;`
- **Small pure helpers** extracted for testability
- **No nested ternaries** — use `if/else` or extract to a method
- **Maximum 3 levels of widget nesting** before extracting sub-widget

### 17.5 State Management (Provider)

- **One Provider per feature** (e.g., `RoleplayProvider`, `VocabProvider`)
- **Providers hold UI state + call UseCases** — no direct API calls from providers
- **UseCases are thin** — orchestrate repository calls, return domain entities
- **No business logic in widgets** — widgets read state and dispatch actions only

### 17.6 Error Handling Pattern

```dart
// GOOD: Try/catch at provider level, expose error state to UI
class RoleplayProvider extends ChangeNotifier {
  String? _errorMessage;
  bool _isLoading = false;

  Future<void> submitResponse(String input) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _evaluateResponse(input);
      _assessment = result;
    } catch (e) {
      _errorMessage = ErrorHandler.getUserMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

### 17.7 Import Organization

```dart
// 1. Dart SDK
import 'dart:async';

// 2. Flutter SDK
import 'package:flutter/material.dart';

// 3. Third-party packages
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

// 4. Project imports (relative)
import '../../core/theme/app_colors.dart';
import '../../domain/entities/lesson_context.dart';
```

---

## 18. Cross-Cutting Concerns

### 18.1 Error Handling

**Error Categories:**
- **Network Errors:** No internet connection
- **API Errors:** Gemini API unavailable, rate limited
- **Auth Errors:** Session expired, permission denied
- **Validation Errors:** Invalid input, constraint violations
- **Database Errors:** Query failed, RLS violation

**Global Error Handler:**
```dart
class ErrorHandler {
  static String getUserMessage(Object error) {
    final msg = error.toString();

    // Gemini API errors (no Dio — direct SDK calls)
    if (msg.contains('429') || msg.contains('RESOURCE_EXHAUSTED')) {
      return "Rate limited. Please try again in a few minutes.";
    } else if (msg.contains('503') || msg.contains('UNAVAILABLE')) {
      return "AI service temporarily unavailable. Please try again.";
    }

    // Network errors
    if (error is SocketException) {
      return "No internet connection. Using offline mode.";
    }

    // Supabase errors
    if (error is PostgrestException) {
      if (error.code == '23505') { // Unique violation
        return "This item already exists.";
      }
    }
    return "Something went wrong. Please try again.";
  }

  static Future<void> handleError(Exception error, BuildContext context) async {
    final message = getUserMessage(error);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: Duration(seconds: 3)),
    );

    // Log error for analytics
    _logError(error);
  }
}
```

### 18.2 Loading States

**Loading State Machine:**
```dart
enum LoadingState { idle, loading, success, error }

class StateProvider extends ChangeNotifier {
  LoadingState _state = LoadingState.idle;
  String? _errorMessage;

  Future<void> performAction() async {
    _state = LoadingState.loading;
    notifyListeners();

    try {
      await _doWork();
      _state = LoadingState.success;
    } catch (e) {
      _state = LoadingState.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }
}

// UI renders based on state
if (state == LoadingState.loading) {
  return LoadingSpinner();
} else if (state == LoadingState.error) {
  return ErrorWidget(message: errorMessage);
} else if (state == LoadingState.success) {
  return SuccessContent();
}
```

### 18.3 Offline Behavior

**Offline Detection:**
```dart
class ConnectivityProvider extends ChangeNotifier {
  late StreamSubscription<ConnectivityResult> subscription;
  bool _isOnline = true;

  void init() {
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((result) {
      _isOnline = result != ConnectivityResult.none;
      notifyListeners();
    });
  }

  bool get isOnline => _isOnline;
}
```

**Offline Strategy:**
1. **Read Operations:** Serve from local cache
2. **Write Operations:** Queue locally, sync when online
3. **UI Indicator:** "Offline Mode" banner (red background)
4. **Disabled Features:** Real-time AI functions disabled until back online

### 18.4 Profile Management

**Profile Sheet (Bottom Sheet Modal):**
1. **User Header:**
   - Avatar image
   - Name
   - Current tier badge (Free/Pro/Premium)
2. **Statistics:**
   - Total lessons completed
   - Current streak
   - Total words learned
3. **Usage Dashboard:**
   - Daily quota progress bars
   - Reset time countdown
4. **Actions:**
   - Edit profile (name, avatar)
   - View subscription (manage, upgrade)
   - View usage statistics
   - Conversation history
   - Settings (notifications, language)
   - Logout
5. **Footer:**
   - App version
   - Privacy policy link
   - Terms of service link

---

## End of Document

**18 sections** covering the complete Aura Coach Mobile application: architecture, auth, AI integration (6 Gemini models), 4 learning modes, vocab system, persistence, subscriptions, database schema, navigation, Flutter project structure, design system, and clean code principles.

**Related files:**
- [`aura-coach-mobile-design-system.md`](./aura-coach-mobile-design-system.md) — Full ClayUI v2.0 design system specification
- [`aura-coach-mobile-wireframes.jsx`](./aura-coach-mobile-wireframes.jsx) — Interactive wireframes (v5.3)
- [`aura-coach-mobile-asset-registry.md`](./aura-coach-mobile-asset-registry.md) — Complete asset registry (Cloudinary clay icons, Fluent topic icons, Lucide UI icons, Flutter constants)

**Key Implementation Areas:**
- 14 Gemini API functions with retry/fallback
- 6 normalized database tables with RLS
- 3-tier subscription system with daily/lifetime quotas
- Dual-write persistence (local + cloud sync)
- 4 primary user modes (Scenario Coach, Story, Translator, Vocab Hub)
- Shared UI components (AssessmentCard, Chat Screen)
- Complete navigation structure with auth guards

For questions or updates, refer to the specific section numbers in this document.
