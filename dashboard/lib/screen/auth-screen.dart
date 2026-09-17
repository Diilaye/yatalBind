// lib/screen/auth/auth_screen.dart
//
// DIFF vs votre fichier original :
//   [1] _handleLogin() — plus d'appel direct à AuthService ni de Navigator.pushReplacementNamed
//       Délégué entièrement à context.read<AuthBloc>().login(context)
//       qui appelle loginSuccess() → notifyListeners() → router redirige
//   [2] Les controllers locaux (_emailController, _passwordController) sont
//       SUPPRIMÉS — AuthBloc expose déjà emailController / passwordController
//   [3] _isLoading, _showPassword, _errorMessage sont lus depuis le bloc (watch)
//   [4] Le design est IDENTIQUE à votre original (même structure, mêmes widgets)

import 'package:dashboard/bloc/auth-bloc.dart';
import 'package:dashboard/utils/coolors-by-dii.dart';
import 'package:dashboard/utils/font-familly-dii.dart';
import 'package:dashboard/utils/padding-global.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    // Les controllers appartiennent au bloc, pas à ce widget
    super.dispose();
  }

  // [FIX] Délégué au bloc — plus de AuthService direct ni de Navigator
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    await context.read<AuthBloc>().login(context);
    // Le router redirige automatiquement vers /admin via refreshListenable
  }

  void _togglePasswordVisibility() {
    context.read<AuthBloc>().setShowPassword();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(toolbarHeight: 0, elevation: 0),
      body: Container(
        height: size.height,
        width: size.width,
        color: bgAdmin,
        child: ListView(
          children: [
            _buildHeader(size),
            paddingVerticalGlobal(24),
            Center(child: _buildLoginForm(size)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Size size) {
    return Container(
      height: 60,
      width: size.width,
      color: blanc,
      child: Row(
        children: [
          paddingHorizontalGlobal(size.width * .1),
          SizedBox(
            width: 200,
            child: Image.asset("assets/images/LOGO_YAATAL.png",
                fit: BoxFit.contain),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm(Size size) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      width: size.width > 600 ? 400 : size.width * 0.9,
      decoration: BoxDecoration(
        color: blanc,
        border: Border(top: BorderSide(color: noir.withOpacity(.5), width: 2)),
        boxShadow: [
          BoxShadow(
              color: noir.withOpacity(.3),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: Form(
        key: _formKey,
        child: Consumer<AuthBloc>(
          builder: (context, bloc, _) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              paddingVerticalGlobal(32),
              _buildTitle(),
              paddingVerticalGlobal(15),
              Container(height: 1, color: noir.withOpacity(.2)),
              paddingVerticalGlobal(24),
              if (bloc.errorMessage != null)
                _buildErrorMessage(bloc.errorMessage!),
              _buildEmailField(size, bloc),
              paddingVerticalGlobal(24),
              _buildPasswordField(size, bloc),
              paddingVerticalGlobal(16),
              _buildShowPasswordCheckbox(bloc),
              paddingVerticalGlobal(32),
              _buildLoginButton(size, bloc),
              paddingVerticalGlobal(24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.lock_outline, color: vert, size: 24),
        paddingHorizontalGlobal(8),
        Text(
          'Connectez-vous',
          style: fontFammilyDii(
              context, 18, vert, FontWeight.bold, FontStyle.normal),
        ),
      ],
    );
  }

  Widget _buildErrorMessage(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.shade300),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
            paddingHorizontalGlobal(8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailField(Size size, AuthBloc bloc) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Email',
                  style: fontFammilyDii(
                      context, 14, noir, FontWeight.bold, FontStyle.normal)),
              const Text(' *',
                  style: TextStyle(color: Colors.red, fontSize: 14)),
            ],
          ),
          paddingVerticalGlobal(8),
          TextFormField(
            controller: bloc.emailController, // contrôleur du bloc
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            enabled: !bloc.isLoading,
            validator: (_) => bloc.validateEmail(),
            decoration: InputDecoration(
              hintText: "exemple@yaatal.sn",
              hintStyle: TextStyle(color: noir.withOpacity(.4)),
              prefixIcon: Icon(Icons.email_outlined, color: vert),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: noir.withOpacity(.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: vert, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              filled: true,
              fillColor: bloc.isLoading ? gris.withOpacity(.3) : blanc,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(Size size, AuthBloc bloc) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Mot de passe',
                  style: fontFammilyDii(
                      context, 14, noir, FontWeight.bold, FontStyle.normal)),
              const Text(' *',
                  style: TextStyle(color: Colors.red, fontSize: 14)),
              paddingHorizontalGlobal(8),
              Text(
                "(6 caractères minimum)",
                style: fontFammilyDii(context, 11, noir.withOpacity(.6),
                    FontWeight.w300, FontStyle.normal),
              ),
            ],
          ),
          paddingVerticalGlobal(8),
          TextFormField(
            controller: bloc.passwordController, // contrôleur du bloc
            obscureText: !bloc.showPassword,
            textInputAction: TextInputAction.done,
            enabled: !bloc.isLoading,
            validator: (_) => bloc.validatePassword(),
            onFieldSubmitted: (_) => _handleLogin(),
            decoration: InputDecoration(
              hintText: "Mot de passe",
              hintStyle: TextStyle(color: noir.withOpacity(.4)),
              prefixIcon: Icon(Icons.lock_outline, color: vert),
              suffixIcon: IconButton(
                icon: Icon(
                  bloc.showPassword ? Icons.visibility : Icons.visibility_off,
                  color: noir.withOpacity(.6),
                ),
                onPressed: _togglePasswordVisibility,
                tooltip: bloc.showPassword ? 'Masquer' : 'Afficher',
              ),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: noir.withOpacity(.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: vert, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              filled: true,
              fillColor: bloc.isLoading ? gris.withOpacity(.3) : blanc,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShowPasswordCheckbox(AuthBloc bloc) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: bloc.isLoading ? null : _togglePasswordVisibility,
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: bloc.showPassword ? vert : noir.withOpacity(.4),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(4),
                  color: bloc.showPassword ? vert : Colors.transparent,
                ),
                child: bloc.showPassword
                    ? Icon(Icons.check, color: blanc, size: 14)
                    : null,
              ),
              paddingHorizontalGlobal(8),
              Expanded(
                child: Text(
                  'Afficher le mot de passe',
                  style: fontFammilyDii(
                    context,
                    13,
                    noir.withOpacity(bloc.isLoading ? .4 : .7),
                    FontWeight.w400,
                    FontStyle.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(Size size, AuthBloc bloc) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: MouseRegion(
        cursor:
            bloc.isLoading ? SystemMouseCursors.wait : SystemMouseCursors.click,
        child: GestureDetector(
          onTap: bloc.isLoading ? null : _handleLogin,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 50,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: bloc.isLoading ? vert.withOpacity(.7) : vert,
              boxShadow: bloc.isLoading
                  ? []
                  : [
                      BoxShadow(
                          color: vert.withOpacity(.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4))
                    ],
            ),
            child: Center(
              child: bloc.isLoading
                  ? SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(blanc)),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.login, color: blanc, size: 20),
                        paddingHorizontalGlobal(8),
                        Text(
                          "Se connecter",
                          style: fontFammilyDii(context, 15, blanc,
                              FontWeight.w600, FontStyle.normal),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
