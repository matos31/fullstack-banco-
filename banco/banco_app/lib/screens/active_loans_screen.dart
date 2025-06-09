import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/loan_provider.dart';
import '../providers/auth_provider.dart';
import '../models/loan_model.dart';

class ActiveLoansScreen extends StatelessWidget {
  const ActiveLoansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loans = Provider.of<LoanProvider>(context).loans;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Empréstimos Ativos'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1D0807), Color(0xFFBD0000)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: loans.isEmpty
            ? const Center(
                child: Text(
                  'Nenhum empréstimo ativo.',
                  style: TextStyle(color: Colors.white70, fontSize: 18),
                ),
              )
            : ListView.builder(
                itemCount: loans.length,
                itemBuilder: (context, index) {
                  final loan = loans[index];
                  return _glassCard(context, loan);
                },
              ),
      ),
    );
  }

  Widget _glassCard(BuildContext context, Loan loan) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final loanProvider = Provider.of<LoanProvider>(context, listen: false);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'R\$ ${loan.amount.toStringAsFixed(2)} em ${loan.installments}x',
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Parcela: R\$ ${loan.installmentValue.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.white70),
              ),
              Text(
                'Pagas: ${loan.paidInstallments}/${loan.installments}',
                style: const TextStyle(color: Colors.white70),
              ),
              Text(
                'Restante: R\$ ${loan.remainingAmount.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 12),
              loan.isPaid
                  ? const Icon(Icons.check_circle, color: Colors.greenAccent)
                  : Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () {
                          final success = auth.withdraw(loan.installmentValue);
                          if (success) {
                            loanProvider.payInstallment(loan.id, auth);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Parcela paga com sucesso!')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Saldo insuficiente.')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 21, 216, 193),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Pagar'),
                      ),
                    )
            ],
          ),
        ),
      ),
    );
  }
}
