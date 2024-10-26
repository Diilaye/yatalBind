import 'package:app/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ContactScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs de texte pour récupérer les valeurs du formulaire
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  // Coordonnées des adresses du groupe Yaatal Mbinde
  final List<LatLng> addresses = [
    LatLng(14.7229682,-17.4356641), // Dakar
    LatLng(14.7537825,-17.4355525),     // Example: Another location in Dakar
    LatLng(14.7796272,-17.3158438),     // Example: Another location in Dakar
    LatLng(14.7613031,-17.3018858),     // Example: Another location in Dakar
    LatLng(14.7417649,-17.2884158),     // Example: Another location in Dakar
    LatLng(14.7811631,-16.9534776),     // Example: Another location in Dakar
    LatLng(14.6110375,-17.3568222),     // Example: Another location in Dakar
    LatLng(14.4717772,-17.0466523),     // Example: Another location in Dakar
    LatLng(14.1420969,-16.0830768),     // Example: Another location in Dakar
    LatLng(14.8466172,-15.8840429),     // Example: Another location in Dakar
    LatLng(14.8575909,-15.8952873),     // Example: Another location in Dakar
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Contactez-nous',
          style: TextStyle(
              color: yWhiteColor,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600
          ),
        ),
        backgroundColor: yAccentColor,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Formulaire de contact
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField(_nameController, 'Nom'),
                  SizedBox(height: 10),
                  _buildTextField(_surnameController, 'Prénom'),
                  SizedBox(height: 10),
                  _buildTextField(_emailController, 'Email', isEmail: true),
                  SizedBox(height: 10),
                  _buildTextField(_phoneController, 'Téléphone'),
                  SizedBox(height: 10),
                  _buildTextField(
                    _messageController,
                    'Message',
                    maxLines: 5,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Traitement du formulaire, ex: envoi vers une API
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Message envoyé avec succès!')),
                        );
                      }
                    },
                    child: Text('Envoyer', style: TextStyle(fontFamily: 'Poppins', color: yWhiteColor),),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: yAccentColor,
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      textStyle: TextStyle(fontSize: 18,),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),

            // Informations du groupe Yaatal Mbinde
            Text(
              'Informations du groupe Yaatal Mbinde',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            _buildContactInfoRow(Icons.location_on, 'Adresse: Dakar, Sénégal'),
            _buildContactInfoRow(Icons.phone, 'Téléphone: +221 33 123 45 67'),
            _buildContactInfoRow(Icons.email, 'Email: contact@yaatal.com'),
            SizedBox(height: 30),

            // Intégration de Google Maps avec un marqueur
            Text(
              'Nos Localisations',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Container(
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: GoogleMap(
                mapType: MapType.hybrid,
                initialCameraPosition: CameraPosition(
                  target: addresses[0], // Centre sur la première adresse
                  zoom: 5,
                ),
                markers: addresses
                    .map((location) => Marker(
                  markerId: MarkerId(location.toString()),
                  position: location,
                ))
                    .toSet(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fonction pour créer un champ de texte avec validation
  Widget _buildTextField(
      TextEditingController controller,
      String label, {
        bool isEmail = false,
        int maxLines = 1,
      }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez entrer $label';
        }
        if (isEmail && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
          return 'Veuillez entrer un email valide';
        }
        return null;
      },
    );
  }

  // Fonction pour afficher une ligne d'information avec une icône
  Widget _buildContactInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
