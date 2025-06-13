import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:math' as math;

import 'package:olx_clone/utils/theme.dart';
import 'package:olx_clone/view/home/home_view.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  AnimationController? _fabAnimationController;
  Animation<double>? _fabAnimation;

  final List<Widget> _screens = [
    HomeView(),
    const Center(child: Text('Chat')),
    const Center(child: Text('Jual')),
    const Center(child: Text('Iklan Saya')),
    const Center(child: Text('Akun Saya')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
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
  }

  @override
  void dispose() {
    _fabAnimationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              height: 60,
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
                padding: const EdgeInsets.symmetric(vertical: 2),
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
                  ],
                ),
              ),
            ),
            Positioned(
              top: -35,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => _onItemTapped(2),
                    child:
                        _fabAnimation != null
                            ? ScaleTransition(
                              scale: _fabAnimation!,
                              child: _buildFABContainer(),
                            )
                            : _buildFABContainer(),
                  ),
                  const SizedBox(height: 10),
                  Text('Jual', style: AppTheme.of(context).textStyle.bodySmall.copyWith(
                    color: AppTheme.of(context).colors.primary,
                    fontWeight: FontWeight.w600,
                  )),
                ],
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
            padding: const EdgeInsets.symmetric(vertical: 6),
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
                    size: 26,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    color:
                        isSelected
                            ? AppTheme.of(context).colors.primary
                            : Colors.grey[600],
                    fontSize: 12,
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
    return Container(
      height: 60,
      width: 60,
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
      child: CustomPaint(
        painter: FullCircleTripleArcPainter(),
        child: Center(
          child: Container(
            height: 50,
            width: 50,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.add, size: 30),
          ),
        ),
      ),
    );
  }
}

class FullCircleTripleArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 6.0;
    final radius = size.width / 2;
    final arcRect = Rect.fromCircle(
      center: Offset(radius, radius),
      radius: radius - strokeWidth / 2,
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
