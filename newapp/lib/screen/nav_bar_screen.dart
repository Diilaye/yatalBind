import '/screen/Concours/concours.dart';
import '/screen/Contact/contact.dart';
import '/screen/Events/events.dart';
import '/screen/Gallery/gallery_screen.dart'
    hide yAccentColor, ySecondaryColor, yDarkColor, yWhiteColor;
import '/screen/Home/home_screen.dart';
import '/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NavBarScreen extends StatefulWidget {
  const NavBarScreen({super.key});

  @override
  State<NavBarScreen> createState() => _NavBarScreenState();
}

class _NavBarScreenState extends State<NavBarScreen>
    with TickerProviderStateMixin {
  int currentIndex = 2;

  // Animation controller pour l'indicateur actif
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  final List<_NavItem> _navItems = const [
    _NavItem(
      icon: Icons.emoji_events_outlined,
      activeIcon: Icons.emoji_events,
      label: 'Concours',
      labelAr: 'المسابقة',
    ),
    _NavItem(
      icon: Icons.play_circle_outline_rounded,
      activeIcon: Icons.play_circle_rounded,
      label: 'Événements',
      labelAr: 'الفعاليات',
    ),
    _NavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Accueil',
      labelAr: 'الرئيسية',
    ),
    _NavItem(
      icon: Icons.photo_library_outlined,
      activeIcon: Icons.photo_library_rounded,
      label: 'Galerie',
      labelAr: 'المعرض',
    ),
    _NavItem(
      icon: Icons.contact_mail_outlined,
      activeIcon: Icons.contact_mail_rounded,
      label: 'Contact',
      labelAr: 'اتصل بنا',
    ),
  ];

  final List<Widget> _screens = [
    const ConcoursScreen(),
    const EventsScreen(),
    const HomeScreen(),
    const GalleryScreen(),
    ContactScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _scaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index == currentIndex) return;
    HapticFeedback.lightImpact();
    setState(() => currentIndex = index);
    _animController.reset();
    _animController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _screens[currentIndex],
      bottomNavigationBar: _buildNavBar(),
    );
  }

  Widget _buildNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: yDarkColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: yGoldColor.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 68,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_navItems.length, (index) {
              return _buildNavItem(index);
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final item = _navItems[index];
    final isActive = currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icône avec indicateur pill
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: isActive
                      ? yGoldColor.withOpacity(0.18)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: isActive
                      ? Border.all(color: yGoldColor.withOpacity(0.4), width: 1)
                      : null,
                ),
                child: ScaleTransition(
                  scale:
                      isActive ? _scaleAnim : const AlwaysStoppedAnimation(1.0),
                  child: Icon(
                    isActive ? item.activeIcon : item.icon,
                    size: isActive ? 24 : 22,
                    color:
                        isActive ? yGoldColor : yWhiteColor.withOpacity(0.45),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              // Label
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                  color: isActive ? yGoldColor : yWhiteColor.withOpacity(0.45),
                  letterSpacing: isActive ? 0.3 : 0,
                ),
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Modèle d'item de navigation
class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String labelAr;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.labelAr,
  });
}
