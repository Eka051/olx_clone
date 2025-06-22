import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';

class PaymentProvider extends ChangeNotifier {
  WebViewController? _controller;
  bool _isLoading = true;
  int _loadingPercentage = 0;

  WebViewController get controller => _controller!;
  bool get isLoading => _isLoading;
  int get loadingPercentage => _loadingPercentage;

  void initController({required Function(String) onPaymentResult}) {
    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onProgress: (int progress) {
                _loadingPercentage = progress;
                if (progress == 100) {
                  _isLoading = false;
                }
                notifyListeners();
              },
              onPageStarted: (String url) {
                _isLoading = true;
                _loadingPercentage = 0;
                notifyListeners();
              },
              onPageFinished: (String url) {
                _isLoading = false;
                notifyListeners();
              },
              onWebResourceError: (WebResourceError error) {
                _isLoading = false;
                notifyListeners();
              },
              onNavigationRequest: (NavigationRequest request) {
                final Uri uri = Uri.parse(request.url);
                print('Navigation request URL: ${request.url}');

                // Handle payment redirect patterns
                if (uri.path.contains('payment-redirect.html')) {
                  final status = uri.queryParameters['status'];
                  if (status == 'success') {
                    onPaymentResult('success');
                  } else {
                    onPaymentResult('failed');
                  }
                  return NavigationDecision.prevent;
                }

                // Handle DOKU success/failure URLs
                if (uri.host.contains('olx-clone.app') ||
                    uri.path.contains('/payment/success') ||
                    uri.path.contains('/payment/callback')) {
                  final status =
                      uri.queryParameters['status'] ??
                      uri.queryParameters['transaction_status'];

                  if (status == 'success' ||
                      status == 'COMPLETED' ||
                      uri.path.contains('/success')) {
                    onPaymentResult('success');
                  } else if (status == 'failed' ||
                      status == 'FAILED' ||
                      status == 'CANCELLED' ||
                      uri.path.contains('/failed')) {
                    onPaymentResult('failed');
                  }
                  return NavigationDecision.prevent;
                }

                // Handle any other success/failure patterns in URL
                final url = request.url.toLowerCase();
                if (url.contains('success') || url.contains('completed')) {
                  onPaymentResult('success');
                  return NavigationDecision.prevent;
                } else if (url.contains('failed') ||
                    url.contains('cancelled') ||
                    url.contains('error')) {
                  onPaymentResult('failed');
                  return NavigationDecision.prevent;
                }

                return NavigationDecision.navigate;
              },
            ),
          );
  }

  void loadDokuCheckout(String paymentUrl) {
    if (_controller == null) return;

    final String htmlContent = '''
      <!DOCTYPE html>
      <html>
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
        <script type="text/javascript" src="https://jokul.doku.com/jokul-checkout-js/v1/jokul-checkout-1.0.0.js"></script>
        <style>
          body, html { margin: 0; padding: 0; height: 100%; overflow: hidden; display: flex; justify-content: center; align-items: center; background-color: #f0f0f0; }
        </style>
      </head>
      <body onload="loadJokul()">
        <div id="doku-checkout"></div>
        <script type="text/javascript">
          function loadJokul() {
            try {
              loadJokulCheckout('$paymentUrl');
            } catch (e) {
              document.body.innerHTML = 'Gagal memuat halaman pembayaran. Silakan coba lagi.';
            }
          }
        </script>
      </body>
      </html>
    ''';

    _controller!.loadRequest(
      Uri.dataFromString(
        htmlContent,
        mimeType: 'text/html',
        encoding: Encoding.getByName('utf-8'),
      ),
    );
  }
}
