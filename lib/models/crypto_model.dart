import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class Crypto {
  final String id;
  final String name;
  final String symbol;
  final double price;
  final double change24h;

  Crypto({
    required this.id,
    required this.name,
    required this.symbol,
    required this.price,
    required this.change24h,
  });

  factory Crypto.fromJson(Map<String, dynamic> json) {
    return Crypto(
      id: json['id'],
      name: json['name'],
      symbol: json['symbol'],
      price: json['price'].toDouble(),
      change24h: json['change24h'].toDouble(),
    );
  }
}

class CryptoModel extends ChangeNotifier {
  final ApiService _apiService;
  
  List<Crypto> _cryptos = [];
  bool _isLoading = false;
  String? _error;

  CryptoModel(this._apiService);

  List<Crypto> get cryptos => _cryptos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchCryptos() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final jsonData = await _apiService.fetchCryptoData();
      _cryptos = jsonData.map((json) => Crypto.fromJson(json)).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
} 