import 'package:flutter/material.dart';
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
        title: const Text('Profil'),
        centerTitle: true,
        backgroundColor: AppTheme.of(context).colors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
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
            );
          }

          final user = profileProvider.user;
          if (user == null) {
            return const Center(child: Text('Data profil tidak ditemukan'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildProfileHeader(context, user),
                const SizedBox(height: 24),
                _buildProfileStats(context, user),
                const SizedBox(height: 24),
                _buildMenuList(context, authProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, user) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: AppTheme.of(
              context,
            ).colors.primary.withValues(alpha: 0.1),
            backgroundImage:
                user.profilePictureUrl != null
                    ? NetworkImage(user.profilePictureUrl!)
                    : null,
            child:
                user.profilePictureUrl == null
                    ? Icon(
                      Icons.person,
                      size: 50,
                      color: AppTheme.of(context).colors.primary,
                    )
                    : null,
          ),
          const SizedBox(height: 16),
          Text(
            user.name,
            style: AppTheme.of(
              context,
            ).textStyle.titleLarge.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            user.email,
            style: AppTheme.of(
              context,
            ).textStyle.bodyMedium.copyWith(color: Colors.grey[600]),
          ),
          if (user.phoneNumber != null) ...[
            const SizedBox(height: 4),
            Text(
              user.phoneNumber!,
              style: AppTheme.of(
                context,
              ).textStyle.bodyMedium.copyWith(color: Colors.grey[600]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProfileStats(BuildContext context, user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  '${user.totalAds}',
                  style: AppTheme.of(context).textStyle.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.of(context).colors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Total Iklan',
                  style: AppTheme.of(
                    context,
                  ).textStyle.bodySmall.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 40, color: Colors.grey[300]),
          Expanded(
            child: Column(
              children: [
                Text(
                  _getJoinDuration(user.createdAt),
                  style: AppTheme.of(context).textStyle.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.of(context).colors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Bergabung',
                  style: AppTheme.of(
                    context,
                  ).textStyle.bodySmall.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuList(BuildContext context, AuthProviderApp authProvider) {
    final menuItems = [
      {
        'icon': Icons.edit,
        'title': 'Edit Profil',
        'onTap': () => _showEditProfileDialog(context),
      },
      {
        'icon': Icons.inventory_2_outlined,
        'title': 'Iklan Saya',
        'onTap': () => Navigator.pushNamed(context, '/my_ads'),
      },
      {
        'icon': Icons.favorite_outline,
        'title': 'Favorit',
        'onTap': () => Navigator.pushNamed(context, '/favorites'),
      },
      {
        'icon': Icons.history,
        'title': 'Riwayat Transaksi',
        'onTap': () => Navigator.pushNamed(context, '/transaction_history'),
      },
      {
        'icon': Icons.settings,
        'title': 'Pengaturan',
        'onTap': () => Navigator.pushNamed(context, '/settings'),
      },
      {
        'icon': Icons.help_outline,
        'title': 'Bantuan',
        'onTap': () => Navigator.pushNamed(context, '/help'),
      },
      {
        'icon': Icons.info_outline,
        'title': 'Tentang Aplikasi',
        'onTap': () => Navigator.pushNamed(context, '/about'),
      },
      {
        'icon': Icons.logout,
        'title': 'Keluar',
        'isDestructive': true,
        'onTap': () => _showLogoutDialog(context, authProvider),
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: menuItems.length,
        separatorBuilder:
            (context, index) => Divider(height: 1, color: Colors.grey[200]),
        itemBuilder: (context, index) {
          final item = menuItems[index];
          final isDestructive = item['isDestructive'] as bool? ?? false;

          return ListTile(
            leading: Icon(
              item['icon'] as IconData,
              color:
                  isDestructive
                      ? Colors.red[600]
                      : AppTheme.of(context).colors.primary,
            ),
            title: Text(
              item['title'] as String,
              style: AppTheme.of(context).textStyle.bodyLarge.copyWith(
                color: isDestructive ? Colors.red[600] : null,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
            onTap: item['onTap'] as VoidCallback,
          );
        },
      ),
    );
  }

  String _getJoinDuration(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays >= 365) {
      return '${(difference.inDays / 365).floor()}th';
    } else if (difference.inDays >= 30) {
      return '${(difference.inDays / 30).floor()}bln';
    } else {
      return '${difference.inDays}hr';
    }
  }

  void _showEditProfileDialog(BuildContext context) {
    final profileProvider = context.read<ProfileProvider>();
    final user = profileProvider.user;
    if (user == null) return;

    final nameController = TextEditingController(text: user.name);
    final phoneController = TextEditingController(text: user.phoneNumber ?? '');

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Edit Profil'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Nomor Telepon',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final newName = nameController.text.trim();
                  final newPhone = phoneController.text.trim();

                  if (newName.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Nama tidak boleh kosong')),
                    );
                    return;
                  }

                  Navigator.pop(context);
                  await profileProvider.updateProfile(
                    name: newName != user.name ? newName : null,
                    phoneNumber: newPhone != user.phoneNumber ? newPhone : null,
                  );

                  if (profileProvider.error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(profileProvider.error!)),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profil berhasil diperbarui'),
                      ),
                    );
                  }
                },
                child: const Text('Simpan'),
              ),
            ],
          ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProviderApp authProvider) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Keluar'),
            content: const Text('Apakah Anda yakin ingin keluar dari akun?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await authProvider.logout();

                  if (authProvider.errorMessage != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(authProvider.errorMessage!)),
                    );
                  } else {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (route) => false,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Keluar'),
              ),
            ],
          ),
    );
  }
}
