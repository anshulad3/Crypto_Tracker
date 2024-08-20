import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/coins_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:awesome_bottom_bar/widgets/inspired/inspired.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _channel = WebSocketChannel.connect(
      Uri.parse('ws://prereg.ex.api.ampiy.com/prices'));
  late StreamSubscription _subscription;
  List<Coins> _coins = [];
  @override
  void initState() {
    super.initState();
    _subscription = _channel.stream.listen((message) {
      final data = jsonDecode(message) as Map<String, dynamic>;
      if (data['stream'] == 'all@fpTckr') {
        setState(() {
          _coins = coinsFromData(data);
        });
      }
    });

    // send subscription message
    _channel.sink.add(jsonEncode({
      "method": "SUBSCRIBE",
      "params": ["all@ticker"],
      "cid": 1
    }));

    @override
    void dispose() {
      _channel.sink.close();
      _subscription.cancel();
      super.dispose();
    }
  }

  final controller = TextEditingController();

  void searchCoins(String query) {
    final suggestions = _coins.where((coin) {
      final coinname = coin.coin_name.toLowerCase();
      final input = query.toLowerCase();

      return coinname.contains(input);
    }).toList();
    setState(() {
      _coins = suggestions;
    });
  }

  List<TabItem> items = [
    TabItem(
      icon: Icons.home,
      title: 'Home',
    ),
    TabItem(
      icon: Icons.currency_bitcoin,
      title: 'Coins',
    ),
    TabItem(
      icon: Icons.filter_alt,
      title: 'Filter',
    ),
    TabItem(
      icon: Icons.account_balance_wallet,
      title: 'Wallet',
    ),
    TabItem(
      icon: Icons.account_circle,
      title: 'Profile',
    ),
  ];
  int visit = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      // A P P   B A R
      appBar: AppBar(
        title: Text(
          'COINS',
          style: GoogleFonts.lato(
            textStyle: TextStyle(
              fontSize: 30,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
      ),

      // M A I N    B O D Y
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(15),
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Coin Search',
                suffixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade600),
                ),
              ),
              onChanged: searchCoins,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _coins.length,
              itemBuilder: (context, index) {
                final coin = _coins[index];
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.symmetric(),
                  ),
                  margin: const EdgeInsets.only(
                    left: 6,
                    right: 6,
                    top: 5,
                    bottom: 5,
                  ),
                  child: ListTile(
                    title: Text(coin.coin_name),
                    subtitle: Row(
                      children: [
                        Text(
                          'Current Price: ',
                          style: TextStyle(fontSize: 14.0),
                        ),
                        Text(
                          "₹ " + coin.coin_current_price.toStringAsFixed(2),
                          style: TextStyle(fontSize: 14.0),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          coin.coin_price_change.toStringAsFixed(2),
                          style: TextStyle(
                            fontSize: 14.0,
                            color: coin.coin_price_change < 0
                                ? Colors.red
                                : Colors.green,
                          ),
                        ),
                        Text('%', style: TextStyle(fontSize: 14.0)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      // B O T T O M   B A R
      bottomNavigationBar: Container(
        child: BottomBarFloating(
          items: items,
          backgroundColor: Colors.grey.shade300,
          color: Colors.white,
          colorSelected: Colors.grey.shade700,
          indexSelected: visit,
          paddingVertical: 24,
          onTap: (int index) => setState(() {
            visit = index;
          }),
        ),
      ),
    );
  }
}
