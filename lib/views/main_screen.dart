import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:olx_clone/views/home/halaman_new.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

import 'package:olx_clone/utils/theme.dart';
import 'package:olx_clone/providers/profile_provider.dart';
import 'package:olx_clone/views/home/home_view.dart';
import 'package:olx_clone/views/chat/chat_view.dart';
import 'package:olx_clone/views/myAds/my_ads_view.dart';
import 'package:olx_clone/views/product/select_category_view.dart';
import 'package:olx_clone/views/profile/profile_view.dart';
import 'package:olx_clone/views/sell/sell_screen.dart';

class MainScreen extends StatefulWidget {
  final int? initialTab;

  const MainScreen({super.key, this.initialTab});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  AnimationController? _fabAnimationController;
  Animation<double>? _fabAnimation;
  final List<Widget> _screens = [
    const HomeView(),
    const ChatView(),
    const SellScreen(),
    const MyAdsView(),
    const ProfileView(),
    // const HalamanNew(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab ?? 0;
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _fabAnimationController!,
        curve: Curves.easeInOut,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileProvider = context.read<ProfileProvider>();
      if (profileProvider.user == null) {
        profileProvider.fetchUserProfile();
      }
    });
  }

  @override
  void dispose() {
    _fabAnimationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomNavHeight = screenHeight * 0.075;
    final clampedNavHeight = bottomNavHeight.clamp(60.0, 80.0);

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(30),
              offset: const Offset(0, 2),
              blurRadius: 3,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Container(
              height: clampedNavHeight,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    offset: const Offset(0, -2),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                  BoxShadow(
                    color: Colors.black.withAlpha(4),
                    offset: const Offset(0, -1),
                    blurRadius: 4,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: clampedNavHeight * 0.05,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(
                      index: 0,
                      iconOutlined: Icons.storefront_outlined,
                      iconFilled: Icons.storefront_rounded,
                      label: 'Home',
                    ),
                    _buildNavItem(
                      index: 1,
                      iconOutlined: FontAwesomeIcons.comment,
                      iconFilled: FontAwesomeIcons.solidComment,
                      label: 'Chat',
                    ),
                    const SizedBox(width: 48),
                    _buildNavItem(
                      index: 3,
                      iconOutlined: Icons.favorite_border,
                      iconFilled: Icons.favorite,
                      label: 'Iklan Saya',
                    ),
                    _buildNavItem(
                      index: 4,
                      iconOutlined: Icons.person_outline_rounded,
                      iconFilled: Icons.person_rounded,
                      label: 'Akun Saya',
                    ),
                    // _buildNavItem(
                    //   index: 5,
                    //   iconOutlined: Icons.pages_outlined,
                    //   iconFilled: Icons.pages,
                    //   label: 'Halaman Baru',
                    // ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: -(clampedNavHeight * 0.6),
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    _fabAnimation != null
                        ? ScaleTransition(
                          scale: _fabAnimation!,
                          child: _buildFABContainer(),
                        )
                        : _buildFABContainer(),
                    Text(
                      'Jual',
                      style: AppTheme.of(context).textStyle.bodySmall.copyWith(
                        color: AppTheme.of(context).colors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: MediaQuery.of(context).size.width * 0.028,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData iconOutlined,
    required IconData iconFilled,
    required String label,
  }) {
    final bool isSelected = _currentIndex == index;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onItemTapped(index),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height * 0.008,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isSelected ? iconFilled : iconOutlined,
                    key: ValueKey('$index-$isSelected'),
                    color:
                        isSelected
                            ? AppTheme.of(context).colors.primary
                            : Colors.grey[600],
                    size: MediaQuery.of(context).size.width * 0.065,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.003),
                Text(
                  label,
                  style: TextStyle(
                    color:
                        isSelected
                            ? AppTheme.of(context).colors.primary
                            : Colors.grey[600],
                    fontSize: MediaQuery.of(context).size.width * 0.03,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFABContainer() {
    final fabSize = MediaQuery.of(context).size.width * 0.18;
    final clampedFabSize = fabSize.clamp(60.0, 80.0);

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: clampedFabSize,
          width: clampedFabSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                offset: const Offset(0, 8),
                blurRadius: 16,
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withAlpha(20),
                offset: const Offset(0, 4),
                blurRadius: 8,
                spreadRadius: 0,
              ),
            ],
          ),
          child: CustomPaint(painter: FullCircleTripleArcPainter()),
        ),
        FloatingActionButton(
          heroTag: "main_screen_fab",
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SelectCategoryView(),
              ),
            );
          },
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, size: 28),
        ),
      ],
    );
  }
}

class FullCircleTripleArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 6.0;
    final radius = size.width / 2;
    final arcRadius = radius - strokeWidth / 2 - 2.0;
    final arcRect = Rect.fromCircle(
      center: Offset(radius, radius),
      radius: arcRadius,
    );

    final sweepAngle = 2 * math.pi / 3;
    final startAngles = [
      -math.pi / 2,
      -math.pi / 2 + sweepAngle,
      -math.pi / 2 + 2 * sweepAngle,
    ];
    final colors = [Colors.cyan, Colors.amber, Colors.blue];

    for (int i = 0; i < 3; i++) {
      final paint =
          Paint()
            ..color = colors[i]
            ..style = PaintingStyle.stroke
            ..strokeWidth = strokeWidth
            ..strokeCap = StrokeCap.butt;

      canvas.drawArc(arcRect, startAngles[i], sweepAngle, false, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
