-- Credit Card Optimizer MVP — SQLite schema.
-- Monetary amounts in integer cents. Dates ISO 8601 (TEXT).

-- Cards
CREATE TABLE IF NOT EXISTS cards (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  total_limit INTEGER NOT NULL CHECK (total_limit >= 0),
  annual_fee_amount INTEGER NOT NULL CHECK (annual_fee_amount >= 0),
  annual_fee_issue_date TEXT NOT NULL,
  fx_markup_bps INTEGER,
  currency TEXT NOT NULL,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);

-- Statement cycles per card
CREATE TABLE IF NOT EXISTS statement_cycles (
  id TEXT PRIMARY KEY,
  card_id TEXT NOT NULL REFERENCES cards(id) ON DELETE CASCADE,
  statement_date TEXT NOT NULL,
  due_date TEXT NOT NULL,
  grace_days INTEGER NOT NULL CHECK (grace_days >= 0),
  closing_balance_cents INTEGER NOT NULL CHECK (closing_balance_cents >= 0),
  min_payment_pct INTEGER NOT NULL,
  apr_bps INTEGER NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('open', 'paid', 'overdue')),
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_statement_cycles_card_statement ON statement_cycles(card_id, statement_date DESC);
CREATE INDEX IF NOT EXISTS idx_statement_cycles_card_due ON statement_cycles(card_id, due_date);

-- Installment plans (0%)
CREATE TABLE IF NOT EXISTS installment_plans (
  id TEXT PRIMARY KEY,
  card_id TEXT NOT NULL REFERENCES cards(id) ON DELETE CASCADE,
  total_amount INTEGER NOT NULL CHECK (total_amount > 0),
  monthly_payment INTEGER NOT NULL CHECK (monthly_payment > 0),
  remaining_amount INTEGER NOT NULL CHECK (remaining_amount >= 0),
  num_installments INTEGER NOT NULL CHECK (num_installments > 0),
  remaining_installments INTEGER NOT NULL CHECK (remaining_installments >= 0),
  start_date TEXT NOT NULL,
  next_due_date TEXT NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('active', 'completed', 'cancelled')),
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_installment_plans_card ON installment_plans(card_id);

-- Optional: current balance cache (one row per card)
CREATE TABLE IF NOT EXISTS card_balances (
  card_id TEXT PRIMARY KEY REFERENCES cards(id) ON DELETE CASCADE,
  balance INTEGER NOT NULL CHECK (balance >= 0),
  updated_at TEXT NOT NULL
);

-- Freemium: store tier locally (or use SharedPreferences key subscription_tier)
CREATE TABLE IF NOT EXISTS app_config (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL
);
-- INSERT OR REPLACE INTO app_config (key, value) VALUES ('subscription_tier', 'free');
