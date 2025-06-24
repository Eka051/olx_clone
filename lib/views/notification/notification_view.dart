import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:olx_clone/providers/auth_provider.dart';
import 'package:olx_clone/providers/notification_provider.dart';
import 'package:olx_clone/models/notification.dart' as model;
import 'package:olx_clone/utils/theme.dart';

class NotificationView extends StatefulWidget {
  const NotificationView({super.key});

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  late String? _token;
  bool _localeInitialized = false;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null).then((_) {
      setState(() {
        _localeInitialized = true;
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProviderApp>();
      final notificationProvider = context.read<NotificationProvider>();
      _token = authProvider.jwtToken;
      if (authProvider.isLoggedIn && _token != null) {
        notificationProvider.fetchNotifications();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_localeInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppTheme.of(context).colors.background,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(deviceHeight * 0.07),
          child: AppBar(
            backgroundColor: AppTheme.of(context).colors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            title: Text(
              'Notifikasi',
              style: AppTheme.of(context).textStyle.titleLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: false,
          ),
        ),
        body: Consumer<NotificationProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading && provider.notifications.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.error != null && provider.notifications.isEmpty) {
              return _buildErrorState(context, provider);
            }

            if (provider.notifications.isEmpty) {
              return _buildEmptyState(context);
            }

            return RefreshIndicator(
              onRefresh: () async {
                final authProvider = context.read<AuthProviderApp>();
                final token = authProvider.jwtToken;
                if (token != null) {
                  await provider.fetchNotifications();
                }
              },
              child: ListView.separated(
                padding: EdgeInsets.symmetric(
                  horizontal: deviceWidth * 0.04,
                  vertical: deviceWidth * 0.04,
                ),
                itemCount: provider.notifications.length,
                separatorBuilder:
                    (context, index) => SizedBox(height: deviceWidth * 0.03),
                itemBuilder: (context, index) {
                  final model.NotificationModel notif =
                      provider.notifications[index];
                  return _buildNotificationItem(context, provider, notif);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNotificationItem(
    BuildContext context,
    NotificationProvider provider,
    model.NotificationModel notif,
  ) {
    final deviceWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        final authProvider = context.read<AuthProviderApp>();
        final token = authProvider.jwtToken;
        if (!notif.isRead && token != null) {
          provider.markAsRead(notif.id);
        }
      },
      child: Container(
        padding: EdgeInsets.all(deviceWidth * 0.04),
        decoration: BoxDecoration(
          color:
              notif.isRead
                  ? Colors.white
                  : AppTheme.of(context).colors.primary.withOpacity(0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                notif.isRead
                    ? Colors.grey[200]!
                    : AppTheme.of(context).colors.primary.withOpacity(0.2),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.07),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: deviceWidth * 0.12,
              height: deviceWidth * 0.12,
              decoration: BoxDecoration(
                color:
                    notif.isRead
                        ? Colors.grey[200]
                        : AppTheme.of(context).colors.primary.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                notif.isRead
                    ? Icons.notifications_none
                    : Icons.notifications_active,
                color:
                    notif.isRead
                        ? Colors.grey[500]
                        : AppTheme.of(context).colors.primary,
                size: deviceWidth * 0.07,
              ),
            ),
            SizedBox(width: deviceWidth * 0.04),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notif.title,
                    style: AppTheme.of(context).textStyle.titleMedium.copyWith(
                      color: AppTheme.of(context).colors.primaryTextColor,
                      fontWeight:
                          notif.isRead ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: deviceWidth * 0.01),
                  Text(
                    notif.message,
                    style: AppTheme.of(
                      context,
                    ).textStyle.bodyMedium.copyWith(color: Colors.grey[700]),
                  ),
                  SizedBox(height: deviceWidth * 0.02),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      DateFormat(
                        'd MMM HH:mm',
                        'id_ID',
                      ).format(notif.createdAt),
                      style: AppTheme.of(context).textStyle.bodySmall.copyWith(
                        color: Colors.grey[500],
                        fontSize: deviceWidth * 0.032,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    return Center(
      child: RefreshIndicator(
        onRefresh: () async {
          final authProvider = context.read<AuthProviderApp>();
          final token = authProvider.jwtToken;
          if (token != null) {
            await context.read<NotificationProvider>().fetchNotifications();
          }
        },
        child: ListView(
          shrinkWrap: true,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_off_outlined,
                  size: deviceWidth * 0.18,
                  color: Colors.grey[300],
                ),
                SizedBox(height: deviceWidth * 0.04),
                Text(
                  'Belum ada notifikasi',
                  style: AppTheme.of(context).textStyle.titleMedium.copyWith(
                    color: AppTheme.of(context).colors.primaryTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, NotificationProvider provider) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(deviceWidth * 0.08),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: deviceWidth * 0.15,
              color: Colors.grey[400],
            ),
            SizedBox(height: deviceWidth * 0.04),
            Text(
              'Gagal memuat notifikasi',
              style: AppTheme.of(context).textStyle.titleMedium.copyWith(
                color: AppTheme.of(context).colors.primaryTextColor,
              ),
            ),
            SizedBox(height: deviceWidth * 0.02),
            Text(
              provider.error ?? '',
              style: AppTheme.of(context).textStyle.bodyMedium.copyWith(
                color: AppTheme.of(context).colors.secondaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: deviceWidth * 0.04),
            ElevatedButton(
              onPressed: () async {
                final authProvider = context.read<AuthProviderApp>();
                final token = authProvider.jwtToken;
                if (token != null) {
                  await provider.fetchNotifications();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.of(context).colors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: deviceWidth * 0.08,
                  vertical: deviceHeight * 0.015,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Coba Lagi',
                style: AppTheme.of(context).textStyle.labelLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
