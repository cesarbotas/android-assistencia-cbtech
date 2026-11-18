import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/primary_button.dart';

class ReceiptScreen extends StatelessWidget {
  final String receiptNumber;
  final String customerName;
  final String customerPhone;
  final String deviceDescription;
  final double amount;
  final String paymentMethod;
  final DateTime date;
  final String itemsSummary;

  const ReceiptScreen({
    super.key,
    required this.receiptNumber,
    required this.customerName,
    required this.customerPhone,
    required this.deviceDescription,
    required this.amount,
    required this.paymentMethod,
    required this.date,
    required this.itemsSummary,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    void shareReceipt() {
      final text = '''
*CB Tech Assistência Técnica*
*RECIBO DE PAGAMENTO / GARANTIA*
--------------------------------
Recibo: $receiptNumber
Data: ${dateFormat.format(date)}
Cliente: $customerName
Aparelho: $deviceDescription
--------------------------------
*Resumo:*
$itemsSummary
--------------------------------
*Valor Total:* ${currencyFormat.format(amount)}
*Forma de Pagamento:* $paymentMethod
--------------------------------
Obrigado pela preferência! Garantia de 90 dias sobre o serviço executado.
''';
      Share.share(text);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comprovante / Recibo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Compartilhar Recibo',
            onPressed: shareReceipt,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.green,
                      radius: 30,
                      child: Icon(Icons.check, color: Colors.white, size: 36),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'CB Tech Assistência Técnica',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
                    ),
                    const SizedBox(height: 4),
                    const Text('CNPJ: 45.890.123/0001-99', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const Divider(height: 30),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Recibo: $receiptNumber', style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(dateFormat.format(date), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Cliente: $customerName', style: const TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text('WhatsApp: $customerPhone', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                          const SizedBox(height: 4),
                          Text('Aparelho: $deviceDescription', style: const TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                    const Divider(height: 30),

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Descrição dos Serviços / Peças:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(itemsSummary, style: const TextStyle(fontSize: 13)),
                    ),
                    const Divider(height: 30),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Forma de Pagamento:', style: TextStyle(color: Colors.grey)),
                        Text(paymentMethod, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Valor Pago:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(
                          currencyFormat.format(amount),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'Garantia de 90 dias contra defeitos de peças substituídas ou mão de obra realizada.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            PrimaryButton(
              text: 'Compartilhar Comprovante (WhatsApp)',
              icon: Icons.share,
              onPressed: shareReceipt,
            ),
          ],
        ),
      ),
    );
  }
}
