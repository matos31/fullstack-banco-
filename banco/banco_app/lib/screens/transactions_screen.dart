import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:u_credit_card/u_credit_card.dart';
import '../providers/auth_provider.dart';
import '../screens/pix_screen.dart';
import '../screens/pay_boleto_screen.dart';
import '../screens/loan_screen.dart';
import '../screens/active_loans_screen.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final String username = auth.username ?? 'Usuário';
    final double saldo = 12345.67;
    final double faturaAtual = 1578.90;
    final double limiteTotal = 5000.00;
    final double limiteRestante = limiteTotal - faturaAtual;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cartão
          Center(
            child: CreditCardUi(
              cardHolderFullName: username,
              cardNumber: '1234567812341234',
              validFrom: '05/24',
              validThru: '05/29',
              topLeftColor: Colors.red.shade900,
              bottomRightColor: Colors.redAccent,
              doesSupportNfc: true,
              placeNfcIconAtTheEnd: true,
              cardType: CardType.credit,
              cardProviderLogo: FlutterLogo(),
              cardProviderLogoPosition: CardProviderLogoPosition.right,
              showBalance: true,
              balance: saldo,
              autoHideBalance: true,
              enableFlipping: true,
              cvvNumber: '999',
              width: 320,
            ),
          ),

          const SizedBox(height: 32),
          const Text('Serviços', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _actionButton(
                context,
                icon: Icons.pix,
                label: 'Pix',
                color: Colors.red[800]!,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const PixScreen()));
                },
              ),
              _actionButton(
                context,
                icon: Icons.receipt_long,
                label: 'Boletos',
                color: Colors.blueGrey,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const PayBoletoScreen()));
                },
              ),
              _actionButton(
                context,
                icon: Icons.trending_up,
                label: 'Empréstimo',
                color: Colors.teal[800]!,
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    builder: (_) => Wrap(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.add),
                          title: const Text('Solicitar Empréstimo'),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const LoanScreen()));
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.list),
                          title: const Text('Ver Empréstimos Ativos'),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const ActiveLoansScreen()));
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 32),
          Text('Fatura atual', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800])),
          const SizedBox(height: 8),
          Text('R\$ ${faturaAtual.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.red[800])),
          const SizedBox(height: 20),
          Text('Limite disponível',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800])),
          const SizedBox(height: 8),
          Text('R\$ ${limiteRestante.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green[700])),
        ],
      ),
    );
  }

  Widget _actionButton(BuildContext context,
      {required IconData icon,
      required String label,
      required Color color,
      required VoidCallback onTap}) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))],
            ),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.black87)),
      ],
    );
  }
}
