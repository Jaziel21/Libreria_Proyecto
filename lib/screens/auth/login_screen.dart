import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../admin/admin_dashboard_screen.dart';
import '../user/home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Redirección automática si la sesión está activa
    if (!authProvider.isLoading && authProvider.firebaseUser != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (authProvider.isAdmin) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminDashboardScreen()));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        }
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Fondo oscuro de tu diseño admin
      body: Center(
        child: authProvider.isLoading 
          ? const CircularProgressIndicator(color: Colors.white)
          : SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.menu_book, size: 80, color: Color(0xFFEAB308)), // Icono de libro amarillo
                  const SizedBox(height: 16),
                  const Text("LibroApp", style: TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text("Inicia sesión para continuar", style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "Correo electrónico",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "Contraseña",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEAB308), // Botón amarillo
                      ),
                      onPressed: () async {
                        bool success = await authProvider.signIn(
                          _emailController.text, 
                          _passwordController.text
                        );
                        if (!success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Error al iniciar sesión'))
                          );
                        }
                      },
                      child: const Text("INICIAR SESIÓN", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  // ... [Código previo del botón de inicio de sesión]
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("¿No tienes cuenta? ", style: TextStyle(color: Colors.grey)),
                      TextButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
                        },
                        child: const Text("Regístrate", style: TextStyle(color: Color(0xFFEAB308), fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
      ),
    );
  }
}