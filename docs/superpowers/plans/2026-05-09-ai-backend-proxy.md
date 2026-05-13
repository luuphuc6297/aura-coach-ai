# AI Backend Proxy Migration

**Date:** 2026-05-09
**Status:** Critical for production launch — personal Gemini key cannot scale.
**Dependencies:** Subscription Phase A (QuotaEngine) — backend reuses the same engine for server-side enforcement.

## Problem

Mobile app currently calls Gemini directly with `GEMINI_API_KEY` shipped in `.env`. This breaks at production scale for 5 reasons:

1. **Quota collision** — Personal Gemini key shares quota across all users. ~1,500 free req/day, ~4M tokens/min on paid. App with 1k DAU at 20 calls/user/day = 20k req/day → instantly exhausts free tier and saturates paid tier mid-day.
2. **Single point of failure** — Google flagged the key (already happened 2026-05-09). Personal account suspension takes the entire app offline.
3. **No per-user accountability** — One abusive user can burn through everyone's quota. No way to attribute cost to a user, can't refund or rate-limit individuals.
4. **Compliance** — Personal Google account hasn't signed Data Processing Agreement. App Store reviewers reject apps that route user data through personal endpoints.
5. **Cost runaway** — Key leak → unbounded bill on personal credit card.

## Solution: Backend Proxy

Mobile app stops calling Gemini directly. All AI calls route through Firebase Cloud Functions that hold a service-account-scoped Gemini key.

### Request flow

```
Mobile App
  │ POST /grammar/evaluate
  │ Authorization: Bearer <Firebase ID token>
  │ Body: { exerciseId, userAnswer, topic }
  ▼
Cloud Function (Node.js / TypeScript)
  ├─ 1. Verify ID token → uid
  ├─ 2. QuotaEngine.consume(uid, 'grammar')
  │      └─ if exceeded → 429 Too Many Requests
  ├─ 3. Cache lookup (optional Phase 2)
  ├─ 4. Call Gemini with backend service account key
  ├─ 5. Log usage to Firestore (audit + analytics)
  └─ 6. Return JSON to mobile
  ▼
Mobile renders evaluation
```

## Phase 1 — Endpoint inventory

7 AI endpoints to migrate:

| Endpoint | Source method | Free quota | Pro quota |
|----------|---------------|------------|-----------|
| `POST /scenario/lesson` | `GeminiService.generateNextLesson` | 5 sessions/day | 30/day |
| `POST /story/turn` | `GeminiService.generateStoryTurn` | 3 sessions/day | 20/day |
| `POST /grammar/exercise` | `GrammarGeminiService.generateExercise` | 30/day | unlimited |
| `POST /grammar/evaluate` | `GrammarGeminiService.evaluateAnswer` | bundled with above | unlimited |
| `POST /vocab/analyze` | `GeminiService.generateWordAnalysis` | 3/day after 20-grant | 50/day |
| `POST /vocab/compare` | `GeminiService.generateWordComparison` | bundled | 50/day |
| `POST /vocab/describe` | `GeminiService.generateDescribeWord` | bundled | 50/day |
| `POST /mindmap/expand` | `GeminiService.expandMindMapNode` | locked (Pro only) | 10/day |
| `POST /illustration/generate` | image gen | locked (Pro only) | 5/day |

## Phase 2 — Backend stack

```
functions/
├── src/
│   ├── index.ts              # exports all triggers
│   ├── auth/
│   │   └── verifyToken.ts    # Firebase Auth middleware
│   ├── ai/
│   │   ├── client.ts         # Gemini SDK wrapper
│   │   ├── prompts/          # mirror of mobile's data/prompts/
│   │   │   ├── scenario.ts
│   │   │   ├── grammar.ts
│   │   │   └── vocab.ts
│   │   └── schemas.ts        # JSON schemas (mirror)
│   ├── quota/
│   │   └── consume.ts        # server-side quota engine
│   ├── handlers/
│   │   ├── scenario.ts       # /scenario/* handlers
│   │   ├── grammar.ts        # /grammar/* handlers
│   │   └── vocab.ts          # /vocab/* handlers
│   └── usage/
│       └── log.ts            # Firestore usage logger
├── package.json
└── tsconfig.json
```

**Key infra:**
- **Runtime:** Firebase Cloud Functions v2 (Node.js 20)
- **Language:** TypeScript (strict mode)
- **Region:** asia-southeast1 (Singapore — closest to VN users)
- **Memory:** 512MB default, 1GB for image gen
- **Timeout:** 60s (matches mobile's 60s expectation)
- **Concurrency:** 80 per instance (default)
- **Secrets:** Gemini API key in Firebase secret manager (`firebase functions:secrets:set GEMINI_BACKEND_KEY`)

## Phase 3 — Mobile refactor

Replace `GeminiService` direct calls with HTTPS calls to backend:

```dart
// Before
final result = await geminiService.generateWordAnalysis(word: word);

// After
final result = await backendApi.post('/vocab/analyze', body: {'word': word});
```

**New `BackendApi` class:**

```dart
class BackendApi {
  final FirebaseAuth _auth;
  final String _baseUrl; // e.g. https://asia-southeast1-aura-coach-ai.cloudfunctions.net

  Future<T> post<T>(String path, {required Map<String, dynamic> body, required T Function(Map<String, dynamic>) parser}) async {
    final token = await _auth.currentUser?.getIdToken();
    if (token == null) throw const UnauthorizedException();

    final response = await http.post(
      Uri.parse('$_baseUrl$path'),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      body: jsonEncode(body),
    ).timeout(const Duration(seconds: 60));

    if (response.statusCode == 429) throw const QuotaExceededException();
    if (response.statusCode == 401) throw const UnauthorizedException();
    if (response.statusCode != 200) throw BackendException(response.statusCode, response.body);

    return parser(jsonDecode(response.body));
  }
}
```

**Removed from mobile:**
- `flutter_dotenv` (no longer need `.env`)
- `google_generative_ai` package (backend has it, not mobile)
- `lib/data/gemini/` directory entirely
- `lib/data/prompts/` (moved to backend)

## Phase 4 — Cost & rate limiting

**Per-uid rate limit (Cloud Function middleware):**
- Sliding window: 100 req/min per uid
- Daily cap: 500 req/day for free, 2000 for Pro
- Enforced via Firestore counters atomically (consistent with QuotaEngine)

**Daily budget cap (org-level kill switch):**
- Cloud Function checks `users/_global/budget.todaySpend` before each call
- If exceeds $X/day → return 503 Service Unavailable
- Prevents runaway from misconfigured client or attack

**Cost monitoring:**
- Firestore `usage/{date}` aggregate per day
- Cloud Function logs token counts per call
- Daily Cloud Scheduler job aggregates → posts to Slack/email if anomaly

## Phase 5 — Migration sequence

1. **D1-2:** Bootstrap `functions/` with 1 endpoint (`/grammar/evaluate`) end-to-end. Smoke test from mobile via Postman + a feature-flag toggle in Dart.
2. **D3-4:** Add remaining grammar endpoints + scenario.
3. **D5:** Migrate vocab + story.
4. **D6:** Add rate limiting + budget cap + usage logger.
5. **D7:** Remove `GEMINI_API_KEY` from mobile `.env`. Verify mobile fails closed if backend unreachable.
6. **D8:** Deploy + smoke test on TestFlight.
7. **D9-10:** Monitor production for 3 days; tune rate limits.

## Phase 6 — Future-proofing

When user count > 10k, migrate from consumer Gemini API to **Vertex AI**:
- IAM-based auth (no API keys)
- Higher quotas, configurable per-region
- 99.9% SLA contract
- Required for enterprise / education sector compliance
- Pricing: nearly identical to consumer API at our scale

When latency matters more than cost, move from Cloud Functions → **Cloud Run**:
- Always-warm instances (no cold start)
- Same Node.js code with minor `package.json` change
- ~$30/month base cost vs Functions' pay-per-invocation

## Cost projections

**Phase 1 launch (1k MAU):**
- Token cost: ~$50/month (Pro users dominate due to higher quotas)
- Cloud Functions: $0 (free tier covers it)
- Firestore: $0 (free tier)
- Total: ~$50/month

**1 year (10k MAU):**
- Tokens: ~$500/month
- Functions: ~$5/month
- Firestore: ~$10/month
- Total: ~$515/month

**Revenue at 5% Pro conversion:**
- 10k × 5% = 500 Pro × $9.99 = $4,995/month
- Net margin: ~$4,480/month (~89%)

## Decision points still open

1. **Use Vertex AI from day 1 or migrate later?** — Vertex requires gcloud auth, more setup, higher minimum cost. Recommend defer to Phase 6.
2. **Bundle backend deploy with mobile release?** — Yes. Otherwise we ship a mobile binary that fails to call old endpoints.
3. **Caching strategy** — Skip in Phase 1, add in Phase 2. Most prompts are user-specific (their answers, their words) so cache hit rate likely <20%.
4. **Edge runtime?** — Cloudflare Workers vs Firebase Functions. Stick with Firebase for now (simpler stack, already in Firebase ecosystem).

## Open dependencies

- Subscription Phase A (QuotaEngine domain) — backend reuses the same logic. Build it Dart-first then port to TypeScript.
- Subscription Phase F (RevenueCat webhook) — already a Cloud Function. Bundle deployment.
- Cloud Functions billing enabled on `aura-coach-ai` Firebase project — Luu must upgrade to Blaze (pay-as-you-go) plan, free tier still applies.

## Risks

| Risk | Mitigation |
|------|-----------|
| Latency increase 200-500ms per call | Place Functions in asia-southeast1; rely on Cloud Run for hot endpoints later |
| Cold start on 1st request after idle (~3s) | Set min instances = 1 for high-traffic endpoints (~$5/month) |
| Backend down → entire app dead | Cloud Functions has 99.95% SLA; add status page; add offline cache for last-N exercises so user can keep practicing without network |
| Backend logic drift from mobile | Single source of truth for prompts in backend repo; mobile imports types via OpenAPI generation (deferred) |
| Cost overrun from abuse | Daily budget cap + per-uid rate limit (D6 of phase 5) |

## Out of scope (deferred to v1.1+)

- Multi-region deployment (US + EU + Asia)
- Streaming responses (Server-Sent Events for real-time chat feel)
- Function-side caching with semantic similarity (e.g. embeddings-based dedup)
- BYOK (bring your own key) for power users
- Vertex AI migration
- Edge runtime (Cloudflare Workers)
