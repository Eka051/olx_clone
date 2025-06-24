import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebview extends StatefulWidget {
  final String paymentUrl;
  final String finishUrl;

  const PaymentWebview({
    super.key,
    required this.paymentUrl,
    required this.finishUrl,
  });

  @override
  State<PaymentWebview> createState() => _PaymentWebviewState();
}

class _PaymentWebviewState extends State<PaymentWebview> {
  late final WebViewController _controller;
  bool _isLoading = true;
  int _loadingPercentage = 0;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              _loadingPercentage = progress;
              if (progress == 100) {
                _isLoading = false;
              }
            });
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _loadingPercentage = 0;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _isLoading = false;
            });
            Navigator.of(context).pop('failed');
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith(widget.finishUrl)) {
              final uri = Uri.parse(request.url);
              final status = uri.queryParameters['transaction_status'];
              if (status == 'settlement' || status == 'capture') {
                 Navigator.of(context).pop('success');
              } else {
                 Navigator.of(context).pop('failed');
              }
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop('closed'),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 10),
                  Text('Memuat... $_loadingPercentage%'),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
