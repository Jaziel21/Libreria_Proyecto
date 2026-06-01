import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/favorites_provider.dart';

// Screens
import 'screens/auth/intro_screen.dart';
import 'screens/user/home_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';

void main() async {
  // Asegura que los bindings de Flutter estén inicializados antes de llamar a código nativo (Firebase)
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializa Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const LibroApp());
}

class LibroApp extends StatelessWidget {
  const LibroApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
      ],
      child: MaterialApp(
        title: 'LibroApp',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFF0F172A),
          scaffoldBackgroundColor: Colors.grey[50], // Fondo claro para la app
          textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF0F172A),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: const Color(0xFF0F172A),
            secondary: const Color(0xFFEAB308), // Color de acento (amarillo)
          ),
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

/// Este widget escucha el estado de autenticación y decide a qué pantalla enviar al usuario.
/// Mantiene la sesión activa al hacer hot reload o cerrar la app.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Muestra un indicador de carga mientras Firebase verifica la sesión
    if (authProvider.isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F172A),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFEAB308)),
        ),
      );
    }

    // Si no hay usuario logueado, lo manda a la pantalla de Intro
    if (authProvider.firebaseUser == null) {
      return const IntroScreen();
    }

    // Si hay usuario, verifica si es Admin para mandarlo a su respectivo Dashboard
    if (authProvider.isAdmin) {
      return const AdminDashboardScreen();
    }

    // Si es un usuario normal, lo manda al Home
    return const HomeScreen();
  }
}