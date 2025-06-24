import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:olx_clone/utils/theme.dart';
import 'package:olx_clone/models/premium_package.dart';
import 'package:olx_clone/providers/premium_package_provider.dart';
import 'package:olx_clone/providers/profile_provider.dart';
import 'package:olx_clone/views/payment/payment_webview.dart';

class PremiumPackageView extends StatefulWidget {
  const PremiumPackageView({super.key});

  @override
  State<PremiumPackageView> createState() => _PremiumPackageViewState();
}

class _PremiumPackageViewState extends State<PremiumPackageView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PremiumPackageProvider>().fetchPremiumPackages();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: Text(
            'Pilih Paket Anda',
            style: AppTheme.of(context).textStyle.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 1,
          shadowColor: Colors.grey.withAlpha(51),
          surfaceTintColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Consumer<PremiumPackageProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading && provider.packages.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.errorMessage != null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        provider.errorMessage!,
                        style: AppTheme.of(context).textStyle.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => provider.fetchPremiumPackages(),
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (provider.packages.isEmpty) {
              return const Center(child: Text('Tidak ada paket premium tersedia'));
            }

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoBox(context),
                        const SizedBox(height: 16.0),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: provider.packages.length,
                          itemBuilder: (context, index) {
                            return _buildPackageCard(
                              context,
                              index,
                              provider.packages[index],
                              provider,
                            );
                          },
                        ),
                        const SizedBox(height: 24.0),
                        _buildBenefitsSection(context),
                      ],
                    ),
                  ),
                ),
                _buildBottomButton(context, provider),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoBox(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xffe0f3ff),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: const Color(0xffb3e5fc), width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star, color: AppTheme.of(context).colors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Profil Premium',
                style: AppTheme.of(context).textStyle.titleMedium.copyWith(
                      color: AppTheme.of(context).colors.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          Text(
            'Sistem keanggotaan dengan berbagai fitur eksklusif yang dapat meningkatkan reputasi toko, visibilitas akun, dan kepercayaan pembeli, sehingga dapat meningkatkan penjualan. Tingkatkan akun Anda ke Profil Premium sekarang dan dapatkan semua manfaatnya.',
            style: AppTheme.of(context).textStyle.bodyMedium.copyWith(color: Colors.black87, height: 1.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPackageCard(
    BuildContext context,
    int index,
    PremiumPackage package,
    PremiumPackageProvider provider,
  ) {
    bool isSelected = provider.selectedPackageIndex == index;
    final primaryColor = AppTheme.of(context).colors.primary;

    return GestureDetector(
      onTap: () => provider.selectPackage(index),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey[300]!,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (package.isRecommended)
              Align(
                alignment: Alignment.topLeft,
                child: Container(
                  margin: const EdgeInsets.only(left: 0, top: 0),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                  ),
                  child: const Text('Recommended', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ),
            if (!package.isRecommended) const SizedBox(height: 22),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            package.formattedPrice,
                            style: AppTheme.of(context).textStyle.headlineSmall.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            package.formattedOriginalPrice,
                            style: AppTheme.of(context).textStyle.bodyMedium.copyWith(decoration: TextDecoration.lineThrough, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        package.description,
                        style: AppTheme.of(context).textStyle.bodySmall.copyWith(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Radio<int>(
                  value: index,
                  groupValue: provider.selectedPackageIndex,
                  onChanged: (int? value) {
                    if (value != null) provider.selectPackage(value);
                  },
                  activeColor: primaryColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitsSection(BuildContext context) {
    final benefits = [
      {'title': 'Profil Terlihat Lebih Profesional', 'subtitle': 'Dengan halaman profil yang lebih menarik dan profesional, reputasi dan kredibilitas Dealer atau Toko Anda akan meningkat.'},
      {'title': 'Tag/Badge Eksklusif Premium', 'subtitle': 'Tag/badge "Premium" di akun dan Iklan Anda membuat Anda terlihat lebih menonjol dibandingkan Dealer atau Toko lain, dan sekaligus meningkatkan kepercayaan calon pembeli Anda.'},
      {'title': 'Jangkauan Iklan Lebih Luas & Lebih Mudah Ditemukan', 'subtitle': 'Perluas jangkauan eksposur iklan dan Akun Anda dengan fitur profil Premium yang dapat mempermudah calon pembeli untuk dapat menemukan Dealer atau Toko Anda.'},
      {'title': 'Makin Terpercaya', 'subtitle': 'Fitur "Premium" mempermudah Anda untuk menulis lebih banyak info menarik seputar Dealer atau Toko dan juga berbagai program promo yang aktif untuk meyakinkan para calon pembeli.'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Keuntungan Eksklusif Anda',
          style: AppTheme.of(context).textStyle.titleLarge.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.8,
          ),
          itemCount: benefits.length,
          itemBuilder: (context, index) {
            return _buildBenefitItem(context, benefits[index]['title']!, benefits[index]['subtitle']!);
          },
        ),
      ],
    );
  }

  Widget _buildBenefitItem(BuildContext context, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTheme.of(context).textStyle.titleMedium.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              subtitle,
              style: AppTheme.of(context).textStyle.bodySmall.copyWith(color: Colors.grey[700], height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context, PremiumPackageProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16.0).copyWith(top: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(25), blurRadius: 10, offset: const Offset(0, -2))],
        border: Border(top: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Total Tagihan',
                  style: AppTheme.of(context).textStyle.bodySmall.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 2),
                Text(
                  provider.selectedPackage?.formattedPrice ?? 'Rp 0',
                  style: AppTheme.of(context).textStyle.titleLarge.copyWith(fontWeight: FontWeight.bold, color: AppTheme.of(context).colors.primary),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: provider.selectedPackage != null && !provider.isLoading ? () => _handleSubscription(context, provider) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.of(context).colors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: provider.isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Lanjut ke Pembayaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubscription(
    BuildContext context,
    PremiumPackageProvider provider,
  ) async {
    if (provider.selectedPackage == null) return;

    try {
      // Memanggil provider dan mendapatkan Map
      final paymentData = await provider.createPremiumPayment(
        provider.selectedPackage!.id,
      );
      
      // Memastikan data tidak null sebelum digunakan
      if (paymentData != null && mounted) {
        // Membuka WebView dengan data yang benar
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentWebview(
              paymentUrl: paymentData['paymentUrl']!,
              finishUrl: paymentData['finishUrl']!,
            ),
          ),
        );

        if (result == 'success' && mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Memverifikasi pembayaran...'),
                ],
              ),
            ),
          );

          await context.read<ProfileProvider>().refreshProfileAfterPremiumUpgrade();
          
          if(mounted) Navigator.pop(context);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Berhasil berlangganan premium!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.of(context).pop();
        } else if (result == 'failed' && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pembayaran gagal atau dibatalkan'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Gagal membuat pembayaran'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}