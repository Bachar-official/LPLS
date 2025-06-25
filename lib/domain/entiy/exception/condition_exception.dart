class ConditionException implements Exception {
  final String message;
  final String notificationMessage;
  const ConditionException(this.message, this.notificationMessage);
}