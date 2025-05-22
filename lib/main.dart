import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:async';
import 'constants.dart';
import 'favorites_tab.dart';
import 'transactions_tab.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: const Color(0xFF1565C0),    // Deep blue
          secondary: const Color(0xFF2E7D32),  // Green
          tertiary: const Color(0xFF00BFA5),   // Teal green
          primaryContainer: const Color(0xFFE3F2FD), // Light blue
          secondaryContainer: const Color(0xFFE8F5E9), // Light green
          background: Colors.white,
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1565C0),
          foregroundColor: Colors.white,
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        useMaterial3: true,
      ),
      home: const CryptoApp(),
    );
  }
}

class CryptoApp extends StatefulWidget {
  const CryptoApp({super.key});

  @override
  State<CryptoApp> createState() => _CryptoAppState();
}

class _CryptoAppState extends State<CryptoApp> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppConstants.appName),
        actions: [
          // Version indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            alignment: Alignment.center,
            child: Text(AppConstants.appVersion, style: const TextStyle(fontSize: 12)),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
          tabs: const [
            Tab(
              icon: Icon(Icons.star),
              text: 'Favorite Coins',
            ),
            Tab(
              icon: Icon(Icons.receipt_long),
              text: 'Transactions',
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFF5F9FD), // Light blue background
      body: TabBarView(
        controller: _tabController,
        children: const [
          FavoritesTab(),
          TransactionsTab(),
        ],
      ),
    );
  }
}
