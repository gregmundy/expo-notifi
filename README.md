# expo-notifi

**Expo-native push notification infrastructure.** Think of it as the message-handling and scheduling layer that sits between your application and the [Expo Push Service](https://docs.expo.dev/push-notifications/overview/) — the kind of tooling SendGrid offers for email, but built specifically for Expo's ticket/receipt model and field set.

> **Status:** under active development. This is a portfolio piece and a work in progress. Not production-ready yet.

## Why this exists

General-purpose notification platforms (OneSignal, Knock, Courier) treat Expo as one transport among many. Their Expo support tends to be a thin adapter: pass-through fields, no first-class modeling of Expo's two-phase ticket/receipt flow, no surfacing of Expo-specific error codes in the UI.

`expo-notifi` is the opposite — it's *only* Expo, and it's built around Expo's actual semantics:

- The [send → ticket → receipt](https://docs.expo.dev/push-notifications/sending-notifications/) lifecycle is the central abstraction, not an implementation detail.
- Every Expo error code is routed deliberately (`DeviceNotRegistered` closes the loop with the consumer; `MessageRateExceeded` triggers per-token backoff; `InvalidProviderToken` escalates to the operator).
- Expo's per-project rate limits, payload caps, and 24h receipt window are first-class operational concepts.
- The full Expo message field set is supported — including `interruptionLevel`, `richContent`, `collapseId`, `mutableContent`, channel IDs, and the rest.

## What it does (v1 scope)

**Send**
- Full Expo Push Service field parity (iOS + Android)
- Multi-recipient single message via Expo's native `to: [...]` fan-out
- Automatic chunking at 100 messages/request, gzip request compression
- Optional Enhanced Push Security via Expo access tokens
- Token-format validation, payload size enforcement (≤ 4 KiB)

**Schedule**
- One-shot scheduled sends (UTC or in the recipient's local timezone)
- Recurring schedules expressed as RFC 5545 RRULEs (`FREQ=WEEKLY;BYDAY=MO;BYHOUR=9` etc.)
- Per-recipient quiet-hours respected — sends inside a quiet window are deferred, not dropped
- Pause / resume / cancel scheduled and recurring sends
- Per-recipient timezone, locale, and metadata for personalization

**Recipients & topics**
- First-class recipient model: external ID, timezone, locale, opt-in topics
- One recipient → many tokens (devices), with insert-on-rotate to preserve history
- Topic subscriptions: target a topic, fan out to current subscribers at materialization time
- Outbound webhooks for token-death and notification lifecycle events
- Soft delete with a periodic hard-purge worker

**Reliability**
- Durable Postgres-backed delivery state — restarts are safe
- Per-error-code routing for tickets and receipts (the full list, not just success/failure)
- Automatic backoff + retry on transient failures; permanent-failure DLQ
- Idempotency keys (`Idempotency-Key` header) scoped per tenant
- Receipt polling honors Expo's 15-min minimum and 24h window

**Observability**
- `:telemetry` events for every state transition
- Real-time LiveView dashboard: send rate, queue depth, error rate, recent failures
- Streaming event log driven by Phoenix.PubSub
- Per-tenant audit trail backed by an append-only event table

**Multi-tenant**
- One deployment serves many consumer apps, isolated end-to-end
- Postgres Row-Level Security + an Ecto query helper (defense in depth)
- Per-tenant Expo access token (encrypted at rest), API keys, recipients, schedules

## Architecture at a glance

| Concern | Choice |
| --- | --- |
| Language / runtime | Elixir (OTP) |
| Web | Phoenix + LiveView |
| Persistence | Postgres + Ecto |
| Background work | Oban |
| HTTP client | Req |
| Recurrence | RFC 5545 RRULE |
| Tenant isolation | Postgres RLS + Ecto `Scope` query helper |

A few decisions worth calling out:

- **Deliveries are domain rows, not Oban jobs.** Workers query batches via `SELECT … FOR UPDATE SKIP LOCKED`. Oban runs the workers; the unit of work lives in Postgres. This keeps the per-message lifecycle queryable and makes restart/replay trivial.
- **Schedule fires materialize per-timezone-bucket.** A recurring schedule in recipient-local TZ fires once per distinct timezone present in subscribed recipients, not once globally. Quiet hours and DST are first-class.
- **Personalization uses an allow-listed interpolator**, not template eval. `{{recipient.first_name}}` resolves from `Recipient.metadata`. No code execution.

## Expo Push Service specs we operate against

For reference (and for grounding the design):

| Limit / behavior | Value |
| --- | --- |
| Send endpoint | `POST https://exp.host/--/api/v2/push/send` |
| Receipts endpoint | `POST https://exp.host/--/api/v2/push/getReceipts` |
| Messages per request | 100 max |
| Payload size | 4 KiB max |
| Project rate limit | 600 notifications/sec |
| Receipt poll delay | ≥ 15 min after send |
| Receipt retention | Cleared at 24h |
| Token format | `ExponentPushToken[...]` |
| Delivery semantics | At-least-once, no SLA |

Sources: [Expo push notifications overview](https://docs.expo.dev/push-notifications/overview/), [Sending notifications](https://docs.expo.dev/push-notifications/sending-notifications/), [Push notifications FAQ](https://docs.expo.dev/push-notifications/faq/).

## Roadmap

**v1 (in progress):** the scope above.

**v2 candidates:**
- Filter-style targeting (`metadata.country = "US" AND subscribed_to "alerts"`)
- Multi-project per tenant
- A/B testing / message variants
- Per-tenant strict-mode personalization (fail on missing keys)
- Prometheus / OpenTelemetry exporters
- JS/TS SDK

## License

TBD.
