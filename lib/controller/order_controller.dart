import 'dart:async';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/order_model.dart';
import '../models/unit_model.dart';

class OrderController extends GetxController {
  final Unit unit;
  OrderController({required this.unit});

  String get apiUrl => 'http://apps.bitopibd.com:8090/bimobapiv2/api/FinishingBarcode/GetFinishingBarcodeData?unit=${unit.unitName}';

  var orders = <OrderModel>[].obs;
  var isLoading = true.obs;
  var errorMessage = ''.obs;
  var lastUpdated = DateTime.now().obs;
  var currentTime = DateTime.now().obs;
  var lastDataUpdate = DateTime.now().obs;
  var currentPage = 0.obs;
  var itemsPerPage = 16.obs; // This will be dynamically calculated
  var unitName = ''.obs;
  var showPackingDashboard = false.obs;
  var isInPackingDashboardCycle = false.obs;
  Timer? _dashboardCycleTimer;
  Timer? _clockTimer;
  Timer? _dataTimer;
  Timer? _pageTimer;

  @override
  void onInit() {
    super.onInit();
    try {
      orders.clear();
      isLoading.value = true;
      errorMessage.value = '';
      currentPage.value = 0;
      unitName.value = unit.unitName;
      showPackingDashboard.value = false;
      isInPackingDashboardCycle.value = false;

      fetchOrders(showLoader: true);
      _setupPageTimer();
      _startRealTimeClock();
      _dataTimer = Timer.periodic(Duration(minutes:10), (timer) {
        fetchOrders(showLoader: false);
      });
    } catch (e) {
      errorMessage.value = 'Initialization error: $e';
      isLoading.value = false;
      print('OrderController onInit Error: $e');
    }
  }

  @override
  void onClose() {
    try {
      _dataTimer?.cancel();
      _pageTimer?.cancel();
      _clockTimer?.cancel();
      _dashboardCycleTimer?.cancel();
      orders.clear();
    } catch (e) {
      print('OrderController onClose Error: $e');
    }
    super.onClose();
  }

  @override
  void dispose() {
    try {
      _dataTimer?.cancel();
      _pageTimer?.cancel();
      _clockTimer?.cancel();
      _dashboardCycleTimer?.cancel();
      orders.clear();
      isLoading.value = false;
      errorMessage.value = '';
      currentPage.value = 0;
    } catch (e) {
      print('OrderController dispose Error: $e');
    }
    super.dispose();
  }

  void _startRealTimeClock() {
    try {
      _clockTimer?.cancel();
      _clockTimer = Timer.periodic(Duration(seconds: 1), (timer) {
        try {
          currentTime.value = DateTime.now();
        } catch (e) {
          print('Clock timer error: $e');
        }
      });
    } catch (e) {
      print('Start real time clock error: $e');
    }
  }


  void _setupPageTimer() {
    try {
      _pageTimer?.cancel();
      _pageTimer = Timer.periodic(Duration(seconds: 25), (timer) {
        try {
          if (!isLoading.value && errorMessage.value.isEmpty && orders.isNotEmpty) {
            if (!isInPackingDashboardCycle.value) {
              // Check if we're at the last page
              if (currentPage.value >= totalPages - 1) {
                // Show packing dashboard
                showPackingDashboard.value = true;
                isInPackingDashboardCycle.value = true;

                // Set timer to return to CT PAT dashboard after 25 seconds
                _dashboardCycleTimer?.cancel();
                _dashboardCycleTimer = Timer(Duration(seconds: 25), () {
                  showPackingDashboard.value = false;
                  isInPackingDashboardCycle.value = false;
                  currentPage.value = 0; // Start from first page
                });
              } else {
                // Move to next page
                currentPage.value++;
              }
            }
          }
        } catch (e) {
          print('Page timer error: $e');
        }
      });
    } catch (e) {
      print('Setup page timer error: $e');
    }
  }
  void toggleDashboard() {
    try {
      showPackingDashboard.value = !showPackingDashboard.value;
      if (showPackingDashboard.value) {
        isInPackingDashboardCycle.value = true;
        _dashboardCycleTimer?.cancel();
        _dashboardCycleTimer = Timer(Duration(seconds: 25), () {
          showPackingDashboard.value = false;
          isInPackingDashboardCycle.value = false;
          currentPage.value = 0;
        });
      } else {
        isInPackingDashboardCycle.value = false;
        _dashboardCycleTimer?.cancel();
      }
    } catch (e) {
      print('Toggle dashboard error: $e');
    }
  }
  // New method to update items per page based on screen size
  void updateItemsPerPage(int newItemsPerPage) {
    try {
      if (newItemsPerPage > 0 && newItemsPerPage != itemsPerPage.value) {
        final oldPage = currentPage.value;
        itemsPerPage.value = newItemsPerPage;

        // Adjust current page if needed
        if (oldPage >= totalPages) {
          currentPage.value = totalPages > 0 ? totalPages - 1 : 0;
        }
      }
    } catch (e) {
      print('Update items per page error: $e');
    }
  }

  void nextPage() {
    try {
      if (currentPage.value < totalPages - 1) {
        currentPage.value++;
      } else {
        currentPage.value = 0;
      }
    } catch (e) {
      print('Next page error: $e');
    }
  }

  void previousPage() {
    try {
      if (currentPage.value > 0) {
        currentPage.value--;
      } else {
        currentPage.value = totalPages - 1;
      }
    } catch (e) {
      print('Previous page error: $e');
    }
  }

  Future<void> fetchOrders({bool showLoader = true}) async {
    try {
      if (showLoader) {
        isLoading.value = true;
      }
      errorMessage.value = '';

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
      ).timeout(
        Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Request timeout after 10 seconds', Duration(seconds: 10));
        },
      );

      if (response.statusCode == 200) {
        try {
          final responseBody = response.body.trim();
          if (responseBody.isEmpty) {
            throw FormatException('Server returned empty response');
          }

          List<dynamic> jsonData = json.decode(responseBody);

          if (jsonData == null) {
            throw FormatException('Invalid JSON data received');
          }

          final oldPage = currentPage.value;

          // Orders কে shipping date অনুযায়ী ascending order এ sort করা
          orders.value = jsonData
              .map((item) {
            try {
              if (item == null) {
                print('Warning: Null item found in API response');
                return null;
              }
              return OrderModel.fromJson(item);
            } catch (e) {
              print('Error parsing order item: $e, Item: $item');
              return null;
            }
          })
              .where((order) => order != null)
              .cast<OrderModel>()
              .toList()
            ..sort((a, b) {
              try {
                DateTime dateA = DateTime.parse(a.shipmentDate);
                DateTime dateB = DateTime.parse(b.shipmentDate);
                return dateA.compareTo(dateB); // Ascending order (past → current → future)
              } catch (e) {
                print('Date parsing error for shipment dates: ${a.shipmentDate}, ${b.shipmentDate}');
                // যদি date parse করতে error হয় তাহলে orderID দিয়ে sort করা
                try {
                  return a.poNo.compareTo(b.poNo);
                } catch (sortError) {
                  print('OrderID comparison error: $sortError');
                  return 0;
                }
              }
            });

          lastUpdated.value = DateTime.now();
          lastDataUpdate.value = DateTime.now();

          // Restore page
          if (oldPage >= totalPages) {
            currentPage.value = totalPages > 0 ? totalPages - 1 : 0;
          } else {
            currentPage.value = oldPage;
          }

        } catch (e) {
          if (e is FormatException) {
            errorMessage.value = 'Invalid data format received from server';
          } else {
            errorMessage.value = 'Error processing server response: ${e.toString()}';
          }
          print('Response processing error: $e');
        }
      } else if (response.statusCode >= 500) {
        errorMessage.value = 'Server error (${response.statusCode}). Please try again later.';
      } else if (response.statusCode == 404) {
        errorMessage.value = 'Data not found for this unit';
      } else if (response.statusCode == 401) {
        errorMessage.value = 'Authentication failed';
      } else {
        errorMessage.value = 'Failed to load data (Status: ${response.statusCode})';
      }
    } on TimeoutException catch (e) {
      errorMessage.value = 'Request timeout. Please check your internet connection.';
      print('Fetch Orders Timeout Error: $e');
    } on SocketException catch (e) {
      errorMessage.value = 'Network error. Please check your internet connection.';
      print('Fetch Orders Socket Error: $e');
    } on FormatException catch (e) {
      errorMessage.value = 'Invalid server response format';
      print('Fetch Orders Format Error: $e');
    } on http.ClientException catch (e) {
      errorMessage.value = 'Connection failed. Please try again.';
      print('Fetch Orders HTTP Client Error: $e');
    } catch (e) {
      if (e.toString().contains('XMLHttpRequest')) {
        errorMessage.value = 'Network connection failed';
      } else {
        errorMessage.value = 'Unexpected error occurred';
      }
      print('Fetch Orders Unexpected Error: $e');
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

  List<OrderModel> get currentPageItems {
    try {
      if (orders.isEmpty) return [];
      final startIndex = currentPage.value * itemsPerPage.value;
      final endIndex = (startIndex + itemsPerPage.value).clamp(0, orders.length);
      return orders.sublist(startIndex, endIndex);
    } catch (e) {
      print('Error getting current page items: $e');
      return [];
    }
  }

  int get totalPages {
    try {
      return orders.isEmpty ? 0 : (orders.length / itemsPerPage.value).ceil();
    } catch (e) {
      print('Error calculating total pages: $e');
      return 0;
    }
  }
}

