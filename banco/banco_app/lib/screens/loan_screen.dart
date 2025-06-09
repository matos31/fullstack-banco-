import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/loan_model.dart';
import '../providers/loan_provider.dart';
import '../providers/auth_provider.dart';

class LoanScreen extends StatefulWidget {
  const LoanScreen({super.key});

  @override
  State<LoanScreen> createState() => _LoanScreenState();
}

class _LoanScreenState extends State<LoanScreen> {
  final TextEditingController _amountController = TextEditingController();
  int _installments = 1;
  bool _isProcessing = false;

  void _requestLoan() {
    final rawAmount = _amountController.text.trim().replaceAll(',', '.');
    final amount = double.tryParse(rawAmount);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite um valor válido')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    Future.delayed(const Duration(seconds: 2), () {
      final interestRate = 0.005;
      final loan = Loan(
        id: const Uuid().v4(),
        amount: amount,
        installments: _installments,
        interestRate: interestRate,
        startDate: DateTime.now(),
      );

      final loanProvider = Provider.of<LoanProvider>(context, listen: false);
      final auth = Provider.of<AuthProvider>(context, listen: false);

      loanProvider.addLoan(loan);
      auth.deposit(amount);

      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Empréstimo solicitado com sucesso!')),
      );
      Navigator.pop(context);
    });
  }

  Widget _glassmorphicContainer({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Solicitar Empréstimo'),
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
        padding: const EdgeInsets.all(24),
        child: Center(
          child: SingleChildScrollView(
            child: _glassmorphicContainer(
              child: Column(
                children: [
                  const Text(
                    'Digite o valor desejado:',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Ex: 1000.00',
                      hintStyle: TextStyle(color: Colors.white54),
                      prefixIcon: Icon(Icons.attach_money, color: Colors.white),
                      border: InputBorder.none,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Text('Parcelas:', style: TextStyle(color: Colors.white, fontSize: 16)),
                      Expanded(
                        child: Slider(
                          min: 1,
                          max: 28,
                          divisions: 27,
                          value: _installments.toDouble(),
                          activeColor: Colors.white,
                          inactiveColor: Colors.white30,
                          onChanged: (value) {
                            setState(() {
                              _installments = value.toInt();
                            });
                          },
                        ),
                      ),
                      Text('$_installments x', style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _isProcessing
                      ? const CircularProgressIndicator(color: Colors.white)
                      : ElevatedButton.icon(
                          icon: const Icon(Icons.trending_up, color: Colors.white),
                          label: const Text(
                            'Solicitar Empréstimo',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal[800],
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: _requestLoan,
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
