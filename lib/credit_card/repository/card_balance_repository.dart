/// Contract for current card balance (optional cache to avoid scanning all statements).
/// Single balance per card; update when user records payment or new statement.
abstract class CardBalanceRepository {
  Future<int> getBalanceCents(String cardId);
  Future<void> setBalanceCents(String cardId, int balanceCents);
}
