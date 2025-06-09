class Loan {
  final String id;
  final double amount;
  final int installments;
  final double interestRate;
  final DateTime startDate;
  int paidInstallments;

  Loan({
    required this.id,
    required this.amount,
    required this.installments,
    required this.interestRate,
    required this.startDate,
    this.paidInstallments = 0,
  });

  /// Total com juros
  double get totalAmount => amount * (1 + interestRate * installments);

  /// Valor de cada parcela
  double get installmentValue => totalAmount / installments;

  /// Valor restante para pagar
  double get remainingAmount => installmentValue * (installments - paidInstallments);

  /// Verifica se o empréstimo já foi pago f
  bool get isPaid => paidInstallments >= installments;
}
