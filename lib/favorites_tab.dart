import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:flutter_svg/flutter_svg.dart';
import 'constants.dart';

class CryptoCoin {
  final String code;
  final String title;
  final String? icon;
  final double? price;

  CryptoCoin({
    required this.code,
    required this.title,
    this.icon,
    this.price,
  });

  factory CryptoCoin.fromJson(Map<String, dynamic> json) {
    return CryptoCoin(
      code: json['code'] ?? '',
      title: json['title'] ?? '',
      icon: json['icon'],
      price: json['price']?.toDouble(),
    );
  }
}

class CryptoResponse {
  final int count;
  final String? next;
  final String? previous;
  final List<CryptoCoin> results;

  CryptoResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory CryptoResponse.fromJson(Map<String, dynamic> json) {
    return CryptoResponse(
      count: json['count'] ?? 0,
      next: json['next'],
      previous: json['previous'],
      results: (json['results'] as List<dynamic>?)
          ?.map((item) => CryptoCoin.fromJson(item))
          .toList() ?? [],
    );
  }
}

class FavoritesTab extends StatefulWidget {
  const FavoritesTab({super.key});

  @override
  State<FavoritesTab> createState() => _FavoritesTabState();
}

class _FavoritesTabState extends State<FavoritesTab> {
  List<CryptoCoin> cryptoCoins = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  String? errorMessage;
  String? nextPageUrl;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchCryptoPrices();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (nextPageUrl != null && !isLoadingMore) {
        _loadMoreCoins();
      }
    }
  }

  Future<void> fetchCryptoPrices() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      cryptoCoins.clear();
    });
    
    try {
      final client = http.Client();
      final request = http.Request('GET', Uri.parse('https://crypto.m-gh.com/api/v1/exc/cached-prices/'));
      
      try {
        final streamedResponse = await client.send(request)
            .timeout(const Duration(seconds: 10), 
              onTimeout: () => throw TimeoutException('Connection timeout. Please check your internet connection.'));
              
        final response = await http.Response.fromStream(streamedResponse);
        
        if (response.statusCode == 200) {
          final cryptoResponse = CryptoResponse.fromJson(json.decode(response.body));
          setState(() {
            cryptoCoins = cryptoResponse.results;
            nextPageUrl = cryptoResponse.next;
            isLoading = false;
          });
          return;
        }
      } catch (primaryError) {
        print('Primary API failed: $primaryError');
      }
      
      // Try fallback API (CoinGecko as example)
      try {
        final fallbackResponse = await http.get(
          Uri.parse('https://api.coingecko.com/api/v3/simple/price?ids=bitcoin,ethereum,litecoin&vs_currencies=usd'),
        ).timeout(const Duration(seconds: 10));
        
        if (fallbackResponse.statusCode == 200) {
          final Map<String, dynamic> fallbackData = json.decode(fallbackResponse.body);
          // Convert CoinGecko response to match our app's format
          final List<CryptoCoin> adaptedCoins = [
            CryptoCoin(
              code: 'BTC',
              title: 'Bitcoin',
              price: fallbackData['bitcoin']?['usd']?.toDouble(),
            ),
            CryptoCoin(
              code: 'ETH',
              title: 'Ethereum',
              price: fallbackData['ethereum']?['usd']?.toDouble(),
            ),
            CryptoCoin(
              code: 'LTC',
              title: 'Litecoin',
              price: fallbackData['litecoin']?['usd']?.toDouble(),
            ),
          ];
          
          setState(() {
            cryptoCoins = adaptedCoins;
            nextPageUrl = null;
            isLoading = false;
          });
        } else {
          throw Exception('Fallback API failed with status: ${fallbackResponse.statusCode}');
        }
      } catch (fallbackError) {
        setState(() {
          errorMessage = 'All API attempts failed. Please check your internet connection.';
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

  Future<void> _loadMoreCoins() async {
    if (nextPageUrl == null || isLoadingMore) return;

    setState(() {
      isLoadingMore = true;
    });

    try {
      final response = await http.get(Uri.parse(nextPageUrl!))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final cryptoResponse = CryptoResponse.fromJson(json.decode(response.body));
        setState(() {
          cryptoCoins.addAll(cryptoResponse.results);
          nextPageUrl = cryptoResponse.next;
          isLoadingMore = false;
        });
      } else {
        setState(() {
          isLoadingMore = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoadingMore = false;
      });
    }
  }

  // Format large numbers with commas
  String formatPrice(double? price) {
    if (price == null) return 'N/A';
    final formatter = NumberFormat('#,##0.##', 'en_US');
    return formatter.format(price);
  }

  // Get crypto icon based on symbol
  IconData getCryptoIcon(String symbol) {
    switch (symbol.toLowerCase()) {
      case 'btc':
        return Icons.currency_bitcoin;
      case 'eth':
        return Icons.account_balance_wallet;
      case 'bnb':
        return Icons.account_balance;
      case 'trx':
        return Icons.trending_up;
      case 'matic':
        return Icons.hexagon;
      default:
        return Icons.monetization_on;
    }
  }

  Widget _buildCoinIcon(CryptoCoin coin) {
    if (coin.icon != null && coin.icon!.isNotEmpty) {
      // Check if the icon is an SVG
      if (coin.icon!.toLowerCase().endsWith('.svg')) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SvgPicture.network(
            coin.icon!,
            width: 40,
            height: 40,
            placeholderBuilder: (BuildContext context) => SizedBox(
              width: 40,
              height: 40,
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
            ),
          ),
        );
      } else {
        // For non-SVG images (PNG, JPG, etc.)
        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.network(
            coin.icon!,
            width: 40,
            height: 40,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Icon(getCryptoIcon(coin.code), size: 24);
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return SizedBox(
                width: 40,
                height: 40,
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                        : null,
                    strokeWidth: 2,
                  ),
                ),
              );
            },
          ),
        );
      }
    } else {
      return Icon(getCryptoIcon(coin.code), size: 24);
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading 
      ? Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary))
      : errorMessage != null
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(errorMessage!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: fetchCryptoPrices,
                  child: const Text('Retry'),
                ),
              ],
            ),
          )
        : RefreshIndicator(
            color: Theme.of(context).colorScheme.primary,
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
          );
  }

  Widget _buildFeaturedCryptoSection() {
    // Featured cryptocurrencies (Bitcoin, Ethereum, and BNB)
    final featuredCodes = ['BTC', 'ETH', 'BNB'];
    final featuredCoins = cryptoCoins.where((coin) => featuredCodes.contains(coin.code)).toList();
    
    if (featuredCoins.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.05),
              Theme.of(context).colorScheme.secondary.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Featured Cryptocurrencies',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: featuredCoins.map((coin) {
                    return Container(
                      width: 160,
                      margin: const EdgeInsets.only(right: 12),
                      child: _buildFeaturedCryptoCard(coin),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedCryptoCard(CryptoCoin coin) {
    final formattedPrice = formatPrice(coin.price);
    
    // Use different colors for different coins
    Color cardColor;
    Color iconColor;
    
    switch (coin.code.toLowerCase()) {
      case 'btc':
        cardColor = Theme.of(context).colorScheme.primaryContainer;
        iconColor = Theme.of(context).colorScheme.primary;
        break;
      case 'eth':
        cardColor = Theme.of(context).colorScheme.secondaryContainer;
        iconColor = Theme.of(context).colorScheme.secondary;
        break;
      default:
        cardColor = Theme.of(context).colorScheme.tertiaryContainer ?? Theme.of(context).colorScheme.primaryContainer;
        iconColor = Theme.of(context).colorScheme.tertiary ?? Theme.of(context).colorScheme.primary;
    }

    return Card(
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildCoinIcon(coin),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    coin.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: iconColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              coin.code,
              style: TextStyle(
                fontSize: 12,
                color: iconColor.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              formattedPrice,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCryptoList() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: cryptoCoins.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == cryptoCoins.length) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final coin = cryptoCoins[index];
        final formattedPrice = formatPrice(coin.price);
        
        // Alternate between primary and secondary colors for list items
        final isEven = index % 2 == 0;
        final avatarColor = isEven 
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.secondaryContainer;
        final iconColor = isEven
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.secondary;
            
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: avatarColor,
              child: _buildCoinIcon(coin),
            ),
            title: Text(
              coin.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: iconColor,
              ),
            ),
            subtitle: Text(coin.code.toUpperCase()),
            trailing: Text(
              formattedPrice,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: coin.price == null 
                    ? Colors.grey
                    : isEven 
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
        );
      },
    );
  }
} 