import 'package:checkpoint/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app/app.dart';
import 'app/router.dart';

/// Punto de entrada de la app.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Cargar variables de entorno desde .env
  await dotenv.load(fileName: ".env");
  
  // Inicializar Firebase
  await Firebase.initializeApp( 
    options: DefaultFirebaseOptions.currentPlatform,
  ); 
  
  // Verificar si hay sesión activa, dependiendo de esto definir la ruta inicial
  String initialRoute;
  if (FirebaseAuth.instance.currentUser != null) {
    initialRoute = AppRouter.home;
  } else {
    initialRoute = AppRouter.welcome;
  }
  
  runApp(App(initialRoute: initialRoute));
}
