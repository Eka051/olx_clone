import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentProvider extends ChangeNotifier {
  WebViewController? _controller;
  bool _isLoading = true;
  int _loadingPercentage = 0;

  WebViewController? get controller => _controller;
  bool get isLoading => _isLoading;
  int get loadingPercentage => _loadingPercentage;

  void initController({
    required String initialUrl,
    required String finishUrl,
    required Function(String) onPaymentResult,
  }) {
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
                _handleRedirectUrl(url, finishUrl, onPaymentResult);
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
                _handleRedirectUrl(request.url, finishUrl, onPaymentResult);
                return NavigationDecision.navigate;
              },
            ),
          )
          ..loadRequest(Uri.parse(initialUrl));

    notifyListeners();
  }

  void _handleRedirectUrl(
    String url,
    String finishUrl,
    Function(String) onPaymentResult,
  ) {
    final uri = Uri.parse(url);

    if (url.startsWith(finishUrl)) {
      final transactionStatus = uri.queryParameters['transaction_status'];

      if (transactionStatus != null) {
        if (transactionStatus == 'settlement' ||
            transactionStatus == 'capture') {
          onPaymentResult('success');
        } else if (transactionStatus == 'pending') {
          onPaymentResult('pending');
        } else {
          onPaymentResult('failed');
        }
      } else {
        onPaymentResult('pending');
      }
    }
  }
}
