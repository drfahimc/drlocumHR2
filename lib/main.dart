import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'screens/doctor_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with error handling
  try {
    if (kIsWeb) {
      // For web, ensure we're using the correct platform
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.web,
      );
      debugPrint('✅ Firebase initialized successfully for WEB');
    } else {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint('✅ Firebase initialized successfully for ${defaultTargetPlatform.toString()}');
    }
    
    // Test Firebase connection
    final firestore = FirebaseFirestore.instance;
    debugPrint('✅ Firestore instance created');
    
    // Try a simple test query to verify connection
    try {
      final testSnapshot = await firestore.collection('jobs').limit(1).get();
      debugPrint('✅ Firebase connection test: Found ${testSnapshot.docs.length} jobs');
    } catch (e) {
      debugPrint('⚠️ Firebase connection test failed: $e');
      debugPrint('⚠️ This might be due to:');
      debugPrint('   1. No data in Firestore yet');
      debugPrint('   2. Firestore security rules blocking access');
      debugPrint('   3. Network connectivity issues');
    }
  } catch (e, stackTrace) {
    // Log error but don't crash the app
    debugPrint('❌ Firebase initialization error: $e');
    debugPrint('Stack trace: $stackTrace');
    // For web, this might be a configuration issue
    if (kIsWeb) {
      debugPrint('⚠️ Make sure Firebase is properly configured for web in Firebase Console');
      debugPrint('⚠️ Check that your firebase_options.dart has correct web configuration');
    }
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DrLocumDr - Doctor App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const DoctorDashboard(),
    );
  }
}
