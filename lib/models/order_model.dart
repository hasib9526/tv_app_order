class OrderModel {
  final int id;
  final String buyer;
  final String style;
  final String po;
  final String color;
  final String destination;
  final int orderQty;
  final int todayScanQty;
  final int totalScanQty;
  final int balance;
  final int reqCtn;
  final int todayScanCtn;
  final int totalScanCtn;
  final int remainCtnToScan;

  OrderModel({
    required this.id,
    required this.buyer,
    required this.style,
    required this.po,
    required this.color,
    required this.destination,
    required this.orderQty,
    required this.todayScanQty,
    required this.totalScanQty,
    required this.balance,
    required this.reqCtn,
    required this.todayScanCtn,
    required this.totalScanCtn,
    required this.remainCtnToScan,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      buyer: json['buyer'],
      style: json['style'],
      po: json['po'],
      color: json['color'],
      destination: json['destination'],
      orderQty: json['orderQty'],
      todayScanQty: json['todayScanQty'],
      totalScanQty: json['totalScanQty'],
      balance: json['balance'],
      reqCtn: json['reQ_CTN'],
      todayScanCtn: json['todayScanCTN'],
      totalScanCtn: json['totalScanCTN'],
      remainCtnToScan: json['remainCTNToScan'],
    );
  }
}