import 'dart:io';
import 'package:app/utils/colors.dart';
import 'package:app/utils/images_string.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class ParticipateScreen extends StatefulWidget {
  @override
  _ParticipateScreenState createState() => _ParticipateScreenState();
}

class _ParticipateScreenState extends State<ParticipateScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  // Controllers
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _birthDateController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _schoolController = TextEditingController();
  TextEditingController _professorController = TextEditingController();

  // Variables pour la localisation et le fichier image
  LatLng? _currentPosition;
  File? _extraitFile;

  // Méthode pour choisir une image depuis la galerie
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      if (await file.length() > 1 * 1024 * 1024) {
        // Vérifie que le fichier ne dépasse pas 1 Mo
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Le fichier ne doit pas dépasser 1 Mo.')),
        );
      } else {
        setState(() {
          _extraitFile = file;
        });
      }
    }
  }

  // Méthode pour valider le numéro de téléphone
  bool _validatePhone(String phone) {
    final phoneRegex = RegExp(r'^(77|78|75|76|70)\d{7}$');
    return phoneRegex.hasMatch(phone);
  }

  // Méthode pour valider l'âge (doit être inférieur à 34 ans)
  bool _validateAge(DateTime birthDate) {
    final age = DateTime.now().year - birthDate.year;
    return age <= 34;
  }

  // Méthode pour ouvrir le sélecteur de date
  Future<void> _selectBirthDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && _validateAge(pickedDate)) {
      _birthDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('L\'âge ne doit pas dépasser 34 ans.')),
      );
    }
  }

  // Méthode pour soumettre le formulaire
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Formulaire soumis avec succès !')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: yWhiteColor,
      appBar: AppBar(
        title: Text('Formulaire d\'inscription'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(
                width: 180,
                  child: Image.asset(ySplashImage)
              ),
              Text("Vous pouvez déposer votre candidature ici"),

              _buildTextField(_firstNameController, 'Prénom', const Icon(Icons.account_circle)),
              SizedBox(height: 15),
              _buildTextField(_lastNameController, 'Nom', const Icon(Icons.account_circle)),
              SizedBox(height: 15),
              _buildTextField(_phoneController, 'Téléphone', isPhone: true, const Icon(Icons.phone_android_outlined)),
              SizedBox(height: 15),
              GestureDetector(
                onTap: () => _selectBirthDate(context),
                child: AbsorbPointer(
                  child: _buildTextField(
                    _birthDateController,
                    'Date de Naissance',
                      const Icon(Icons.edit_calendar_outlined)
                  ),
                ),
              ),
              SizedBox(height: 15),
              _buildTextField(_addressController, 'Adresse Exacte', const Icon(Icons.maps_home_work)),
              SizedBox(height: 15),
              _buildTextField(_schoolController, 'École', const Icon(Icons.school_rounded)),
              SizedBox(height: 15),
              _buildTextField(_professorController, 'Professeur', const Icon(Icons.school_sharp)),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: Icon(Icons.upload_file),
                label: Text('Ajouter Extrait'),
              ),
              if (_extraitFile != null) Text('Fichier sélectionné.'),
              SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submitForm,
                  icon: Icon(Icons.book),
                  label: Text('Valider'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              _buildGoogleMap(),
            ],
          ),
        ),
      ),
    );
  }

  // Champ de texte réutilisable
  Widget _buildTextField(
      TextEditingController controller,
      String label, Icon icon,{
        bool isPhone = false,
      }) {
    return TextFormField(
      controller: controller,
      keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
      decoration: InputDecoration(
        prefixIcon: icon,
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
        filled: true,
        fillColor: Colors.grey[200],
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez entrer $label.';
        }
        if (isPhone && !_validatePhone(value)) {
          return 'Numéro de téléphone invalide.';
        }
        return null;
      },
    );
  }

  // Widget Google Map
  Widget _buildGoogleMap() {
    return Container(
      height: 300,
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(14.6928, -17.4467), // Exemple : Dakar, Sénégal
          zoom: 12,
        ),
        markers: _currentPosition != null
            ? {
          Marker(
            markerId: MarkerId('currentLocation'),
            position: _currentPosition!,
          )
        }
            : {},
      ),
    );
  }
}
