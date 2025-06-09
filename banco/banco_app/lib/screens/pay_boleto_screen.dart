import 'dart:ui';
import 'package:flutter/material.dart';

class PayBoletoScreen extends StatefulWidget {
  const PayBoletoScreen({super.key});

  @override
  State<PayBoletoScreen> createState() => _PayBoletoScreenState();
}

class _PayBoletoScreenState extends State<PayBoletoScreen> {
  final TextEditingController _barcodeController = TextEditingController();
  bool _isProcessing = false;

  void _simulatePayment() {
    final barcode = _barcodeController.text.trim();
    if (barcode.isEmpty || barcode.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, insira um código de barras válido.')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    Future.delayed(const Duration(seconds: 2), () {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Boleto pago com sucesso!')),
      );
      Navigator.pop(context);
    });
  }

  void _scanBarcode() {
    setState(() {
      _barcodeController.text = '23793381286000000001234567890123456789012345';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Código escaneado com sucesso')),
    );
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
        title: const Text('Pagar Boleto'),
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
                    'Escaneie ou digite o código:',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _barcodeController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.camera_alt, color: Colors.white),
                        onPressed: _scanBarcode,
                      ),
                      hintText: 'Código de barras',
                      hintStyle: const TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _isProcessing
                      ? const CircularProgressIndicator(color: Colors.white)
                      : SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.payment, color: Colors.white),
                            label: const Text(
                              'Pagar Boleto',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[800],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: _simulatePayment,
                          ),
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
