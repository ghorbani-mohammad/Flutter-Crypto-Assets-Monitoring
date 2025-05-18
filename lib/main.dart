import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crypto Price Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const CryptoPriceScreen(),
    );
  }
}

class CryptoPriceScreen extends StatefulWidget {
  const CryptoPriceScreen({super.key});

  @override
  State<CryptoPriceScreen> createState() => _CryptoPriceScreenState();
}

class _CryptoPriceScreenState extends State<CryptoPriceScreen> {
  Map<String, dynamic> cryptoPrices = {};
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchCryptoPrices();
  }

  Future<void> fetchCryptoPrices() async {
    try {
      final response = await http.get(Uri.parse('https://crypto.m-gh.com/api/v1/exc/cached-prices/'));
      
      if (response.statusCode == 200) {
        setState(() {
          cryptoPrices = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load data: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  // Format large numbers with commas
  String formatPrice(dynamic price) {
    if (price is num) {
      final formatter = NumberFormat('#,##0.00', 'en_US');
      return formatter.format(price);
    }
    return price.toString();
  }

  // Get crypto icon based on symbol
  IconData getCryptoIcon(String symbol) {
    switch (symbol.toLowerCase()) {
      case 'btc':
        return Icons.currency_bitcoin;
      case 'eth':
        return Icons.account_balance_wallet;
      default:
        return Icons.monetization_on;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Crypto Price Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                isLoading = true;
              });
              fetchCryptoPrices();
            },
          ),
        ],
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator())
        : errorMessage != null
          ? Center(child: Text(errorMessage!, style: const TextStyle(color: Colors.red)))
          : RefreshIndicator(
              onRefresh: fetchCryptoPrices,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    // Featured crypto section
                    _buildFeaturedCryptoSection(),
                    const SizedBox(height: 16),
                    // All crypto section
                    Expanded(
                      child: _buildCryptoList(),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildFeaturedCryptoSection() {
    // Featured cryptocurrencies (Bitcoin and Ethereum)
    final featuredCoins = ['btc', 'eth'];
    
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Featured Cryptocurrencies',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: featuredCoins.map((symbol) {
                return Expanded(
                  child: _buildFeaturedCryptoCard(symbol),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedCryptoCard(String symbol) {
    if (!cryptoPrices.containsKey(symbol)) {
      return const SizedBox.shrink();
    }

    final price = cryptoPrices[symbol];
    final formattedPrice = formatPrice(price);
    
    // Coin name with first letter capitalized
    final coinName = symbol.isNotEmpty 
        ? '${symbol[0].toUpperCase()}${symbol.substring(1)}'
        : '';

    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(getCryptoIcon(symbol), size: 24),
                const SizedBox(width: 8),
                Text(
                  coinName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '\$${formattedPrice}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCryptoList() {
    final sortedSymbols = cryptoPrices.keys.toList()
      ..sort((a, b) => a.compareTo(b));

    return ListView.builder(
      itemCount: sortedSymbols.length,
      itemBuilder: (context, index) {
        final symbol = sortedSymbols[index];
        final price = cryptoPrices[symbol];
        final formattedPrice = formatPrice(price);
        
        // Coin name with first letter capitalized
        final coinName = symbol.isNotEmpty 
            ? '${symbol[0].toUpperCase()}${symbol.substring(1)}'
            : '';

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(getCryptoIcon(symbol)),
            ),
            title: Text(
              coinName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(symbol.toUpperCase()),
            trailing: Text(
              '\$${formattedPrice}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        );
      },
    );
  }
}
