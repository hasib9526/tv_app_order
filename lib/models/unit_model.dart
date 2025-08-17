
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