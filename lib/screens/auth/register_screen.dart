import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../user/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = "";
  final _addressController = "";
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Crear Cuenta", style: TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text("Únete a LibroApp hoy mismo", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),
            _buildTextField(_nameController, "Nombre completo"),
            const SizedBox(height: 16),
            _buildTextField(_emailController, "Correo electrónico", keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 16),
            _buildTextField(_passwordController, "Contraseña", obscureText: true),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEAB308)),
                onPressed: () async {
                  bool success = await authProvider.signUp(
                    _emailController.text, _passwordController.text,
                    _nameController.text, _phoneController, _addressController
                  );
                  if (success) {
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomeScreen()), (route) => false);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al registrarse')));
                  }
                },
                child: const Text("REGISTRARSE", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {bool obscureText = false, TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}