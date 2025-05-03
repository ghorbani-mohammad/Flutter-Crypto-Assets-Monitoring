import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/crypto_model.dart';
import 'services/api_service.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CryptoModel(ApiService()),
      child: MaterialApp(
        title: 'Crypto Monitor',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          brightness: Brightness.dark,
        ),
        themeMode: ThemeMode.system,
        home: HomeScreen(),
      ),
    );
  }
} 