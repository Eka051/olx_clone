import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:olx_clone/providers/ad_provider.dart';
import 'dart:async';

class PaymentView extends StatefulWidget {
  final String invoiceNumber;

  const PaymentView({Key? key, required this.invoiceNumber}) : super(key: key);

  @override
  State<PaymentView> createState() => _PaymentViewState();
}

class _PaymentViewState extends State<PaymentView> {
  Timer? _paymentStatusTimer;
  bool _isCheckingPayment = false;
  String _paymentStatus = 'PENDING';

  @override
  void initState() {
    super.initState();
    _startPaymentStatusCheck();
  }

  @override
  void dispose() {
    _paymentStatusTimer?.cancel();
    super.dispose();
  }

  void _startPaymentStatusCheck() {
    _paymentStatusTimer = Timer.periodic(const Duration(seconds: 5), (
      timer,
    ) async {
      if (!mounted) {
        timer.cancel();
        return;
      }

      await _checkPaymentStatus();
    });
  }

  Future<void> _checkPaymentStatus() async {
    if (_isCheckingPayment) return;

    setState(() {
      _isCheckingPayment = true;
    });

    try {
      final adProvider = Provider.of<AdProvider>(context, listen: false);
      final status = await adProvider.checkPaymentStatus(widget.invoiceNumber);

      if (mounted) {
        setState(() {
          _paymentStatus = status ?? 'PENDING';
        });

        if (status == 'SUCCESS') {
          _paymentStatusTimer?.cancel();
          _showPaymentSuccessDialog();
        } else if (status == 'FAILED' || status == 'EXPIRED') {
          _paymentStatusTimer?.cancel();
          _showPaymentFailedDialog(status ?? 'FAILED');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _paymentStatus = 'ERROR';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingPayment = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await _showExitConfirmationDialog();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Pembayaran',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0.5,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (await _showExitConfirmationDialog()) {
                Navigator.pop(context);
              }
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildPaymentInfo(),
              const SizedBox(height: 24),
              _buildPaymentStatus(),
              const SizedBox(height: 24),
              _buildPaymentInstructions(),
              const Spacer(),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi Pembayaran',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Invoice Number:',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              Text(
                widget.invoiceNumber,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Consumer<AdProvider>(
            builder: (context, adProvider, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Pembayaran:',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  Text(
                    'Rp ${_formatPrice(adProvider.cartTotalPrice)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF00A651),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStatus() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _getStatusColor()),
      ),
      child: Row(
        children: [
          Icon(_getStatusIcon(), color: _getStatusColor(), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status Pembayaran',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  _getStatusText(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(),
                  ),
                ),
              ],
            ),
          ),
          if (_isCheckingPayment)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
    );
  }

  Widget _buildPaymentInstructions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[600], size: 20),
              const SizedBox(width: 8),
              Text(
                'Petunjuk Pembayaran',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '1. Lakukan pembayaran sesuai dengan nominal yang tertera\n'
            '2. Gunakan nomor invoice sebagai referensi pembayaran\n'
            '3. Status pembayaran akan otomatis terupdate\n'
            '4. Jika pembayaran berhasil, paket iklan akan aktif',
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue[700],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: () => _checkPaymentStatus(),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00A651),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child:
              _isCheckingPayment
                  ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                  : const Text(
                    'Cek Status Pembayaran',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () async {
            if (await _showExitConfirmationDialog()) {
              Navigator.popUntil(context, (route) => route.isFirst);
            }
          },
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            side: const BorderSide(color: Colors.grey),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Kembali ke Beranda',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor() {
    switch (_paymentStatus) {
      case 'SUCCESS':
        return Colors.green;
      case 'FAILED':
      case 'EXPIRED':
        return Colors.red;
      case 'ERROR':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  IconData _getStatusIcon() {
    switch (_paymentStatus) {
      case 'SUCCESS':
        return Icons.check_circle;
      case 'FAILED':
      case 'EXPIRED':
        return Icons.error;
      case 'ERROR':
        return Icons.warning;
      default:
        return Icons.schedule;
    }
  }

  String _getStatusText() {
    switch (_paymentStatus) {
      case 'SUCCESS':
        return 'Pembayaran Berhasil';
      case 'FAILED':
        return 'Pembayaran Gagal';
      case 'EXPIRED':
        return 'Pembayaran Kedaluwarsa';
      case 'ERROR':
        return 'Terjadi Kesalahan';
      default:
        return 'Menunggu Pembayaran';
    }
  }

  Future<bool> _showExitConfirmationDialog() async {
    if (_paymentStatus == 'SUCCESS') {
      return true;
    }

    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Keluar dari Pembayaran?'),
                content: const Text(
                  'Pembayaran belum selesai. Apakah Anda yakin ingin keluar?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Batal'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text(
                      'Keluar',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
        ) ??
        false;
  }

  void _showPaymentSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 28),
                SizedBox(width: 12),
                Text('Pembayaran Berhasil'),
              ],
            ),
            content: const Text(
              'Paket iklan Anda telah aktif dan siap digunakan.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                  Provider.of<AdProvider>(context, listen: false).clearCart();
                },
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showPaymentFailedDialog(String status) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.error, color: Colors.red, size: 28),
                const SizedBox(width: 12),
                Text(
                  status == 'EXPIRED'
                      ? 'Pembayaran Kedaluwarsa'
                      : 'Pembayaran Gagal',
                ),
              ],
            ),
            content: Text(
              status == 'EXPIRED'
                  ? 'Batas waktu pembayaran telah habis. Silakan buat pesanan baru.'
                  : 'Pembayaran tidak dapat diproses. Silakan coba lagi.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}
