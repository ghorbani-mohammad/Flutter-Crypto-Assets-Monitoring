import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:async';
import 'constants.dart';

class Transaction {
  final int id;
  final String type;
  final String market;
  final String coin;
  final double price;
  final double quantity;
  final double totalPrice;
  final double currentValue;
  final String date;
  final double changePercentage;

  Transaction({
    required this.id,
    required this.type,
    required this.market,
    required this.coin,
    required this.price,
    required this.quantity,
    required this.totalPrice,
    required this.currentValue,
    required this.date,
    required this.changePercentage,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      type: json['type'] ?? '',
      market: json['market'] ?? '',
      coin: json['coin'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: (json['quantity'] ?? 0).toDouble(),
      totalPrice: (json['total_price'] ?? 0).toDouble(),
      currentValue: (json['current_value'] ?? 0).toDouble(),
      date: json['date'] ?? '',
      changePercentage: (json['change_percentage'] ?? 0).toDouble(),
    );
  }
}

class TransactionsTab extends StatefulWidget {
  const TransactionsTab({super.key});

  @override
  State<TransactionsTab> createState() => _TransactionsTabState();
}

class _TransactionsTabState extends State<TransactionsTab> {
  List<Transaction> transactions = [];
  bool isLoading = true;
  String? errorMessage;
  String? nextPageUrl;
  bool isLoadingMore = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchTransactions();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (nextPageUrl != null && !isLoadingMore) {
        loadMoreTransactions();
      }
    }
  }

  Future<void> fetchTransactions() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    
    try {
      final response = await http.get(
        Uri.parse('https://crypto.m-gh.com/api/v1/exc/transactions/'),
      ).timeout(const Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          transactions = (data['results'] as List)
              .map((item) => Transaction.fromJson(item))
              .toList();
          nextPageUrl = data['next'];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load transactions. Status: ${response.statusCode}';
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

  Future<void> loadMoreTransactions() async {
    if (nextPageUrl == null || isLoadingMore) return;
    
    setState(() {
      isLoadingMore = true;
    });
    
    try {
      final response = await http.get(
        Uri.parse(nextPageUrl!),
      ).timeout(const Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          transactions.addAll((data['results'] as List)
              .map((item) => Transaction.fromJson(item))
              .toList());
          nextPageUrl = data['next'];
          isLoadingMore = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load more transactions.';
          isLoadingMore = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading more: ${e.toString()}';
        isLoadingMore = false;
      });
    }
  }

  String formatDate(String date) {
    // The date comes in format "1400-10-21 03:30:00" (Persian calendar)
    // We'll just display it as-is for now
    return date;
  }

  String formatPrice(double price, String market) {
    final formatter = NumberFormat('#,##0.##', 'en_US');
    final formattedPrice = formatter.format(price);
    
    // Add currency symbol based on market
    if (market.toLowerCase() == 'usdt') {
      return '\$$formattedPrice';
    } else if (market.toLowerCase() == 'irt') {
      return '$formattedPrice IRT';
    }
    return formattedPrice;
  }

  Color getPercentageColor(double percentage) {
    if (percentage > 0) {
      return Colors.green;
    } else if (percentage < 0) {
      return Colors.red;
    }
    return Colors.grey;
  }

  IconData getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'buy':
        return Icons.arrow_downward;
      case 'sell':
        return Icons.arrow_upward;
      default:
        return Icons.swap_horiz;
    }
  }

  Color getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'buy':
        return Colors.green;
      case 'sell':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading 
      ? Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary))
      : errorMessage != null
        ? Center(child: Text(errorMessage!, style: const TextStyle(color: Colors.red)))
        : transactions.isEmpty
          ? Center(child: Text('No transactions found'))
          : RefreshIndicator(
              onRefresh: fetchTransactions,
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: transactions.length + (nextPageUrl != null ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == transactions.length) {
                          // Show loading indicator at the bottom when loading more
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          );
                        }
                        
                        final transaction = transactions[index];
                        
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 16,
                                          backgroundColor: getTypeColor(transaction.type).withOpacity(0.2),
                                          child: Icon(
                                            getTypeIcon(transaction.type),
                                            size: 16,
                                            color: getTypeColor(transaction.type),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          transaction.coin,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      formatDate(transaction.date),
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Purchase Price',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                        Text(
                                          formatPrice(transaction.price, transaction.market),
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'Quantity',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                        Text(
                                          transaction.quantity.toString(),
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Total Value',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                        Text(
                                          formatPrice(transaction.totalPrice, transaction.market),
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'Current Value',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                        Text(
                                          formatPrice(transaction.currentValue, transaction.market),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: getPercentageColor(transaction.changePercentage),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color: getPercentageColor(transaction.changePercentage).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  child: Text(
                                    '${transaction.changePercentage > 0 ? '+' : ''}${transaction.changePercentage.toStringAsFixed(2)}%',
                                    style: TextStyle(
                                      color: getPercentageColor(transaction.changePercentage),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
  }
} 