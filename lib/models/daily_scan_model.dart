class DailyScanModel {
  final String companyId;
  final String unit;
  final String scanDate;
  final double todayScanFinish;

  DailyScanModel({
    required this.companyId,
    required this.unit,
    required this.scanDate,
    required this.todayScanFinish,
  });

  factory DailyScanModel.fromJson(Map<String, dynamic> json) {
    return DailyScanModel(
      companyId: json['CompanyId']?.toString() ?? '',
      unit: json['Unit']?.toString() ?? '',
      scanDate: json['ScanDate']?.toString() ?? '',
      todayScanFinish: (json['TodayScanFinish'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'CompanyId': companyId,
      'Unit': unit,
      'ScanDate': scanDate,
      'TodayScanFinish': todayScanFinish,
    };
  }
}
