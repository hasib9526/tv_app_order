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


// // class OrderModel {
// //   String? orderID;
// //   String? barcode;
// //   String? pONo;
// //   String? style;
// //   String? buyer;
// //   String? color;
// //   String? country;
// //   String? size;
// //   String? unit;
// //   String? deliveryDate;
// //   String? deliveryMode;
// //   String? orderQty;
// //   String? cTNQty;
// //   String? cTNPerQty;
// //   String? todayPeaceFinish;
// //   String? todayPeaceShip;
// //   String? totalPeaceFinish;
// //   String? totalPeaceShip;
// //   String? balanceQty;
// //   String? todayCTNFinish;
// //   String? todayCTNShip;
// //   String? totalCTNFinish;
// //   String? totalCTNShip;
// //   String? balanceCTNQty;
// //
// //   OrderModel(
// //       {this.orderID,
// //         this.barcode,
// //         this.pONo,
// //         this.style,
// //         this.buyer,
// //         this.color,
// //         this.country,
// //         this.size,
// //         this.unit,
// //         this.deliveryDate,
// //         this.deliveryMode,
// //         this.orderQty,
// //         this.cTNQty,
// //         this.cTNPerQty,
// //         this.todayPeaceFinish,
// //         this.todayPeaceShip,
// //         this.totalPeaceFinish,
// //         this.totalPeaceShip,
// //         this.balanceQty,
// //         this.todayCTNFinish,
// //         this.todayCTNShip,
// //         this.totalCTNFinish,
// //         this.totalCTNShip,
// //         this.balanceCTNQty});
// //
// //   OrderModel.fromJson(Map<String, dynamic> json) {
// //     orderID = json['OrderID'];
// //     barcode = json['Barcode'];
// //     pONo = json['PONo'];
// //     style = json['Style'];
// //     buyer = json['Buyer'];
// //     color = json['Color'];
// //     country = json['Country'];
// //     size = json['Size'];
// //     unit = json['Unit'];
// //     deliveryDate = json['DeliveryDate'];
// //     deliveryMode = json['DeliveryMode'];
// //     orderQty = json['OrderQty'];
// //     cTNQty = json['CTNQty'];
// //     cTNPerQty = json['CTNPerQty'];
// //     todayPeaceFinish = json['TodayPeaceFinish'];
// //     todayPeaceShip = json['TodayPeaceShip'];
// //     totalPeaceFinish = json['TotalPeaceFinish'];
// //     totalPeaceShip = json['TotalPeaceShip'];
// //     balanceQty = json['BalanceQty'];
// //     todayCTNFinish = json['TodayCTNFinish'];
// //     todayCTNShip = json['TodayCTNShip'];
// //     totalCTNFinish = json['TotalCTNFinish'];
// //     totalCTNShip = json['TotalCTNShip'];
// //     balanceCTNQty = json['BalanceCTNQty'];
// //   }
// //
// //   Map<String, dynamic> toJson() {
// //     final Map<String, dynamic> data = <String, dynamic>{};
// //     data['OrderID'] = orderID;
// //     data['Barcode'] = barcode;
// //     data['PONo'] = pONo;
// //     data['Style'] = style;
// //     data['Buyer'] = buyer;
// //     data['Color'] = color;
// //     data['Country'] = country;
// //     data['Size'] = size;
// //     data['Unit'] = unit;
// //     data['DeliveryDate'] = deliveryDate;
// //     data['DeliveryMode'] = deliveryMode;
// //     data['OrderQty'] = orderQty;
// //     data['CTNQty'] = cTNQty;
// //     data['CTNPerQty'] = cTNPerQty;
// //     data['TodayPeaceFinish'] = todayPeaceFinish;
// //     data['TodayPeaceShip'] = todayPeaceShip;
// //     data['TotalPeaceFinish'] = totalPeaceFinish;
// //     data['TotalPeaceShip'] = totalPeaceShip;
// //     data['BalanceQty'] = balanceQty;
// //     data['TodayCTNFinish'] = todayCTNFinish;
// //     data['TodayCTNShip'] = todayCTNShip;
// //     data['TotalCTNFinish'] = totalCTNFinish;
// //     data['TotalCTNShip'] = totalCTNShip;
// //     data['BalanceCTNQty'] = balanceCTNQty;
// //     return data;
// //   }
// // }
// //
//
//
//
//
// class OrderModel {
//   final String id;
//   final String buyer;
//   final String style;
//   final String po;
//   final String color;
//   final String destination;
//   final String orderQty;
//   final String todayScanQty;
//   final String totalScanQty;
//   final String balance;
//   final String reqCtn;
//   final String todayScanCtn;
//   final String totalScanCtn;
//   final String remainCtnToScan;
//
//   OrderModel({
//     required this.id,
//     required this.buyer,
//     required this.style,
//     required this.po,
//     required this.color,
//     required this.destination,
//     required this.orderQty,
//     required this.todayScanQty,
//     required this.totalScanQty,
//     required this.balance,
//     required this.reqCtn,
//     required this.todayScanCtn,
//     required this.totalScanCtn,
//     required this.remainCtnToScan,
//   });
//
//   factory OrderModel.fromJson(Map<String, dynamic> json) {
//     return OrderModel(
//       id: json['id'],
//       buyer: json['buyer'],
//       style: json['style'],
//       po: json['po'],
//       color: json['color'],
//       destination: json['destination'],
//       orderQty: json['orderQty'],
//       todayScanQty: json['todayScanQty'],
//       totalScanQty: json['totalScanQty'],
//       balance: json['balance'],
//       reqCtn: json['reQ_CTN'],
//       todayScanCtn: json['todayScanCTN'],
//       totalScanCtn: json['totalScanCTN'],
//       remainCtnToScan: json['remainCTNToScan'],
//     );
//   }
// }