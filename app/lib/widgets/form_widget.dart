import 'package:flutter/material.dart';
import 'package:app/utils/colors.dart' as color;
class FormWidget extends StatefulWidget {
  const FormWidget({super.key});

  @override
  State<FormWidget> createState() => _FormWidgetState();
}

class _FormWidgetState extends State<FormWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Text(
              "Déposer votre candidature /أرسل طلبك هنا",
              style: TextStyle(
                fontSize: 16, 
                fontWeight: FontWeight.bold,
                color: color.AppColor.yDarkColor,
                ),
              ),
              SizedBox(height: 20,),
              _buildTextField("Prenom/الاسم الأول", Icons.person),
              SizedBox(height: 20,),
              _buildTextField("Nom/الاسم الثاني", Icons.person),
              SizedBox(height: 20,),
              _buildTextField("Téléphone/رقم الهاتف", Icons.phone),
               SizedBox(height: 20,),
              _buildTextField("Téléphone/رقم الهاتف", Icons.phone),
              SizedBox(height: 20,),
              _buildTextField("Adresse/العنوان", Icons.location_on),
              SizedBox(height: 20,),
              _buildTextField("Date de naissance/تاريخ الميلاد", Icons.calendar_month),
              SizedBox(height: 20,),
              _buildTextField("Ecole/المدرسة", Icons.school_outlined),
              SizedBox(height: 20,),
              _buildTextField("Professeur/المعلم", Icons.person),
              SizedBox(height: 20,),
              

          ]
          ),
        ),
      ),
    );
  }
  Widget _buildTextField(String label, IconData icon, {int maxLines = 1}) {

    return TextField(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: color.AppColor.yAccentColor),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: color.AppColor.yDarkColor, 
            width: 2.0
          ), 
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: color.AppColor.yDarkColor, 
              width: 1.5
            ), 
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        filled: true,
        fillColor: Colors.grey[200],
      ),
      maxLines: maxLines,
    );
  }
}