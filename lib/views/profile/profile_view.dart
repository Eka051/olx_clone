import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:olx_clone/utils/const.dart';
import 'package:provider/provider.dart';
import 'package:olx_clone/providers/profile_provider.dart';
import 'package:olx_clone/providers/auth_provider.dart';
import 'package:olx_clone/utils/theme.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().fetchUserProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.of(context).colors.background,
      appBar: AppBar(
        backgroundColor: AppTheme.of(context).colors.background,
        elevation: 1,
        surfaceTintColor: Colors.transparent,
        title: SizedBox(
          height: 40,
          child: Image.asset(
            'assets/images/OLX-LOGO-BLUE.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Text(
                'OLX Clone',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Colors.blue,
                ),
              );
            },
          ),
        ),
        centerTitle: false,
      ),
      body: Consumer2<ProfileProvider, AuthProviderApp>(
        builder: (context, profileProvider, authProvider, child) {
          if (profileProvider.isLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: AppTheme.of(context).colors.primary,
              ),
            );
          }

          if (profileProvider.error != null) {
            if (profileProvider.error!.contains('401') ||
                profileProvider.error!.toLowerCase().contains('unauthorized')) {
              return _build401ErrorView(context, authProvider);
            }

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Terjadi Kesalahan',
                      style: AppTheme.of(context).textStyle.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      profileProvider.error!,
                      style: AppTheme.of(
                        context,
                      ).textStyle.bodyMedium.copyWith(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => profileProvider.fetchUserProfile(),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }
          final user = profileProvider.user;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildProfileHeader(context, user),
                  const SizedBox(height: 24),
                  _buildEditProfileButton(context),
                  const SizedBox(height: 24),
                  _buildMenuList(context, authProvider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _build401ErrorView(
    BuildContext context,
    AuthProviderApp authProvider,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.of(context).colors.primary.withAlpha(30),
            Colors.white,
          ],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_outline,
                  size: 80,
                  color: Colors.orange[600],
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Sesi Berakhir',
                style: AppTheme.of(context).textStyle.headlineMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Sesi Anda telah berakhir. Silakan masuk kembali untuk melanjutkan menggunakan aplikasi.',
                style: AppTheme.of(context).textStyle.bodyLarge.copyWith(
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.of(context).colors.primary,
                      AppTheme.of(context).colors.primary.withAlpha(130),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.of(
                        context,
                      ).colors.primary.withAlpha(45),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () async {
                    await authProvider.logout();
                    if (mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/auth-option',
                        (route) => false,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.login, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Masuk Kembali',
                        style: AppTheme.of(
                          context,
                        ).textStyle.titleMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed:
                    () => context.read<ProfileProvider>().fetchUserProfile(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.refresh,
                      size: 18,
                      color: AppTheme.of(context).colors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Coba Lagi',
                      style: TextStyle(
                        color: AppTheme.of(context).colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, user) {
    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: AppTheme.of(context).colors.primary.withAlpha(25),
          backgroundImage:
              (user?.profilePictureUrl?.isNotEmpty ?? false)
                  ? NetworkImage(user!.profilePictureUrl!)
                  : null,
          child:
              (user?.profilePictureUrl?.isNotEmpty ?? false) == false
                  ? Text(
                    (user?.name?.isNotEmpty ?? false)
                        ? user!.name[0].toUpperCase()
                        : 'U',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.of(context).colors.primary,
                    ),
                  )
                  : null,
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      user?.name ?? 'Pengguna',
                      style: AppTheme.of(context).textStyle.headlineSmall
                          .copyWith(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (user?.isPremium == true) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3A77FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, color: Colors.white, size: 12),
                          SizedBox(width: 2),
                          Text(
                            'Premium',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Text(
                user?.email ?? 'Email tidak tersedia',
                style: AppTheme.of(
                  context,
                ).textStyle.bodyMedium.copyWith(color: Colors.grey[600]),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEditProfileButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          final profileProvider = context.read<ProfileProvider>();
          final result = await Navigator.pushNamed(
            context,
            AppRoutes.editProfile,
          );
          if (result == true && mounted) {
            await profileProvider.fetchUserProfile();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.of(context).colors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 2,
        ),
        child: Text(
          'Lihat dan edit profil',
          style: AppTheme.of(context).textStyle.titleMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuList(BuildContext context, AuthProviderApp authProvider) {
    final menuItems = [
      {
        'icon': Icons.card_giftcard_outlined,
        'title': 'Paket Iklan',
        'onTap': () {
          Navigator.pushNamed(context, AppRoutes.adPackages);
        },
      },
      {
        'icon': Icons.star_border_outlined,
        'title': 'Program Penjual',
        'onTap': () {
          Navigator.pushNamed(context, AppRoutes.premiumPackages);
        },
      },
      // {
      //   'icon': Icons.stacked_bar_chart,
      //   'title': 'notification',
      //   'onTap': () {
      //     Navigator.pushNamed(context, AppRoutes.notification);
      //   },
      // },
      {
        'icon': Icons.logout,
        'title': 'Logout',
        'onTap': () => _showLogoutDialog(context, authProvider),
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: menuItems.length,
        separatorBuilder:
            (context, index) => Divider(
              height: 1,
              color: Colors.grey[200],
              indent: 16,
              endIndent: 16,
            ),
        itemBuilder: (context, index) {
          final item = menuItems[index];
          return ListTile(
            leading: Icon(item['icon'] as IconData, color: Colors.grey[800]),
            title: Text(
              item['title'] as String,
              style: AppTheme.of(context).textStyle.bodyLarge,
            ),
            trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
            onTap: item['onTap'] as VoidCallback,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
          );
        },
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProviderApp authProvider) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Apakah Anda yakin ingin keluar dari akun?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  final scaffoldMessenger = ScaffoldMessenger.of(context);

                  Navigator.pop(dialogContext);

                  try {
                    await authProvider.logout();

                    await Future.delayed(const Duration(milliseconds: 100));

                    if (mounted) {
                      if (authProvider.errorMessage != null) {
                        scaffoldMessenger.showSnackBar(
                          SnackBar(content: Text(authProvider.errorMessage!)),
                        );
                      } else {
                        navigator.pushNamedAndRemoveUntil(
                          '/auth-option',
                          (route) => false,
                        );
                      }
                    }
                  } catch (e) {
                    if (mounted) {
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: Text('Gagal logout: ${e.toString()}'),
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Logout'),
              ),
            ],
          ),
    );
  }
}
