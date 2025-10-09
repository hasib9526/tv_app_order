class HourlyScanModel {
  final String companyId;
  final String unit;
  final int hourOnly;
  final double todayScanFinish;

  HourlyScanModel({
    required this.companyId,
    required this.unit,
    required this.hourOnly,
    required this.todayScanFinish,
  });

  factory HourlyScanModel.fromJson(Map<String, dynamic> json) {
    return HourlyScanModel(
      companyId: json['CompanyId']?.toString() ?? '',
      unit: json['Unit']?.toString() ?? '',
      hourOnly: json['HourOnly'] ?? 0,
      todayScanFinish: (json['TodayScanFinish'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'CompanyId': companyId,
      'Unit': unit,
      'HourOnly': hourOnly,
      'TodayScanFinish': todayScanFinish,
    };
  }
}
