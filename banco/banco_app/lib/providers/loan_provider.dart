import 'package:flutter/material.dart';
import '../models/loan_model.dart';
import 'auth_provider.dart';

class LoanProvider extends ChangeNotifier {
  final List<Loan> _loans = [];

  List<Loan> get loans => List.unmodifiable(_loans);

  void addLoan(Loan loan) {
    _loans.add(loan);
    notifyListeners();
  }

  void payInstallment(String loanId, AuthProvider auth) {
    final loan = _loans.firstWhere((l) => l.id == loanId, orElse: () => throw Exception('Empréstimo não encontrado'));

    if (!loan.isPaid && auth.withdraw(loan.installmentValue)) {
      loan.paidInstallments++;
      notifyListeners();
    }
  }
}
