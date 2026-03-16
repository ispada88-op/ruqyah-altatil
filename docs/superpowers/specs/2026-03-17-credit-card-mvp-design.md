# Credit Card Optimizer MVP — Data, Logic & Architecture Design

**Date:** 2026-03-17  
**Scope:** Database schema, business logic (Minimum Payment Trap, Installment Tracker), and Flutter architecture. No UI. MCC tracking excluded for MVP.

---

## Task 1: Database Schema

### Recommendation: SQLite (drift) for MVP

- **Offline-first:** Works without network; critical for financial data.
- **Single source of truth:** One local DB; no sync conflicts for MVP.
- **Scalability path:** Later add sync (e.g. Firebase or custom backend) by syncing these tables.

**Alternative:** Firebase Firestore if you need real-time multi-device sync from day one. Schema below is normalized and maps 1:1 to Firestore collections/subcollections.

---

### 1.1 Core Tables (SQLite/drift)

All monetary amounts stored as **integer cents** (or smallest currency unit) to avoid floating-point errors. Dates as **ISO 8601 strings** or **Unix seconds** (int).

#### `cards`

| Column       | Type    | Constraints | Description |
|-------------|---------|-------------|-------------|
| id          | TEXT    | PK          | UUID v4 |
| name        | TEXT    | NOT NULL    | User-facing label (e.g. "Chase Sapphire") |
| total_limit | INTEGER | NOT NULL ≥0 | Total credit limit (cents) |
| annual_fee_amount | INTEGER | NOT NULL ≥0 | Annual fee (cents) |
| annual_fee_issue_date | TEXT  | NOT NULL    | Date of year when fee is charged (e.g. "03-15" or full date) |
| fx_markup_bps | INTEGER | NULL       | FX markup in basis points (e.g. 200 = 2%). Null = unknown |
| currency    | TEXT    | NOT NULL    | ISO 4217 (e.g. "USD") |
| created_at  | TEXT    | NOT NULL    | ISO 8601 |
| updated_at  | TEXT    | NOT NULL    | ISO 8601 |

**Derived (not stored):** `available_limit = total_limit - current_balance - sum(installments_reserved)`. Computed in app layer and cached/invalidated via Riverpod.

#### `statement_cycles`

| Column        | Type    | Constraints | Description |
|---------------|---------|-------------|-------------|
| id            | TEXT    | PK          | UUID v4 |
| card_id       | TEXT    | FK → cards  | |
| statement_date| TEXT    | NOT NULL    | Closing date (ISO date) |
| due_date      | TEXT    | NOT NULL    | Payment due (ISO date) |
| grace_days    | INTEGER | NOT NULL ≥0 | Days from statement_date to due_date |
| closing_balance | INTEGER| NOT NULL ≥0 | Balance at closing (cents) |
| min_payment_pct | INTEGER| NOT NULL    | Min payment as % (e.g. 5 for 5%) |
| apr_bps       | INTEGER | NOT NULL    | APR in basis points (e.g. 1899 = 18.99%) |
| status        | TEXT    | NOT NULL    | "open" \| "paid" \| "overdue" |
| created_at    | TEXT    | NOT NULL    | |
| updated_at    | TEXT    | NOT NULL    | |

**Indexes:** `(card_id, statement_date DESC)`, `(card_id, due_date)` for liquidity/upcoming due queries.

#### `installment_plans`

| Column           | Type    | Constraints | Description |
|------------------|---------|-------------|-------------|
| id               | TEXT    | PK          | UUID v4 |
| card_id          | TEXT    | FK → cards  | |
| total_amount     | INTEGER | NOT NULL >0 | Total plan amount (cents) |
| monthly_payment  | INTEGER | NOT NULL >0 | Per-month installment (cents) |
| remaining_amount | INTEGER | NOT NULL ≥0 | Remaining to pay (cents) |
| num_installments | INTEGER | NOT NULL >0 | Total number of installments |
| remaining_installments | INTEGER | NOT NULL ≥0 | Left to pay |
| start_date       | TEXT    | NOT NULL    | When plan started (ISO date) |
| next_due_date    | TEXT    | NOT NULL    | Next installment due (ISO date) |
| status           | TEXT    | NOT NULL    | "active" \| "completed" \| "cancelled" |
| created_at       | TEXT    | NOT NULL    | |
| updated_at       | TEXT    | NOT NULL    | |

**Reserved credit:** For available limit we use `total_amount` (or `remaining_amount`) to reserve the full (or remaining) plan amount from the card's available limit. Monthly fraction is added to the *upcoming statement's due amount* in logic, not stored here (computed when building "amount due" for a cycle).

#### `card_balances` (optional but recommended)

| Column     | Type    | Constraints | Description |
|------------|---------|-------------|-------------|
| card_id    | TEXT    | PK, FK      | One row per card |
| balance    | INTEGER | NOT NULL ≥0 | Current statement/balance (cents) |
| updated_at | TEXT    | NOT NULL    | |

Use this to avoid scanning all statements for "current" balance; update when user records payment or new statement.

---

### 1.2 Freemium (in-app or backend)

- **Free tier:** Enforce max 3 cards in app logic; basic statement/due alerts; basic utilization (e.g. >30% warning).
- **Premium:** Unlimited cards; installment tracking; Min Payment Trap; FX Exposer.

Store tier in local config or remote: e.g. `user_subscription` table or SharedPreferences key `subscription_tier` ("free" | "premium"). Enforce in repositories before insert (cards count) and before calling premium features.

---

### 1.3 Firebase Mapping (if chosen)

- `users/{userId}/cards/{cardId}` → cards row
- `users/{userId}/statement_cycles/{cycleId}` with `cardId` field
- `users/{userId}/installment_plans/{planId}` with `cardId` field
- Row-Level Security: `auth.uid == userId` for all reads/writes.

---

## Task 2: Core Business Logic (Dart)

### 2.1 Minimum Payment Trap Calculator

**Inputs:**  
- `balanceCents` (int), `aprBps` (int), `minPaymentPercent` (int, e.g. 5), optional `monthlyPaymentCents` (fixed extra payment).

**Output:**  
- Total interest paid (cents), number of months to pay off, optional month-by-month breakdown.

**Formula (simplified industry-style minimum):**  
- Min payment = max(flat minimum, e.g. $25, or `minPaymentPercent%` of balance).  
- Monthly interest = `balance * (aprBps/10000) / 12`.  
- Principal payment = payment - interest.  
- Iterate until balance ≤ 0; sum interest, count months.

**Efficiency:** Single loop, O(months). Use integer cents throughout; avoid `double` for money. Expose a pure function e.g. `MinimumPaymentTrapResult runTrap(int balanceCents, int aprBps, int minPaymentPercent, {int? fixedExtraCents})`.

### 2.2 Installment Tracker (Available Limit & Statement Impact)

**Reserved credit (available limit):**  
- For each card: `available_limit = total_limit - current_balance - sum(active_installments.total_amount)` (or use `remaining_amount` for a more conservative reserve).  
- When a plan is added/updated/removed, recompute and notify (e.g. Riverpod invalidate).

**Statement / due amount:**  
- For a given statement cycle, "amount due" = closing_balance for that cycle + sum of **this cycle’s installment slice** for each active plan.  
- Installment slice for a cycle: if `next_due_date` falls within the cycle’s period (statement_date → next statement_date), add `monthly_payment` to that cycle’s due amount.  
- Logic: function that takes a `StatementCycle` and list of `InstallmentPlan` and returns `dueAmountCents` (cycle balance + installment portions due in that period).

**Efficiency:**  
- Reserved credit: one sum over active installments per card; O(n) small n.  
- Due amount: filter plans whose `next_due_date` is in range; O(plans).  
- No heavy math; keep functions pure and testable.

---

## Task 3: Flutter Architecture Outline

### 3.1 Layers

- **Models:** Immutable Dart classes (e.g. `CardProfile`, `StatementCycle`, `InstallmentPlan`) with `fromJson`/`toJson` and (if using drift) `fromRow`/`toCompanion`.
- **Repositories:** Single responsibility per entity. `CardRepository`, `StatementCycleRepository`, `InstallmentPlanRepository`. They talk to DB (drift) or Firebase. All writes go through repos; repos enforce freemium (e.g. card count).
- **State (Riverpod):**  
  - **Providers for data:** `cardListProvider` (async list of cards), `statementCyclesProvider(cardId)`, `installmentPlansProvider(cardId)`.  
  - **Computed / family:** `availableLimitProvider(cardId)` that depends on: card, balance, and active installments for that card. When any of these change, provider recomputes.  
  - **Single source of truth:** Card list and balances/installments loaded from DB; `availableLimitProvider` is derived only (no separate stored “available limit” in DB).

### 3.2 Keeping Available Limit Synced

1. **Derive, don’t store:** Available limit = `total_limit - balance - sum(installment_reserved)` per card.  
2. **Dependency graph:**  
   - `availableLimitProvider(cardId)` = async provider that:  
     - reads `ref.watch(cardProvider(cardId))`,  
     - `ref.watch(cardBalanceProvider(cardId))`,  
     - `ref.watch(activeInstallmentPlansProvider(cardId))`,  
     - then computes and returns one value.  
3. **Invalidation:** Any mutation that changes balance or installments (e.g. add payment, add/update/complete installment) calls `ref.invalidate(cardBalanceProvider(cardId))` or `ref.invalidate(activeInstallmentPlansProvider(cardId))`, which causes `availableLimitProvider(cardId)` to recompute.  
4. **Optional:** A single `cardsSummaryProvider` that returns list of cards with precomputed `availableLimit` for list UIs, all derived from the same base data.

### 3.3 File Layout (concise)

```
lib/credit_card/
  models/
    card_profile.dart
    statement_cycle.dart
    installment_plan.dart
    minimum_payment_trap_result.dart
  logic/
    minimum_payment_trap.dart   # Pure functions
    installment_tracker.dart    # Reserved credit + due amount
  repository/
    card_repository.dart
    statement_cycle_repository.dart
    installment_plan_repository.dart
  provider/
    card_providers.dart        # cardList, card(cardId), availableLimit(cardId)
    statement_providers.dart
    installment_providers.dart
```

### 3.4 Freemium in Flow

- `CardRepository.createCard()`: before insert, check card count; if free tier and count >= 2, throw or return `Result.freeLimitReached`.  
- Premium features (installment CRUD, trap simulation, FX exposer): guard in provider or service layer with `subscriptionProvider`; if free, return empty or "upgrade" result.

---

## Summary

| Deliverable | Content |
|-------------|--------|
| **Schema** | SQLite (drift) tables: `cards`, `statement_cycles`, `installment_plans`, optional `card_balances`; integer cents; indexes for card + dates. |
| **Logic** | Min Payment Trap: iterative simulator (interest + months). Installment: reserved credit = sum(plan amounts); due amount = cycle balance + installment slices due in cycle. |
| **Architecture** | Models → Repos → Riverpod; available limit as derived provider from card + balance + installments; invalidation on any mutation. |

No UI code; ready for implementation plan and TDD for logic and repos.
