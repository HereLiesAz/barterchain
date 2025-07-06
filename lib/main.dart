// main.dart
import 'package:flutter/material.dart';
import 'package:barterchain/create_offer_page.dart';
import 'package:barterchain/browse_offers_page.dart';
import 'package:barterchain/my_barters_page.dart';
import 'package:barterchain/user_profile_page.dart';
import 'package:barterchain/settings_page.dart';
import 'package:barterchain/help_support_page.dart';
import 'package:barterchain/review_rating_page.dart';
import 'package:barterchain/markdown_viewer_page.dart';
import 'package:barterchain/block_blockchain.dart'; // Import our local blockchain classes
import 'package:barterchain/blockchain_service.dart'; // Import our new blockchain service

// Firebase imports
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert'; // Required for json.decode

// Global variables provided by the Canvas environment for Firebase configuration
// These are typically injected into the runtime environment.
// We provide default values for local development if they are not defined.
const String __app_id = String.fromEnvironment('APP_ID', defaultValue: 'default-app-id');
const String __firebase_config = String.fromEnvironment('FIREBASE_CONFIG', defaultValue: '{}');
const String __initial_auth_token = String.fromEnvironment('INITIAL_AUTH_TOKEN', defaultValue: '');

// Global instances for Firebase and Blockchain
late FirebaseFirestore db;
late FirebaseAuth auth;
late Blockchain localBlockchain;
late BlockchainService blockchainService;

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter binding is initialized

  // Parse firebaseConfig from the global variable
  final firebaseConfigMap = Map<String, dynamic>.from(
    (await Future.value(
      __firebase_config.isNotEmpty ? Map<String, dynamic>.from(
        (json.decode(__firebase_config) as Map<dynamic, dynamic>).cast<String, dynamic>()
      ) : {}
    ))
  );

  // Initialize Firebase App
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: firebaseConfigMap['apiKey'] ?? '',
      appId: firebaseConfigMap['appId'] ?? '',
      messagingSenderId: firebaseConfigMap['messagingSenderId'] ?? '',
      projectId: firebaseConfigMap['projectId'] ?? '',
      storageBucket: firebaseConfigMap['storageBucket'] ?? '',
    ),
  );

  // Initialize Firestore and Auth instances
  db = FirebaseFirestore.instance;
  auth = FirebaseAuth.instance;

  // Sign in with custom token if provided, otherwise anonymously
  if (__initial_auth_token.isNotEmpty) {
    try {
      await auth.signInWithCustomToken(__initial_auth_token);
      print("Signed in with custom token.");
    } catch (e) {
      print("Error signing in with custom token: $e");
      await auth.signInAnonymously();
      print("Signed in anonymously due to custom token error.");
    }
  } else {
    await auth.signInAnonymously();
    print("Signed in anonymously.");
  }

  // Initialize the local blockchain instance
  localBlockchain = Blockchain();
  // Initialize the blockchain service for syncing with Firestore
  blockchainService = BlockchainService(db, auth, localBlockchain, __app_id);

  runApp(const BarterchainApp());
}

class BarterchainApp extends StatelessWidget {
  const BarterchainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barterchain',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: Colors.white),
          displayMedium: TextStyle(color: Colors.white),
          displaySmall: TextStyle(color: Colors.white),
          headlineLarge: TextStyle(color: Colors.white),
          headlineMedium: TextStyle(color: Colors.white),
          headlineSmall: TextStyle(color: Colors.white),
          titleLarge: TextStyle(color: Colors.white),
          titleMedium: TextStyle(color: Colors.white),
          titleSmall: TextStyle(color: Colors.white),
          bodyLarge: TextStyle(color: Colors.white70),
          bodyMedium: TextStyle(color: Colors.white70),
          bodySmall: TextStyle(color: Colors.white54),
          labelLarge: TextStyle(color: Colors.white),
          labelMedium: TextStyle(color: Colors.white),
          labelSmall: TextStyle(color: Colors.white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.grey[800],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
        cardTheme: CardTheme(
          color: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          elevation: 4.0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[900],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: Colors.white54, width: 1.0),
          ),
          labelStyle: const TextStyle(color: Colors.white70),
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
        ),
      ),
      home: const BarterchainHomePage(),
    );
  }
}

class BarterchainHomePage extends StatelessWidget {
  const BarterchainHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barterchain'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'A new era of exchange.',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreateOfferPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Propose a Barter'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BrowseOffersPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Browse Offers'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyBartersPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('My Barters'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UserProfilePage()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('My Profile'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Settings'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HelpSupportPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Help & Support'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MarkdownViewerPage(
                      markdownAssetPath: 'assets/blockchain_plan.md',
                      pageTitle: 'Blockchain Plan: The Ledger',
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('View Blockchain Plan'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MarkdownViewerPage(
                      markdownAssetPath: 'assets/manifesto.md',
                      pageTitle: 'Barterchain Manifesto',
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Read the Manifesto'),
            ),
          ],
        ),
      ),
    );
  }
}
