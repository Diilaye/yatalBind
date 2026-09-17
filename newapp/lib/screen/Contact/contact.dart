import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yaatal_mbindum/bloc/controllers/language_controller.dart';

const String BASE_URL = 'https://api.yaatalmbindumalxuran.sn/api/v1/';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen>
    with TickerProviderStateMixin {
  final LanguageController langController = Get.find<LanguageController>();
  final _formKey = GlobalKey<FormState>();
  bool _isSending = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Directionality(
          textDirection: langController.isRTL.value
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: Scaffold(
            body: Stack(
              children: [
                // ── Fond d'écran ──
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
                          yDarkColor.withOpacity(0.78),
                          yDarkColor.withOpacity(0.96),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Contenu ──
                SafeArea(
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),

                            // Header
                            _buildHeader(),
                            const SizedBox(height: 28),

                            // Infos de contact rapides
                            _buildContactInfoCards(),
                            const SizedBox(height: 28),

                            // Formulaire
                            _buildSectionLabel(
                                Icons.edit_outlined, 'Envoyer un message'),
                            const SizedBox(height: 14),
                            _buildForm(),
                            const SizedBox(height: 28),

                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  // ── Header ──
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _circleBtn(
              icon: langController.isRTL.value
                  ? Icons.arrow_forward_rounded
                  : Icons.arrow_back_rounded,
              onTap: () => Navigator.pop(context),
            ),
            _circleBtn(icon: Icons.share_outlined, onTap: () {}),
          ],
        ),
        const SizedBox(height: 20),
        const Text(
          'Contactez-nous',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: yWhiteColor,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Groupe Yaatal Mbinde — Dakar, Sénégal',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            color: yWhiteColor.withOpacity(0.55),
          ),
        ),
      ],
    );
  }

  // ── Infos contact rapides ──
  Widget _buildContactInfoCards() {
    final infos = [
      _ContactInfo(
          icon: Icons.location_on_rounded,
          label: 'Adresse',
          value: 'KM 6.5 Route de Rufisque, Sénégal'),
      _ContactInfo(
          icon: Icons.phone_rounded,
          label: 'Téléphone',
          value: '+221 76 751 43 42'),
      _ContactInfo(
          icon: Icons.email_rounded,
          label: 'Email',
          value: 'concoursc3syma@c3s.sn'),
    ];

    return Row(
      children: infos.map((info) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: info == infos.last ? 0 : 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: yWhiteColor.withOpacity(0.07),
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: yWhiteColor.withOpacity(0.12), width: 1),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [yAccentColor, ySecondaryColor]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(info.icon, color: yWhiteColor, size: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  info.label,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: yWhiteColor.withOpacity(0.5),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Text(
                  info.value,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: yWhiteColor,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Label de section ──
  Widget _buildSectionLabel(IconData icon, String title) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 22,
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
        Icon(icon, color: yGoldColor, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: yWhiteColor,
          ),
        ),
      ],
    );
  }

  // ── Formulaire ──
  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: yWhiteColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: yWhiteColor.withOpacity(0.12), width: 1),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                    child: _buildField(
                        _nameController, 'Nom', Icons.person_outline_rounded)),
                const SizedBox(width: 12),
                Expanded(
                    child: _buildField(_surnameController, 'Prénom',
                        Icons.person_outline_rounded)),
              ],
            ),
            const SizedBox(height: 14),
            _buildField(_emailController, 'Email', Icons.email_outlined,
                isEmail: true, keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 14),
            _buildField(_phoneController, 'Téléphone', Icons.phone_outlined,
                keyboardType: TextInputType.phone),
            const SizedBox(height: 14),
            _buildField(_messageController, 'Message', Icons.message_outlined,
                maxLines: 5),
            const SizedBox(height: 20),

            // Bouton envoyer
            SizedBox(
              width: double.infinity,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [yGoldColor, yGoldLight, yGoldColor],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: yGoldShadow,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: _isSending ? null : _submitForm,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_isSending)
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: yDarkColor,
                              ),
                            )
                          else
                            const Icon(Icons.send_rounded,
                                color: yDarkColor, size: 18),
                          const SizedBox(width: 10),
                          Text(
                            _isSending ? 'Envoi...' : 'Envoyer le message',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: yDarkColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget for building a form field with a given controller, label, icon, and optional isEmail, maxLines, and keyboardType parameters.
  ///
  /// The widget is a TextFormField with a given controller, maxLines, and keyboardType.
  /// The decoration is a InputDecoration with a given label, prefixIcon, filled, fillColor, contentPadding, enabledBorder, focusedBorder, errorBorder, and focusedErrorBorder.
  /// The validator is a function that checks if the value is null or empty, and if it is an invalid email if isEmail is true.
  Widget _buildField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isEmail = false,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 14,
        color: yWhiteColor,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13,
          color: yWhiteColor.withOpacity(0.5),
        ),
        prefixIcon: Icon(icon, color: yGoldColor, size: 18),
        filled: true,
        fillColor: yWhiteColor.withOpacity(0.06),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              BorderSide(color: yWhiteColor.withOpacity(0.15), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: yGoldColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: yErrorColor, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: yErrorColor, width: 1.5),
        ),
        errorStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 11,
          color: yErrorColor,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Champ requis';
        if (isEmail && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
          return 'Email invalide';
        }
        return null;
      },
    );
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSending = true);

    try {
      final result = await postResponse(url: 'sendContact', body: {
        'message': _messageController.text,
        'email': _emailController.text,
      });

      _showSnack(
        result['status'] == 200
            ? 'Message envoyé avec succès !'
            : 'Erreur lors de l\'envoi',
        result['status'] == 200,
      );
    } catch (_) {
      _showSnack('Erreur de connexion', false);
    } finally {
      setState(() => _isSending = false);
    }
  }

  void _showSnack(String msg, bool success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              success ? Icons.check_circle_rounded : Icons.error_rounded,
              color: yWhiteColor,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                msg,
                style:
                    const TextStyle(fontFamily: 'Poppins', color: yWhiteColor),
              ),
            ),
          ],
        ),
        backgroundColor: success ? yAccentColor : yErrorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
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
          color: yWhiteColor.withOpacity(0.10),
          shape: BoxShape.circle,
          border: Border.all(color: yWhiteColor.withOpacity(0.20), width: 1),
        ),
        child: Icon(icon, color: yWhiteColor, size: 20),
      ),
    );
  }
}

// ── Modèle info contact ──
class _ContactInfo {
  final IconData icon;
  final String label;
  final String value;
  const _ContactInfo(
      {required this.icon, required this.label, required this.value});
}

// ── HTTP helpers ──
Future getResponse({required String url}) async {
  final uri = Uri.parse(BASE_URL + url);
  return http.get(uri, headers: {'Content-Type': 'application/json'}).then(
      (r) => {'body': 'success', 'status': r.statusCode});
}

Future postResponse(
    {required String url, required Map<String, dynamic> body}) async {
  final uri = Uri.parse(BASE_URL + url);
  return http.post(uri, body: json.encode(body), headers: {
    'Content-Type': 'application/json'
  }).then((r) => {'body': 'success', 'status': r.statusCode});
}
