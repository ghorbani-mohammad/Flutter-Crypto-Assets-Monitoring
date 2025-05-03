import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/crypto_model.dart';
import '../widgets/crypto_list.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch data when screen loads
    Future.microtask(() => 
      Provider.of<CryptoModel>(context, listen: false).fetchCryptos()
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crypto Monitor'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              Provider.of<CryptoModel>(context, listen: false).fetchCryptos();
            },
          ),
        ],
      ),
      body: Consumer<CryptoModel>(
        builder: (context, cryptoModel, child) {
          if (cryptoModel.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          
          if (cryptoModel.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error loading data',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Text(
                    cryptoModel.error!,
                    style: TextStyle(fontSize: 14, color: Colors.red),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Provider.of<CryptoModel>(context, listen: false).fetchCryptos();
                    },
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }
          
          if (cryptoModel.cryptos.isEmpty) {
            return Center(child: Text('No crypto data available'));
          }
          
          return CryptoList(cryptos: cryptoModel.cryptos);
        },
      ),
    );
  }
} 