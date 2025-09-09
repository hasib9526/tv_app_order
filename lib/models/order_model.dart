class OrderModel {
  final String poNo;
  final String style;
  final String buyer;
  final String color;
  final String country;
  final String unit;
  final String orderQty;
  final String ctnQty;
  final String balanceQty;
  final String todayCTNFinish;
  final String totalCTNFinish;
  final String balanceCTNQty;
  final String shipmentDate;

  OrderModel({
    required this.poNo,
    required this.style,
    required this.buyer,
    required this.color,
    required this.country,
    required this.unit,
    required this.orderQty,
    required this.ctnQty,
    required this.balanceQty,
    required this.todayCTNFinish,
    required this.totalCTNFinish,
    required this.balanceCTNQty,
    required this.shipmentDate,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      poNo: json['PONo'] ?? '',
      style: json['Style'] ?? '',
      buyer: json['Buyer'] ?? '',
      color: json['Color'] ?? '',
      country: json['Country'] ?? '',
      unit: json['Unit'] ?? '',
      orderQty: json['OrderQty'] ?? '',
      ctnQty: json['CTNQty'] ?? '',
      balanceQty: json['BalanceQty'] ?? '',
      todayCTNFinish: json['TodayCTNFinish'] ?? '',
      totalCTNFinish: json['TotalCTNFinish'] ?? '',
      balanceCTNQty: json['BalanceCTNQty'] ?? '',
      shipmentDate: json['ShipmentDate'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'PONo': poNo,
      'Style': style,
      'Buyer': buyer,
      'Color': color,
      'Country': country,
      'Unit': unit,
      'OrderQty': orderQty,
      'CTNQty': ctnQty,
      'BalanceQty': balanceQty,
      'TodayCTNFinish': todayCTNFinish,
      'TotalCTNFinish': totalCTNFinish,
      'BalanceCTNQty': balanceCTNQty,
      'ShipmentDate': shipmentDate,
    };
  }
}
