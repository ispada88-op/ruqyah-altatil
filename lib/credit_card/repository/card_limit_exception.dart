/// Thrown when adding a card would exceed the free tier limit.
class CardLimitReachedException implements Exception {
  CardLimitReachedException(this.maxCards, this.currentCount);

  final int maxCards;
  final int currentCount;

  @override
  String toString() =>
      'CardLimitReachedException: Free tier allows max $maxCards cards, '
      'current count is $currentCount. Upgrade to Premium for unlimited cards.';
}
