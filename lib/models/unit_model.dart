// class Unit {
//   String? unitID;
//   String? unitName;
//
//   Unit({this.unitID, this.unitName});
//
//   Unit.fromJson(Map<String, dynamic> json) {
//     unitID = json['UnitID'];
//     unitName = json['UnitName'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['UnitID'] = unitID;
//     data['UnitName'] = unitName;
//     return data;
//   }
// }


class Unit {
  final String unitID;
  final String unitName;

  Unit({required this.unitID, required this.unitName});

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      unitID: json['UnitID'],
      unitName: json['UnitName'],
    );
  }
}