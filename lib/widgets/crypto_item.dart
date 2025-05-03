import 'package:flutter/material.dart';
import '../models/crypto_model.dart';

class CryptoItem extends StatelessWidget {
  final Crypto crypto;

  const CryptoItem({Key? key, required this.crypto}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Set color based on price change (green for positive, red for negative)
    final Color changeColor = crypto.change24h >= 0 ? Colors.green : Colors.red;
    final String changeSign = crypto.change24h >= 0 ? '+' : '';

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            // Crypto symbol and name
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    crypto.symbol,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    crypto.name,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            // Price
            Expanded(
              flex: 3,
              child: Text(
                '\$${crypto.price.toStringAsFixed(2)}',
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            
            // Change percentage
            Expanded(
              flex: 2,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: changeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$changeSign${crypto.change24h.toStringAsFixed(2)}%',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: changeColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 