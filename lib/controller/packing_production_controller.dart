import 'dart:async';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../models/hourly_scan_model.dart';
import '../models/daily_scan_model.dart';
import '../models/unit_model.dart';

class PackingProductionController extends GetxController {
  final Unit unit;
  PackingProductionController({required this.unit});

  String get hourlyApiUrl =>
      'https://apps.bitopibd.com/Bimobapiv2/api/finishGood/GetHourWiseScan?companyId=06&Unit=${unit.unitName}';

  String get dailyApiUrl =>
      'https://apps.bitopibd.com/Bimobapiv2/api/finishGood/GetDateWiseScan?companyId=06&Unit=${unit.unitName}';

  var hourlyScanData = <HourlyScanModel>[].obs;
  var dailyScanData = <DailyScanModel>[].obs;
  var isLoading = true.obs;
  var errorMessage = ''.obs;
  var currentDate = DateTime.now().obs;
  Timer? _dataTimer;
  Timer? _clockTimer;

  @override
  void onInit() {
    super.onInit();
    try {
      hourlyScanData.clear();
      dailyScanData.clear();
      isLoading.value = true;
      errorMessage.value = '';
      currentDate.value = DateTime.now();

      fetchData(showLoader: true);
      _startRealTimeClock();
      _dataTimer = Timer.periodic(Duration(minutes: 10), (timer) {
        fetchData(showLoader: false);
      });
    } catch (e) {
      errorMessage.value = 'Initialization error: $e';
      isLoading.value = false;
      print('PackingProductionController onInit Error: $e');
    }
  }

  @override
  void onClose() {
    try {
      _dataTimer?.cancel();
      _clockTimer?.cancel();
      hourlyScanData.clear();
      dailyScanData.clear();
    } catch (e) {
      print('PackingProductionController onClose Error: $e');
    }
    super.onClose();
  }

  @override
  void dispose() {
    try {
      _dataTimer?.cancel();
      _clockTimer?.cancel();
      hourlyScanData.clear();
      dailyScanData.clear();
      isLoading.value = false;
      errorMessage.value = '';
    } catch (e) {
      print('PackingProductionController dispose Error: $e');
    }
    super.dispose();
  }

  void _startRealTimeClock() {
    try {
      _clockTimer?.cancel();
      _clockTimer = Timer.periodic(Duration(seconds: 1), (timer) {
        try {
          currentDate.value = DateTime.now();
        } catch (e) {
          print('Clock timer error: $e');
        }
      });
    } catch (e) {
      print('Start real time clock error: $e');
    }
  }

  Future<void> fetchData({bool showLoader = true}) async {
    try {
      if (showLoader) {
        isLoading.value = true;
      }
      errorMessage.value = '';

      // Fetch both APIs in parallel
      final responses = await Future.wait([
        http
            .get(
              Uri.parse(hourlyApiUrl),
              headers: {'Content-Type': 'application/json'},
            )
            .timeout(
              Duration(seconds: 15),
              onTimeout: () {
                throw TimeoutException(
                    'Request timeout after 10 seconds', Duration(seconds: 15));
              },
            ),
        http
            .get(
              Uri.parse(dailyApiUrl),
              headers: {'Content-Type': 'application/json'},
            )
            .timeout(
              Duration(seconds: 15),
              onTimeout: () {
                throw TimeoutException(
                    'Request timeout after 10 seconds', Duration(seconds: 15));
              },
            ),
      ]);

      final hourlyResponse = responses[0];
      final dailyResponse = responses[1];

      // Process Hourly Data
      if (hourlyResponse.statusCode == 200) {
        try {
          final responseBody = hourlyResponse.body.trim();
          if (responseBody.isEmpty) {
            throw FormatException('Hourly data: Server returned empty response');
          }

          List<dynamic> jsonData = json.decode(responseBody);

          if (jsonData == null) {
            throw FormatException('Hourly data: Invalid JSON data received');
          }

          hourlyScanData.value = jsonData
              .map((item) {
                try {
                  if (item == null) {
                    print('Warning: Null item found in hourly API response');
                    return null;
                  }
                  return HourlyScanModel.fromJson(item);
                } catch (e) {
                  print('Error parsing hourly item: $e, Item: $item');
                  return null;
                }
              })
              .where((item) => item != null)
              .cast<HourlyScanModel>()
              .toList();
        } catch (e) {
          if (e is FormatException) {
            errorMessage.value = 'Invalid hourly data format from server';
          } else {
            errorMessage.value =
                'Error processing hourly data: ${e.toString()}';
          }
          print('Hourly response processing error: $e');
        }
      } else {
        errorMessage.value =
            'Failed to load hourly data (Status: ${hourlyResponse.statusCode})';
      }

      // Process Daily Data
      if (dailyResponse.statusCode == 200) {
        try {
          final responseBody = dailyResponse.body.trim();
          if (responseBody.isEmpty) {
            throw FormatException('Daily data: Server returned empty response');
          }

          List<dynamic> jsonData = json.decode(responseBody);

          if (jsonData == null) {
            throw FormatException('Daily data: Invalid JSON data received');
          }

          dailyScanData.value = jsonData
              .map((item) {
                try {
                  if (item == null) {
                    print('Warning: Null item found in daily API response');
                    return null;
                  }
                  return DailyScanModel.fromJson(item);
                } catch (e) {
                  print('Error parsing daily item: $e, Item: $item');
                  return null;
                }
              })
              .where((item) => item != null)
              .cast<DailyScanModel>()
              .toList();
        } catch (e) {
          if (e is FormatException) {
            errorMessage.value = 'Invalid daily data format from server';
          } else {
            errorMessage.value = 'Error processing daily data: ${e.toString()}';
          }
          print('Daily response processing error: $e');
        }
      } else {
        errorMessage.value =
            'Failed to load daily data (Status: ${dailyResponse.statusCode})';
      }
    } on TimeoutException catch (e) {
      errorMessage.value =
          'Request timeout. Please check your internet connection.';
      print('Fetch Data Timeout Error: $e');
    } on SocketException catch (e) {
      errorMessage.value =
          'Network error. Please check your internet connection.';
      print('Fetch Data Socket Error: $e');
    } on FormatException catch (e) {
      errorMessage.value = 'Invalid server response format';
      print('Fetch Data Format Error: $e');
    } on http.ClientException catch (e) {
      errorMessage.value = 'Connection failed. Please try again.';
      print('Fetch Data HTTP Client Error: $e');
    } catch (e) {
      if (e.toString().contains('XMLHttpRequest')) {
        errorMessage.value = 'Network connection failed';
      } else {
        errorMessage.value = 'Unexpected error occurred';
      }
      print('Fetch Data Unexpected Error: $e');
    } finally {
      try {
        if (showLoader) {
          isLoading.value = false;
        }
      } catch (e) {
        print('Error updating loading state: $e');
      }
    }
  }

  // Helper methods for chart data
  List<double> get hourlyDataList {
    return hourlyScanData.map((e) => e.todayScanFinish).toList();
  }

  List<String> get hourlyLabels {
    return hourlyScanData
        .map((e) => _formatHourLabel(e.hourOnly))
        .toList();
  }

  String _formatHourLabel(int hour) {
    if (hour == 1) return '1st';
    if (hour == 2) return '2nd';
    if (hour == 3) return '3rd';
    return '${hour}th';
  }

  List<double> get dailyDataList {
    return dailyScanData.map((e) => e.todayScanFinish / 1000).toList();
  }

  List<String> get dailyLabels {
    return dailyScanData.map((e) => _formatDateLabel(e.scanDate)).toList();
  }

  String _formatDateLabel(String dateStr) {
    try {
      // Parse "23 Sep 2025" format
      final parts = dateStr.split(' ');
      if (parts.length == 3) {
        return '${parts[0]}-${parts[1]}';
      }
      return dateStr;
    } catch (e) {
      return dateStr;
    }
  }

  double get hourlyTotal {
    return hourlyScanData.fold(0.0, (sum, item) => sum + item.todayScanFinish);
  }

  double get dailyTotal {
    return dailyScanData.fold(0.0, (sum, item) => sum + item.todayScanFinish);
  }

  double get dailyAverage {
    if (dailyScanData.isEmpty) return 0.0;
    return dailyTotal / dailyScanData.length;
  }

  double get dailyHighest {
    if (dailyScanData.isEmpty) return 0.0;
    return dailyScanData
        .map((e) => e.todayScanFinish)
        .reduce((a, b) => a > b ? a : b);
  }

  double get dailyLowest {
    if (dailyScanData.isEmpty) return 0.0;
    return dailyScanData
        .map((e) => e.todayScanFinish)
        .reduce((a, b) => a < b ? a : b);
  }

  String get runningDayDate {
    return DateFormat('dd-MMM').format(currentDate.value);
  }

  String get dailyDateRange {
    if (dailyScanData.isEmpty) return '';
    final first = dailyScanData.first.scanDate;
    final last = dailyScanData.last.scanDate;
    return '$first to $last';
  }
}
