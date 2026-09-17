import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// ──────────────────────────────────────────────────────────────────────────
///  PrivacyScreen — Politique de confidentialité C3S YAATAL
///  Trilingue : Français / Arabe / Anglais
///  Accessible depuis la page Contact via un lien
/// ──────────────────────────────────────────────────────────────────────────

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen>
    with TickerProviderStateMixin {
  // ── langue courante : 'fr' | 'ar' | 'en'
  String _lang = 'fr';

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  // ── Palette islamique ──────────────────────────────────
  static const Color _greenDeep = Color(0xFF0A3D1F);
  static const Color _greenMid = Color(0xFF145A32);
  static const Color _gold = Color(0xFFC9A84C);
  static const Color _goldLight = Color(0xFFF0D080);
  static const Color _goldPale = Color(0xFFFDF4DC);
  static const Color _cream = Color(0xFFFAF8F2);
  static const Color _textMid = Color(0xFF3D3D3D);

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _switchLang(String lang) {
    if (_lang == lang) return;
    _fadeCtrl.reverse().then((_) {
      setState(() => _lang = lang);
      _fadeCtrl.forward();
    });
  }

  // ── Contenu trilingue ──────────────────────────────────
  List<_Section> get _sections => _content[_lang]!;

  static const Map<String, List<_Section>> _content = {
    // ─────────────────── FRANÇAIS ───────────────────────
    'fr': [
      _Section('Introduction',
          intro:
              'La présente politique décrit comment la COMPAGNIE SERIGNE SECKE SENEGAL (C3S) collecte, utilise et protège les données personnelles des utilisateurs de l\'application CONCOURS C3S YAATAL MBINDUM AL XURANE.',
          highlight:
              'Objectif : promouvoir un concours de calligraphie du Saint Coran pour les jeunes au Sénégal.'),
      _Section('Données collectées',
          items: [
            'Nom et prénom',
            'Numéro de téléphone',
            'Date de naissance',
            'Localisation géographique',
            'Photos et vidéos liées au concours',
          ],
          highlight:
              'Ces données sont collectées uniquement lorsque nécessaire.'),
      _Section('Utilisation des données', items: [
        'Inscription et gestion des participants',
        'Vérification de l\'éligibilité (âge)',
        'Organisation des auditions et du concours',
        'Communication (SMS et notifications)',
        'Publication des résultats',
        'Amélioration de l\'application',
      ]),
      _Section('Utilisation par les mineurs',
          highlight: '⚠️ Application réservée aux 13 ans et plus.',
          items: [
            'Autorisation parentale obligatoire',
            'Âge vérifié via la date de naissance',
            'Validation possible lors des auditions physiques',
          ]),
      _Section('Partage des données',
          intro:
              'Données partagées uniquement avec les services techniques nécessaires (ex : API SMS Orange).',
          highlight:
              'Aucune donnée personnelle n\'est vendue ni partagée à des fins commerciales.'),
      _Section('Contenus publiés',
          intro: 'Les utilisateurs ne peuvent pas publier de contenu.',
          items: [
            'Contenus gérés exclusivement par les administrateurs',
            'Accessibles publiquement',
          ]),
      _Section('Notifications',
          items: [
            'Notifications push',
            'SMS via services partenaires',
          ],
          intro:
              'Communications relatives uniquement au concours et aux résultats.'),
      _Section('Stockage & Sécurité',
          intro: 'Données stockées sur des serveurs sécurisés (MongoDB, OVH).',
          items: [
            'Protocole HTTPS',
            'Chiffrement des données',
            'Accès sécurisé aux systèmes',
          ]),
      _Section('Durée de conservation',
          intro:
              'Données conservées uniquement pendant la durée nécessaire au concours et aux obligations légales.'),
      _Section('Droits des utilisateurs',
          items: [
            'Droit d\'accès à leurs données',
            'Droit de rectification',
            'Droit de suppression',
          ],
          highlight: 'Demandes à envoyer à : contactyma@c3s.sn',
          email: true),
      _Section('Suppression des données',
          intro:
              'Demande de suppression possible par email : contactyma@c3s.sn',
          email: true),
      _Section('Publication des résultats',
          intro:
              'Noms, prénoms et images des gagnants peuvent être publiés publiquement.'),
      _Section('Modifications',
          intro:
              'Cette politique peut être mise à jour à tout moment. Les utilisateurs seront informés des modifications importantes.'),
      _Section('Contact',
          isContact: true,
          intro:
              'COMPAGNIE SERIGNE SECKE SENEGAL (C3S)\n📍 KM 6.5 Route de Rufisque Yarakh, Dakar, Sénégal\n📧 contactyma@c3s.sn',
          email: true),
      _Section('Acceptation',
          isAcceptance: true,
          intro:
              'En utilisant l\'application, vous acceptez la présente politique de confidentialité.'),
    ],

    // ─────────────────── ENGLISH ────────────────────────
    'en': [
      _Section('Introduction',
          intro:
              'This privacy policy describes how COMPAGNIE SERIGNE SECKE SENEGAL (C3S) collects, uses and protects personal data of users of the CONCOURS C3S YAATAL MBINDUM AL XURANE application.',
          highlight:
              'Purpose: promote a Holy Quran calligraphy competition for young people in Senegal.'),
      _Section('Data Collected',
          items: [
            'First and last name',
            'Phone number',
            'Date of birth',
            'Geographic location',
            'Photos and videos related to the competition',
          ],
          highlight: 'Data collected only when necessary.'),
      _Section('Use of Data', items: [
        'Registration and management of participants',
        'Eligibility verification (age)',
        'Organization of auditions and competition',
        'Communication (SMS and notifications)',
        'Publication of results',
        'Application improvement',
      ]),
      _Section('Use by Minors',
          highlight: '⚠️ Application strictly for users aged 13 and over.',
          items: [
            'Parental consent is mandatory',
            'Age verified through date of birth',
            'Additional validation may occur during physical auditions',
          ]),
      _Section('Data Sharing',
          intro:
              'Data shared only with technical services necessary for operation (e.g., Orange SMS API).',
          highlight:
              'No personal data is sold or shared for commercial purposes.'),
      _Section('Published Content',
          intro: 'Users cannot publish content.',
          items: [
            'Content managed exclusively by administrators',
            'Publicly accessible',
          ]),
      _Section('Notifications',
          items: ['Push notifications', 'SMS via partner services'],
          intro: 'Communications relate only to the competition and results.'),
      _Section('Storage & Security',
          intro: 'Data stored on secure servers (MongoDB, OVH).',
          items: [
            'HTTPS protocol',
            'Data encryption',
            'Secure system access',
          ]),
      _Section('Retention Period',
          intro:
              'Personal data retained only as long as necessary for the competition and legal obligations.'),
      _Section('User Rights',
          items: [
            'Right of access to their data',
            'Right of rectification',
            'Right of erasure',
          ],
          highlight: 'Requests to: contactyma@c3s.sn',
          email: true),
      _Section('Data Deletion',
          intro: 'Deletion requests can be made by email: contactyma@c3s.sn',
          email: true),
      _Section('Publication of Results',
          intro:
              'Names and possibly images of winners may be publicly published.'),
      _Section('Policy Changes',
          intro:
              'This policy may be updated at any time. Users will be notified of significant changes.'),
      _Section('Contact',
          isContact: true,
          intro:
              'COMPAGNIE SERIGNE SECKE SENEGAL (C3S)\n📍 KM 6.5 Route de Rufisque Yarakh, Dakar, Senegal\n📧 contactyma@c3s.sn',
          email: true),
      _Section('Acceptance',
          isAcceptance: true,
          intro: 'By using the application, you accept this privacy policy.'),
    ],

    // ─────────────────── ARABIC ─────────────────────────
    'ar': [
      _Section('مقدمة',
          intro:
              'تصف سياسة الخصوصية هذه كيفية جمع شركة C3S واستخدام وحماية البيانات الشخصية لمستخدمي تطبيق مسابقة ياتال مبيندوم الخران.',
          highlight: 'الهدف: تعزيز مسابقة خط القرآن الكريم للشباب في السنغال.'),
      _Section('البيانات المجمعة',
          items: [
            'الاسم الأول والعائلي',
            'رقم الهاتف',
            'تاريخ الميلاد',
            'الموقع الجغرافي',
            'الصور ومقاطع الفيديو المتعلقة بالمسابقة',
          ],
          highlight: 'تُجمع البيانات فقط عند الضرورة.'),
      _Section('استخدام البيانات', items: [
        'التسجيل وإدارة المشاركين',
        'التحقق من الأهلية (السن)',
        'تنظيم التصفيات والمسابقة',
        'التواصل (رسائل SMS وإشعارات)',
        'نشر النتائج',
        'تحسين التطبيق',
      ]),
      _Section('استخدام القاصرين',
          highlight: '⚠️ التطبيق مخصص لمن تبلغ أعمارهم 13 عاماً فأكثر.',
          items: [
            'موافقة ولي الأمر إلزامية',
            'التحقق من السن عبر تاريخ الميلاد',
            'تحقق إضافي ممكن خلال التصفيات الحضورية',
          ]),
      _Section('مشاركة البيانات',
          intro:
              'تتم مشاركة البيانات فقط مع الخدمات التقنية الضرورية (مثل: Orange SMS API).',
          highlight: 'لا يتم بيع أي بيانات شخصية أو مشاركتها لأغراض تجارية.'),
      _Section('المحتوى المنشور',
          intro: 'لا يمكن للمستخدمين نشر أي محتوى.',
          items: [
            'المحتوى يُدار حصراً من قِبل المسؤولين',
            'متاح للعموم',
          ]),
      _Section('الإشعارات',
          items: ['إشعارات فورية', 'رسائل SMS عبر خدمات شريكة'],
          intro: 'تتعلق الاتصالات فقط بالمسابقة والنتائج.'),
      _Section('التخزين والأمان',
          intro: 'تُخزَّن البيانات على خوادم آمنة (MongoDB، OVH).',
          items: [
            'بروتوكول HTTPS',
            'تشفير البيانات',
            'وصول آمن للأنظمة',
          ]),
      _Section('مدة الاحتفاظ',
          intro:
              'تُحتفظ بالبيانات فقط طوال المدة الضرورية للمسابقة والالتزامات القانونية.'),
      _Section('حقوق المستخدمين',
          items: [
            'حق الوصول إلى البيانات',
            'حق التصحيح',
            'حق الحذف',
          ],
          highlight: 'الطلبات إلى: contactyma@c3s.sn',
          email: true),
      _Section('حذف البيانات',
          intro: 'طلبات الحذف عبر البريد الإلكتروني: contactyma@c3s.sn',
          email: true),
      _Section('نشر النتائج', intro: 'قد يتم نشر أسماء وصور الفائزين علناً.'),
      _Section('تعديلات السياسة',
          intro:
              'يمكن تحديث هذه السياسة في أي وقت. سيتم إخطار المستخدمين بالتعديلات الجوهرية.'),
      _Section('التواصل',
          isContact: true,
          intro:
              'شركة سيريني سيك السنغال (C3S)\n📍 كيلومتر 6.5 طريق روفيسك ياراخ، داكار، السنغال\n📧 contactyma@c3s.sn',
          email: true),
      _Section('القبول',
          isAcceptance: true,
          intro: 'باستخدام التطبيق، فإنك توافق على سياسة الخصوصية هذه.'),
    ],
  };

  // ── Labels de l'interface selon la langue ──
  String get _pageTitle => switch (_lang) {
        'ar' => 'سياسة الخصوصية',
        'en' => 'Privacy Policy',
        _ => 'Politique de Confidentialité',
      };

  bool get _isRtl => _lang == 'ar';

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: _isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: _cream,
        body: CustomScrollView(
          slivers: [
            // ── App Bar ──────────────────────────────────
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              backgroundColor: _greenDeep,
              iconTheme: const IconThemeData(color: _goldLight),
              flexibleSpace: FlexibleSpaceBar(
                background: _buildHeader(),
                collapseMode: CollapseMode.pin,
              ),
              title: Text(
                _pageTitle,
                style: const TextStyle(
                  color: _goldLight,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // ── Language Switcher ─────────────────────────
            SliverToBoxAdapter(child: _buildLangBar()),

            // ── Sections ─────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
              sliver: FadeTransition(
                opacity: _fadeAnim,
                child: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => _SectionCard(
                      section: _sections[i],
                      index: i + 1,
                      isRtl: _isRtl,
                      lang: _lang,
                    ),
                    childCount: _sections.length,
                  ),
                ),
              ),
            ),

            // ── Footer ───────────────────────────────────
            SliverToBoxAdapter(child: _buildFooter()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_greenDeep, _greenMid, Color(0xFF1E8449)],
        ),
      ),
      child: Column(
        children: [
          // gold top band
          Container(
            height: 5,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_gold, _goldLight, _gold],
              ),
            ),
          ),
          const Spacer(),
          // medallion
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [_goldLight, _gold],
                center: Alignment(-0.3, -0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: _gold.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Center(
              child: Text('📖', style: TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'C3S — YAATAL MBINDUM AL XURANE',
            style: TextStyle(
              color: _gold.withOpacity(.8),
              fontSize: 10,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'مسابقة كتابة القرآن الكريم',
            style: TextStyle(
              fontFamily: 'Amiri',
              color: _goldLight,
              fontSize: 14,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildLangBar() {
    return Container(
      color: _greenDeep,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LangButton(
                  label: '🇫🇷 Français',
                  active: _lang == 'fr',
                  onTap: () => _switchLang('fr')),
              const SizedBox(width: 6),
              _LangButton(
                  label: '🇸🇳 العربية',
                  active: _lang == 'ar',
                  onTap: () => _switchLang('ar')),
              const SizedBox(width: 6),
              _LangButton(
                  label: '🇬🇧 English',
                  active: _lang == 'en',
                  onTap: () => _switchLang('en')),
            ],
          ).paddingSymmetric(vertical: 10, horizontal: 12),
          Container(height: 2, color: _gold),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      color: _greenDeep,
      child: Column(
        children: [
          Container(
            height: 3,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [_gold, _goldLight, _gold]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'C3S — Compagnie Serigne Secke Sénégal\nyaatalmbindumalxuran.sn | contactyma@c3s.sn',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(.5),
                fontSize: 12,
                height: 1.7,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────
// Section card widget
// ──────────────────────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.section,
    required this.index,
    required this.isRtl,
    required this.lang,
  });

  final _Section section;
  final int index;
  final bool isRtl;
  final String lang;

  static const Color _greenDeep = Color(0xFF0A3D1F);
  static const Color _greenMid = Color(0xFF145A32);
  static const Color _gold = Color(0xFFC9A84C);
  static const Color _goldLight = Color(0xFFF0D080);
  static const Color _goldPale = Color(0xFFFDF4DC);
  static const Color _textMid = Color(0xFF3D3D3D);

  @override
  Widget build(BuildContext context) {
    if (section.isContact) return _buildContactCard();
    if (section.isAcceptance) return _buildAcceptanceCard();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: isRtl
              ? BorderSide.none
              : const BorderSide(color: _gold, width: 4),
          right: isRtl
              ? const BorderSide(color: _gold, width: 4)
              : BorderSide.none,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0A3D1F).withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // number badge
            Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [_greenMid, Color(0xFF1E8449)],
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                _toLocalNumber(index),
                style: const TextStyle(
                  color: _goldLight,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // title
            Text(
              section.title,
              style: TextStyle(
                fontSize: lang == 'ar' ? 18 : 15,
                fontWeight: FontWeight.w700,
                color: _greenDeep,
                fontFamily: lang == 'ar' ? 'Amiri' : null,
              ),
            ),
            const Divider(color: Color(0x40C9A84C), height: 20),

            // intro text
            if (section.intro != null)
              Text(
                section.intro!,
                style: TextStyle(
                  color: _textMid,
                  fontSize: lang == 'ar' ? 16 : 14,
                  height: lang == 'ar' ? 2.0 : 1.7,
                  fontFamily: lang == 'ar' ? 'Amiri' : null,
                ),
              ),

            // bullet items
            if (section.items != null) ...[
              const SizedBox(height: 8),
              ...section.items!.map((item) => _BulletItem(
                    text: item,
                    isRtl: isRtl,
                    lang: lang,
                  )),
            ],

            // highlight box
            if (section.highlight != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _greenMid.withOpacity(.07),
                      _gold.withOpacity(.09),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _gold.withOpacity(.25)),
                ),
                child: section.email == true
                    ? _EmailHighlight(
                        text: section.highlight!, isRtl: isRtl, lang: lang)
                    : Text(
                        section.highlight!,
                        style: TextStyle(
                          color: _greenDeep,
                          fontWeight: FontWeight.w600,
                          fontSize: lang == 'ar' ? 15 : 13,
                          fontFamily: lang == 'ar' ? 'Amiri' : null,
                          height: 1.5,
                        ),
                        textAlign: isRtl ? TextAlign.right : TextAlign.left,
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_greenDeep, Color(0xFF145A32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _greenDeep.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              section.title,
              style: TextStyle(
                color: _goldLight,
                fontSize: lang == 'ar' ? 20 : 16,
                fontWeight: FontWeight.w700,
                fontFamily: lang == 'ar' ? 'Amiri' : null,
              ),
            ),
            const SizedBox(height: 12),
            const Divider(color: Color(0x40F0D080)),
            const SizedBox(height: 12),
            Text(
              section.intro ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(.85),
                height: 1.8,
                fontSize: lang == 'ar' ? 16 : 14,
                fontFamily: lang == 'ar' ? 'Amiri' : null,
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => launchUrl(Uri.parse('mailto:contactyma@c3s.sn')),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: _gold.withOpacity(.15),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: _gold.withOpacity(.4)),
                ),
                child: const Text(
                  '✉️  contactyma@c3s.sn',
                  style: TextStyle(
                    color: _goldLight,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAcceptanceCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _goldPale,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _gold.withOpacity(.3)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: _gold,
            ),
            alignment: Alignment.center,
            child: const Text('✓',
                style: TextStyle(
                    color: _greenDeep,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),
          Text(
            section.title,
            style: TextStyle(
              color: _greenDeep,
              fontSize: lang == 'ar' ? 18 : 15,
              fontWeight: FontWeight.w700,
              fontFamily: lang == 'ar' ? 'Amiri' : null,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            section.intro ?? '',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF3D3D3D),
              fontSize: lang == 'ar' ? 16 : 14,
              height: 1.6,
              fontFamily: lang == 'ar' ? 'Amiri' : null,
            ),
          ),
        ],
      ),
    );
  }

  String _toLocalNumber(int n) {
    if (lang != 'ar') return '$n';
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return n.toString().split('').map((c) {
      final d = int.tryParse(c);
      return d != null ? arabic[d] : c;
    }).join();
  }
}

// ──────────────────────────────────────────────────────────────────────────
// Bullet item
// ──────────────────────────────────────────────────────────────────────────
class _BulletItem extends StatelessWidget {
  const _BulletItem(
      {required this.text, required this.isRtl, required this.lang});
  final String text;
  final bool isRtl;
  final String lang;

  static const Color _gold = Color(0xFFC9A84C);
  static const Color _textMid = Color(0xFF3D3D3D);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: isRtl
            ? [
                Expanded(
                  child: Text(text,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        color: _textMid,
                        fontSize: 16,
                        height: 1.8,
                        fontFamily: 'Amiri',
                      )),
                ),
                const SizedBox(width: 8),
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text('◆', style: TextStyle(color: _gold, fontSize: 8)),
                ),
              ]
            : [
                const Padding(
                  padding: EdgeInsets.only(top: 8, right: 8),
                  child: Text('◆', style: TextStyle(color: _gold, fontSize: 8)),
                ),
                Expanded(
                  child: Text(text,
                      style: TextStyle(
                        color: _textMid,
                        fontSize: lang == 'ar' ? 16 : 14,
                        height: 1.7,
                      )),
                ),
              ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────
// Email highlight (tappable)
// ──────────────────────────────────────────────────────────────────────────
class _EmailHighlight extends StatelessWidget {
  const _EmailHighlight(
      {required this.text, required this.isRtl, required this.lang});
  final String text;
  final bool isRtl;
  final String lang;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => launchUrl(Uri.parse('mailto:contactyma@c3s.sn')),
      child: Text(
        text,
        textAlign: isRtl ? TextAlign.right : TextAlign.left,
        style: TextStyle(
          color: const Color(0xFF145A32),
          fontWeight: FontWeight.w700,
          fontSize: lang == 'ar' ? 15 : 13,
          fontFamily: lang == 'ar' ? 'Amiri' : null,
          decoration: TextDecoration.underline,
          decorationColor: const Color(0xFFC9A84C),
          height: 1.5,
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────
// Language button
// ──────────────────────────────────────────────────────────────────────────
class _LangButton extends StatelessWidget {
  const _LangButton({
    required this.label,
    required this.active,
    required this.onTap,
  });
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFC9A84C) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                active ? const Color(0xFFC9A84C) : Colors.white.withOpacity(.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active
                ? const Color(0xFF0A3D1F)
                : Colors.white.withOpacity(.65),
            fontWeight: active ? FontWeight.w700 : FontWeight.w400,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────
// Data model
// ──────────────────────────────────────────────────────────────────────────
class _Section {
  const _Section(
    this.title, {
    this.intro,
    this.items,
    this.highlight,
    this.email = false,
    this.isContact = false,
    this.isAcceptance = false,
  });

  final String title;
  final String? intro;
  final List<String>? items;
  final String? highlight;
  final bool email;
  final bool isContact;
  final bool isAcceptance;
}

// ──────────────────────────────────────────────────────────────────────────
// Helper extension (évite d'importer un package externe)
// ──────────────────────────────────────────────────────────────────────────
extension on Widget {
  Widget paddingSymmetric({double vertical = 0, double horizontal = 0}) =>
      Padding(
        padding:
            EdgeInsets.symmetric(vertical: vertical, horizontal: horizontal),
        child: this,
      );
}


/// ──────────────────────────────────────────────────────────────────────────
///  USAGE depuis la page Contact
///  Copiez ce snippet dans votre contact.dart :
///
///  GestureDetector(
///    onTap: () => Navigator.push(
///      context,
///      MaterialPageRoute(builder: (_) => const PrivacyScreen()),
///    ),
///    child: Text(
///      '📄 Politique de confidentialité',
///      style: TextStyle(
///        color: Colors.blue,
///        decoration: TextDecoration.underline,
///      ),
///    ),
///  ),
/// ──────────────────────────────────────────────────────────────────────────