import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/crypto_model.dart';
import 'crypto_item.dart';

class CryptoList extends StatelessWidget {
  final List<Crypto> cryptos;

  const CryptoList({Key? key, required this.cryptos}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await Provider.of<CryptoModel>(context, listen: false).fetchCryptos();
      },
      child: ListView.builder(
        itemCount: cryptos.length,
        itemBuilder: (context, index) {
          return CryptoItem(crypto: cryptos[index]);
        },
      ),
    );
  }
} 