import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

enum PaymentResultStatus { success, pending, failed, error }

class MidtransPaymentService {
  static void processPayment({
    required BuildContext context,
    required String paymentUrl,
    required Function(PaymentResultStatus, String?) onPaymentFinished,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => _PaymentWebView(
              paymentUrl: paymentUrl,
              onPaymentFinished: onPaymentFinished,
            ),
      ),
    );
  }
}

class _PaymentWebView extends StatefulWidget {
  final String paymentUrl;
  final Function(PaymentResultStatus, String?) onPaymentFinished;

  const _PaymentWebView({
    required this.paymentUrl,
    required this.onPaymentFinished,
  });

  @override
  State<_PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<_PaymentWebView> {
  late final WebViewController _controller;
  int _loadingPercentage = 0;

  @override
  void initState() {
    super.initState();
    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onProgress: (progress) {
                setState(() {
                  _loadingPercentage = progress;
                });
              },
              onPageStarted: (url) {
                setState(() {
                  _loadingPercentage = 0;
                });
              },
              onPageFinished: (url) {
                setState(() {
                  _loadingPercentage = 100;
                });
              },
              onNavigationRequest: (request) {
                final uri = Uri.parse(request.url);

                if (uri.queryParameters.containsKey('status_code')) {
                  handlePaymentResult(uri);
                  return NavigationDecision.prevent;
                }
                return NavigationDecision.navigate;
              },
            ),
          )
          ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  void handlePaymentResult(Uri uri) {
    final statusCode = uri.queryParameters['status_code'];
    final transactionStatus = uri.queryParameters['transaction_status'];
    final orderId = uri.queryParameters['order_id'];

    PaymentResultStatus resultStatus;

    switch (statusCode) {
      case '200': // Success
        resultStatus = PaymentResultStatus.success;
        break;
      case '201': // Pending
        resultStatus = PaymentResultStatus.pending;
        break;
      case '202': // Denied
        resultStatus = PaymentResultStatus.failed;
        break;
      default:
        resultStatus = PaymentResultStatus.error;
        break;
    }

    if (mounted) {
      Navigator.pop(context);
      widget.onPaymentFinished(resultStatus, orderId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pembayaran")),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loadingPercentage < 100)
            LinearProgressIndicator(value: _loadingPercentage / 100.0),
        ],
      ),
    );
  }
}
