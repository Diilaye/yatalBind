import '/screen/Concours/participate_screen.dart';
import '/screen/nav_bar_screen.dart';
import '/utils/colors.dart';
import '/utils/images_string.dart';
import '/widgets/concours/concours_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yaatal_mbindum/bloc/controllers/language_controller.dart';

class ConcoursScreen extends StatefulWidget {
  const ConcoursScreen({super.key});

  @override
  State<ConcoursScreen> createState() => _ConcoursScreenState();
}

class _ConcoursScreenState extends State<ConcoursScreen>
    with TickerProviderStateMixin {
  final LanguageController langController = Get.find<LanguageController>();

  late AnimationController _fabAnimController;
  late Animation<double> _fabScaleAnim;

  @override
  void initState() {
    super.initState();
    _fabAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fabScaleAnim =
        CurvedAnimation(parent: _fabAnimController, curve: Curves.elasticOut);
    Future.delayed(
        const Duration(milliseconds: 400), () => _fabAnimController.forward());
  }

  @override
  void dispose() {
    _fabAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Obx(() => Directionality(
          textDirection: langController.isRTL.value
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: Scaffold(
            body: Stack(
              children: [
                // ── Fond d'écran global ──
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/plandetravail.png',
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          yDarkColor.withValues(alpha: 0.85),
                          yDarkColor.withValues(alpha: 0.97),
                        ],
                        stops: const [0.0, 0.5],
                      ),
                    ),
                  ),
                ),

                // ── Contenu ──
                CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // ── SliverAppBar avec image hero ──
                    SliverAppBar(
                      expandedHeight: size.height * 0.38,
                      pinned: true,
                      backgroundColor: yDarkColor,
                      automaticallyImplyLeading: false,
                      flexibleSpace: FlexibleSpaceBar(
                        background: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Image hero
                            Image.asset(
                              welcomeScreen,
                              fit: BoxFit.cover,
                            ),
                            // Overlay dégradé bas
                            DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    yDarkColor.withValues(alpha: 0.85),
                                  ],
                                  stops: const [0.45, 1.0],
                                ),
                              ),
                            ),
                            // Titre hero en bas de l'image
                            Positioned(
                              bottom: 24,
                              left: 20,
                              right: 20,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: yGoldColor.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color:
                                              yGoldColor.withValues(alpha: 0.5),
                                          width: 1),
                                    ),
                                    child: Text(
                                      'yaatal_mbinde_contest'.tr,
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: yGoldColor,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'information'.tr,
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800,
                                      color: yWhiteColor,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Bouton retour
                            Positioned(
                              top: 48,
                              left: langController.isRTL.value ? null : 16,
                              right: langController.isRTL.value ? 16 : null,
                              child: _circleBtn(
                                icon: langController.isRTL.value
                                    ? Icons.arrow_forward_rounded
                                    : Icons.arrow_back_rounded,
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) => const NavBarScreen()),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ── Corps du contenu ──
                    SliverToBoxAdapter(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.transparent,
                        ),
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Stats en grille 2x2 ──
                            _buildStatsSection(context),
                            const SizedBox(height: 32),

                            // ── Résultats Concours ──
                            _buildSectionHeader(
                              'contest_results'.tr,
                              onSeeAll: () {},
                            ),
                            const SizedBox(height: 14),
                            ConcoursInfoWidget(),
                            const SizedBox(height: 32),

                            // ── Pourquoi Yaatal Mbinde ──
                            _buildSectionHeader(
                              'why_yaatal_mbinde'.tr,
                              onSeeAll: null,
                            ),
                            const SizedBox(height: 14),
                            const ConcoursInfoWidget(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // ── FAB Participer ──
                Positioned(
                  bottom: 54,
                  left: 20,
                  right: 20,
                  child: ScaleTransition(
                    scale: _fabScaleAnim,
                    child: _buildParticipateButton(context),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  // ── Stats section ──
  Widget _buildStatsSection(BuildContext context) {
    final stats = [
      _StatItem(
          name: 'participation_rate'.tr,
          amount: '+1000 P',
          percent: 90,
          data: 0.9,
          color: ySecondaryColor),
      _StatItem(
          name: 'regions'.tr,
          amount: '+14',
          percent: 90,
          data: 0.9,
          color: yGoldColor),
      _StatItem(
          name: 'boys'.tr,
          amount: '+700',
          percent: 70,
          data: 0.7,
          color: yTertiaryColor),
      _StatItem(
          name: 'girls'.tr,
          amount: '+300',
          percent: 30,
          data: 0.3,
          color: const Color(0xFFAB68E0)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 20,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [yGoldColor, yGoldLight],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'information'.tr,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: yWhiteColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 450;
            if (isNarrow) {
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildStatCard(stats[0])),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatCard(stats[1])),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildStatCard(stats[2])),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatCard(stats[3])),
                    ],
                  ),
                ],
              );
            }
            return Row(
              children: stats
                  .map((s) => Expanded(
                        child: Padding(
                          padding:
                              EdgeInsets.only(right: s == stats.last ? 0 : 12),
                          child: _buildStatCard(s),
                        ),
                      ))
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatCard(_StatItem stat) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: yWhiteColor.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(18),
        border:
            Border.all(color: yWhiteColor.withValues(alpha: 0.12), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stat.amount,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: stat.color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            stat.name,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10,
              color: yWhiteColor.withValues(alpha: 0.6),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: stat.data,
              minHeight: 5,
              backgroundColor: yWhiteColor.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(stat.color),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${stat.percent}%',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: stat.color,
            ),
          ),
        ],
      ),
    );
  }

  // ── Section header ──
  Widget _buildSectionHeader(String title, {VoidCallback? onSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                width: 3,
                height: 20,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [yGoldColor, yGoldLight],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: yWhiteColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (onSeeAll != null) ...[
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onSeeAll,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: yGoldColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: yGoldColor.withValues(alpha: 0.4), width: 1),
              ),
              child: Text(
                'see_all'.tr,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: yGoldColor,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ── Bouton Participer (FAB) ──
  Widget _buildParticipateButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [yGoldColor, yGoldLight, yGoldColor],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: yGoldShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ParticipateScreen()),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: yDarkColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.how_to_reg_rounded,
                    color: yDarkColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'participate'.tr,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: yDarkColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _circleBtn({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: yDarkColor.withValues(alpha: 0.55),
          shape: BoxShape.circle,
          border:
              Border.all(color: yWhiteColor.withValues(alpha: 0.25), width: 1),
        ),
        child: Icon(icon, color: yWhiteColor, size: 20),
      ),
    );
  }
}

// ── Modèle stat ──
class _StatItem {
  final String name;
  final String amount;
  final int percent;
  final double data;
  final Color color;

  const _StatItem({
    required this.name,
    required this.amount,
    required this.percent,
    required this.data,
    required this.color,
  });
}
