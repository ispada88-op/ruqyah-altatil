import '../models/card_profile.dart';

/// FX fee comparison: finds the card with the lowest foreign transaction fee.
/// All amounts in integer cents; markup in basis points (100 bps = 1%).
/// No floating-point; integer arithmetic only.
class FXCalculator {
  FXCalculator._();

  /// Fee in cents for a given amount and markup.
  /// [amountCents] Transaction amount in cents.
  /// [fxMarkupBps] Markup in basis points (e.g. 200 = 2%).
  /// Returns fee in cents: (amountCents * fxMarkupBps) / 10000.
  static int feeCents(int amountCents, int fxMarkupBps) {
    return (amountCents * fxMarkupBps) ~/ 10000;
  }

  /// Returns the card that incurs the lowest foreign transaction fee for [amountCents].
  /// Cards with null [fxMarkupBps] are skipped (unknown markup).
  /// Returns null if no card has a defined [fxMarkupBps], or if [cards] is empty.
  static CardProfile? cheapestCardForAmount({
    required int amountCents,
    required List<CardProfile> cards,
  }) {
    CardProfile? best;
    int bestFeeCents = -1;

    for (final card in cards) {
      final bps = card.fxMarkupBps;
      if (bps == null) continue;

      final fee = feeCents(amountCents, bps);
      if (best == null || fee < bestFeeCents) {
        best = card;
        bestFeeCents = fee;
      }
    }
    return best;
  }
}
