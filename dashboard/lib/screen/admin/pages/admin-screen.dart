// DIFF vs votre fichier original (admin-screen.dart) :
//   [1] AdminPage.sms ajouté dans le switch _buildPage() → SmsComposePanel
//   [2] Item "SMS Candidats" ajouté dans la sidebar (était présent visuellement
//       dans certains designs mais non branché)
//   [3] Déconnexion via authBloc.logoutSilent() — pas de context.go()
//   [4] Layout responsive via votre deviceName() existant
//   [5] Import responsive-ui.dart pour ScreenType / deviceName

import 'package:dashboard/bloc/auth-bloc.dart';
import 'package:dashboard/bloc/menu-bloc.dart';
import 'package:dashboard/screen/admin/pages/candidats_screen.dart';
import 'package:dashboard/screen/admin/pages/over-view-admin.dart';
import 'package:dashboard/screen/admin/widgets/sms/sms_compose_panel.dart';
import 'package:dashboard/utils/coolors-by-dii.dart';
import 'package:dashboard/utils/responsive-ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dashboard/screen/admin/pages/gallery_admin_screen.dart';
import 'package:dashboard/screen/admin/pages/home_config_screen.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screen = deviceName(size);

    if (screen == ScreenType.Mobile) return const _MobileLayout();
    return const _DesktopLayout();
  }
}

// ─── Desktop / Tablette ───────────────────────────────────────────────────────

class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout();

  @override
  Widget build(BuildContext context) {
    final menuBloc = context.watch<MenuAdminBloc>();
    final size = MediaQuery.of(context).size;
    final sidebarWidth = size.width >= 1280 ? 240.0 : 200.0;

    return Scaffold(
      body: Row(
        children: [
          SizedBox(width: sidebarWidth, child: const _Sidebar()),
          Expanded(child: _buildPage(context, menuBloc.currentPage)),
        ],
      ),
    );
  }
}

// ─── Mobile ───────────────────────────────────────────────────────────────────

class _MobileLayout extends StatelessWidget {
  const _MobileLayout();

  @override
  Widget build(BuildContext context) {
    final menuBloc = context.watch<MenuAdminBloc>();

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 52,
        backgroundColor: blanc,
        elevation: 0,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded, size: 22),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: Text(
          _pageLabel(menuBloc.currentPage),
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
      ),
      drawer: const Drawer(child: _Sidebar()),
      body: _buildPage(context, menuBloc.currentPage),
    );
  }
}

// ─── Routing interne ──────────────────────────────────────────────────────────

Widget _buildPage(BuildContext context, AdminPage page) {
  switch (page) {
    case AdminPage.dashboard:
      return const OverViewAdmin();
    case AdminPage.candidats:
      return const CandidatsScreen();
    case AdminPage.sms:
      // [FIX] Page SMS maintenant accessible depuis le menu
      return const Scaffold(
        body: Padding(
          padding: EdgeInsets.all(20),
          child: SmsComposePanel(),
        ),
      );
    case AdminPage.homeConfig:
      return const HomeConfigScreen();

    case AdminPage.gallery:
      return const GalleryAdminScreen();

    case AdminPage.evenements:
      return _Placeholder(
          title: 'Événements', icon: CupertinoIcons.calendar_badge_plus);
    case AdminPage.articles:
      return _Placeholder(title: 'Articles', icon: CupertinoIcons.doc_richtext);
    case AdminPage.help:
      return _Placeholder(
          title: 'Aide & Support', icon: CupertinoIcons.headphones);
    case AdminPage.settings:
      return _Placeholder(
          title: 'Paramètres', icon: CupertinoIcons.settings_solid);
  }
}

String _pageLabel(AdminPage page) {
  const m = {
    AdminPage.dashboard: 'Dashboard',
    AdminPage.candidats: 'Candidats',
    AdminPage.sms: 'SMS Candidats',
    AdminPage.gallery: 'Images',
    AdminPage.evenements: 'Événements',
    AdminPage.articles: 'Articles',
    AdminPage.help: 'Aide & Support',
    AdminPage.settings: 'Paramètres',
  };
  return m[page] ?? '';
}

// ─── Sidebar ──────────────────────────────────────────────────────────────────

class _Sidebar extends StatelessWidget {
  const _Sidebar();

  @override
  Widget build(BuildContext context) {
    final menuBloc = context.watch<MenuAdminBloc>();

    void go(AdminPage p) {
      menuBloc.navigate(p);
      final scaffold = Scaffold.maybeOf(context);
      if (scaffold != null && scaffold.isDrawerOpen)
        Navigator.of(context).pop();
    }

    return Container(
      color: blanc,
      child: Column(
        children: [
          // ── Brand ─────────────────────────────────────────────────────
          GestureDetector(
            onTap: () => go(AdminPage.dashboard),
            child: Container(
              padding: const EdgeInsets.fromLTRB(18, 22, 18, 16),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                        color: vert, borderRadius: BorderRadius.circular(8)),
                    child: const Center(
                      child: Text('YM',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w900)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Yaatal',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: vert)),
                      Text('Mbinde Admin',
                          style: TextStyle(
                              fontSize: 10, color: Colors.grey.shade500)),
                    ],
                  ),
                ],
              ),
            ),
          ),

          Divider(height: 1, color: Colors.grey.shade100),
          const SizedBox(height: 8),

          // ── Menu principal ─────────────────────────────────────────────
          _SectionLabel('MENU PRINCIPAL'),
          _NavItem(
              icon: CupertinoIcons.square_grid_2x2_fill,
              label: 'Dashboard',
              page: AdminPage.dashboard,
              current: menuBloc.currentPage,
              onTap: () => go(AdminPage.dashboard)),
          _NavItem(
              icon: CupertinoIcons.person_2_fill,
              label: 'Candidats',
              page: AdminPage.candidats,
              current: menuBloc.currentPage,
              onTap: () => go(AdminPage.candidats)),
          // [FIX] SMS CANDIDATS — item maintenant visible et branché
          _NavItem(
              icon: CupertinoIcons.chat_bubble_text_fill,
              label: 'SMS Candidats',
              page: AdminPage.sms,
              current: menuBloc.currentPage,
              onTap: () => go(AdminPage.sms)),

          const SizedBox(height: 8),

          _SectionLabel('APP MOBILE'),
          _NavItem(
            icon: CupertinoIcons.home,
            label: 'Home Screen',
            page: AdminPage.homeConfig,
            current: menuBloc.currentPage,
            onTap: () => go(AdminPage.homeConfig),
          ),
          _NavItem(
            icon: CupertinoIcons.photo_fill_on_rectangle_fill,
            label: 'Galerie',
            page: AdminPage.gallery,
            current: menuBloc.currentPage,
            onTap: () => go(AdminPage.gallery),
          ),
          _NavItem(
              icon: CupertinoIcons.calendar_badge_plus,
              label: 'Événements',
              page: AdminPage.evenements,
              current: menuBloc.currentPage,
              onTap: () => go(AdminPage.evenements)),
          _NavItem(
              icon: CupertinoIcons.doc_richtext,
              label: 'Articles',
              page: AdminPage.articles,
              current: menuBloc.currentPage,
              onTap: () => go(AdminPage.articles)),

          const Spacer(),
          Divider(height: 1, color: Colors.grey.shade100),

          _NavItem(
              icon: CupertinoIcons.headphones,
              label: 'Aide & Support',
              page: AdminPage.help,
              current: menuBloc.currentPage,
              onTap: () => go(AdminPage.help)),
          _NavItem(
              icon: CupertinoIcons.settings_solid,
              label: 'Paramètres',
              page: AdminPage.settings,
              current: menuBloc.currentPage,
              onTap: () => go(AdminPage.settings)),

          // [FIX] Déconnexion — logoutSilent() sans context.go()
          _LogoutTile(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ─── Item de navigation ───────────────────────────────────────────────────────

class _NavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final AdminPage page;
  final AdminPage current;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.page,
    required this.current,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.page == widget.current;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 130),
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            color: active
                ? vert.withOpacity(0.09)
                : _hovered
                    ? Colors.grey.shade50
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 130),
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: active ? vert.withOpacity(0.13) : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(widget.icon,
                    size: 14, color: active ? vert : Colors.grey.shade500),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                    color: active ? vert : const Color(0xFF1A202C),
                  ),
                ),
              ),
              if (active)
                Container(
                  width: 3,
                  height: 14,
                  decoration: BoxDecoration(
                    color: vert,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 2),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade400,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

// ─── Bouton déconnexion ───────────────────────────────────────────────────────

class _LogoutTile extends StatefulWidget {
  @override
  State<_LogoutTile> createState() => _LogoutTileState();
}

class _LogoutTileState extends State<_LogoutTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => _confirmLogout(context),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 130),
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            color: _hovered ? Colors.red.shade50 : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: _hovered ? Colors.red.shade100 : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(Icons.logout_rounded,
                    size: 14,
                    color:
                        _hovered ? Colors.red.shade700 : Colors.grey.shade500),
              ),
              const SizedBox(width: 9),
              Text(
                'Déconnexion',
                style: TextStyle(
                  fontSize: 13,
                  color:
                      _hovered ? Colors.red.shade700 : const Color(0xFF1A202C),
                  fontWeight: _hovered ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Déconnexion',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        content: const Text('Voulez-vous vraiment vous déconnecter ?',
            style: TextStyle(fontSize: 14, color: Color(0xFF4A5568))),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child:
                Text('Annuler', style: TextStyle(color: Colors.grey.shade500)),
          ),
          ElevatedButton(
            // [FIX] logoutSilent() → notifyListeners() → router → '/'
            onPressed: () async {
              Navigator.of(ctx).pop();
              await context.read<AuthBloc>().logoutSilent();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            child: const Text('Déconnecter'),
          ),
        ],
      ),
    );
  }
}

// ─── Placeholder ──────────────────────────────────────────────────────────────

class _Placeholder extends StatelessWidget {
  final String title;
  final IconData icon;
  const _Placeholder({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF1F5F8),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                  color: vert.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(18)),
              child: Icon(icon, size: 32, color: vert),
            ),
            const SizedBox(height: 16),
            Text(title,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A202C))),
            const SizedBox(height: 8),
            Text('Section en cours de développement',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }
}
