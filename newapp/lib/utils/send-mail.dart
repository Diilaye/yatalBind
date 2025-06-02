import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

Future<void> sendEmail(String subject, String text, String mel) async {
  // Paramètres SMTP OVH
  String username = 'concoursc3syma@c3s.s'; // Ton adresse e-mail OVH
  String password = 'Yaatalmbinde2018'; // Ton mot de passe

  final smtpServer = SmtpServer(
    'ssl0.ovh.net', // Serveur sortant OVH
    port: 587, // Port recommandé
    username: username,
    password: password,
    ssl: false, // Désactive SSL (car OVH utilise STARTTLS sur 587)
    allowInsecure: true,
  );

  // Création du message
  final message = Message()
    ..from = Address(username, 'Yaatalmbinde')
    ..recipients.add(mel) // Remplace par l'adresse du destinataire
    ..subject = subject
    ..text = text;

  try {
    final sendReport = await send(message, smtpServer);
    print('✅ E-mail envoyé : ${sendReport.toString()}');
  } catch (e) {
    print('❌ Erreur lors de l\'envoi : $e');
  }
}
