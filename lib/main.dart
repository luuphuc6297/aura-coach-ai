import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'shared/painters/icon_registry.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initIconRegistry();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: '.env');
  final prefs = await SharedPreferences.getInstance();
  runApp(AuraCoachApp(prefs: prefs));
}
