import 'package:flutter/material.dart';
import 'package:olx_clone/providers/payment_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebview extends StatefulWidget {
  final String paymentUrl;

  const PaymentWebview({super.key, required this.paymentUrl});

  @override
  State<PaymentWebview> createState() => _PaymentWebviewState();
}

class _PaymentWebviewState extends State<PaymentWebview> {
  late final PaymentProvider _paymentProvider;

  @override
  void initState() {
    super.initState();
    _paymentProvider = PaymentProvider();
    _paymentProvider.initController(
      onPaymentResult: (String result) {
        if (mounted) {
          Navigator.of(context).pop(result);
        }
      },
    );
    _paymentProvider.loadDokuCheckout(widget.paymentUrl);
  }

  @override
  void dispose() {
    _paymentProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _paymentProvider,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Pembayaran'),
          ),
          body: Stack(
            children: [
              WebViewWidget(controller: _paymentProvider.controller),
              if (_paymentProvider.isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        );
      },
    );
  }
}
