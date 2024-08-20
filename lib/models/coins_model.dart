class Coins {
  final String coin_name;
  final double coin_current_price;
  final double coin_price_change;
  Coins({
    required this.coin_name,
    required this.coin_current_price,
    required this.coin_price_change,
  });

  factory Coins.fromJson(Map<String, dynamic> json) {
    return Coins(
      coin_name: json['s'],
      coin_current_price: double.parse(json['c']),
      coin_price_change: double.parse(json['p']),
    );
  }
}

List<Coins> coinsFromData(Map<String, dynamic> data) {
  final List<Coins> coins = [];
  for (var item in data['data']) {
    if (item['T'] == 'fpTckr') {
      coins.add(Coins.fromJson(item));
    }
  }
  return coins;
}
