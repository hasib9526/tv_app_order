class OrderModel {
  final String orderID;
  final String barcode;
  final String poNo;
  final String style;
  final String buyer;
  final String color;
  final String country;
  final String size;
  final String unit;
  final String deliveryDate;
  final String deliveryMode;
  final String orderQty;
  final String ctnQty;
  final String ctnPerQty;
  final String todayPeaceFinish;
  final String todayPeaceShip;
  final String totalPeaceFinish;
  final String totalPeaceShip;
  final String balanceQty;
  final String todayCTNFinish;
  final String todayCTNShip;
  final String totalCTNFinish;
  final String totalCTNShip;
  final String balanceCTNQty;

  OrderModel({
    required this.orderID,
    required this.barcode,
    required this.poNo,
    required this.style,
    required this.buyer,
    required this.color,
    required this.country,
    required this.size,
    required this.unit,
    required this.deliveryDate,
    required this.deliveryMode,
    required this.orderQty,
    required this.ctnQty,
    required this.ctnPerQty,
    required this.todayPeaceFinish,
    required this.todayPeaceShip,
    required this.totalPeaceFinish,
    required this.totalPeaceShip,
    required this.balanceQty,
    required this.todayCTNFinish,
    required this.todayCTNShip,
    required this.totalCTNFinish,
    required this.totalCTNShip,
    required this.balanceCTNQty,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      orderID: json['OrderID'] ?? '',
      barcode: json['Barcode'] ?? '',
      poNo: json['PONo'] ?? '',
      style: json['Style'] ?? '',
      buyer: json['Buyer'] ?? '',
      color: json['Color'] ?? '',
      country: json['Country'] ?? '',
      size: json['Size'] ?? '',
      unit: json['Unit'] ?? '',
      deliveryDate: json['DeliveryDate'] ?? '',
      deliveryMode: json['DeliveryMode'] ?? '',
      orderQty: json['OrderQty'] ?? '',
      ctnQty: json['CTNQty'] ?? '',
      ctnPerQty: json['CTNPerQty'] ?? '',
      todayPeaceFinish: json['TodayPeaceFinish'] ?? '',
      todayPeaceShip: json['TodayPeaceShip'] ?? '',
      totalPeaceFinish: json['TotalPeaceFinish'] ?? '',
      totalPeaceShip: json['TotalPeaceShip'] ?? '',
      balanceQty: json['BalanceQty'] ?? '',
      todayCTNFinish: json['TodayCTNFinish'] ?? '',
      todayCTNShip: json['TodayCTNShip'] ?? '',
      totalCTNFinish: json['TotalCTNFinish'] ?? '',
      totalCTNShip: json['TotalCTNShip'] ?? '',
      balanceCTNQty: json['BalanceCTNQty'] ?? '',
    );
  }
}
