import 'dart:async';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/order_model.dart';

class OrderController extends GetxController {
  static const String apiUrl = 'https://192.168.14.97:7023/api/Orders';

  var orders = <OrderModel>[].obs;
  var isLoading = true.obs;
  var errorMessage = ''.obs;
  var lastUpdated = DateTime.now().obs;
  var currentTime = DateTime.now().obs;
  var lastDataUpdate = DateTime.now().obs;
  var currentPage = 0.obs;
  var itemsPerPage = 16.obs;
  var unitName = 'PRODUCTION-1'.obs;

  Timer? _clockTimer;
  Timer? _dataTimer;
  Timer? _pageTimer;

  @override
  void onInit() {
    fetchOrders(showLoader: true); // first time → loader
    _setupPageTimer();
    _startRealTimeClock();

    // Auto refresh every 30 seconds without loader
    _dataTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      fetchOrders(showLoader: false);
    });

    super.onInit();
  }


  @override
  void onClose() {
    _dataTimer?.cancel();
    _pageTimer?.cancel();
    _clockTimer?.cancel();
    super.onClose();
  }

  void _startRealTimeClock() {
    _clockTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      currentTime.value = DateTime.now();
    });
  }

  void _setupPageTimer() {
    _pageTimer = Timer.periodic(Duration(seconds: 15), (timer) {
      if (!isLoading.value && errorMessage.value.isEmpty && orders.isNotEmpty) {
        currentPage.value = (currentPage.value + 1) % totalPages;
      }
    });
  }
// পেজ কন্ট্রোলের জন্য মেথড
  void nextPage() {
    if (currentPage.value < totalPages - 1) {
      currentPage.value++;
    } else {
      currentPage.value = 0; // লুপ ব্যাক
    }
  }

  void previousPage() {
    if (currentPage.value > 0) {
      currentPage.value--;
    } else {
      currentPage.value = totalPages - 1; // লাস্ট পেজে যাবে
    }
  }
  // Calculate items per page based on TV screen width
  void calculateItemsPerPage(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    int newItemsPerPage;

    // TV screen size breakpoints
    if (screenWidth >= 3840) {
      // 4K TV (3840x2160)
      newItemsPerPage = 20;
    } else if (screenWidth >= 2560) {
      // 2K/QHD TV (2560x1440)
      newItemsPerPage = 16;
    } else if (screenWidth >= 1920) {
      // Full HD TV (1920x1080)
      newItemsPerPage = 12;
    } else if (screenWidth >= 1366) {
      // HD TV (1366x768)
      newItemsPerPage = 10;
    } else if (screenWidth >= 1280) {
      // Smaller HD (1280x720)
      newItemsPerPage = 8;
    } else {
      // Small screens
      newItemsPerPage = 6;
    }

    // Also consider screen height for better optimization
    if (screenHeight <= 720) {
      newItemsPerPage = (newItemsPerPage * 0.75).round();
    } else if (screenHeight >= 2160) {
      newItemsPerPage = (newItemsPerPage * 1.25).round();
    }

    // Ensure minimum of 4 items and maximum of 25 items
    newItemsPerPage = newItemsPerPage.clamp(4, 25);

    if (itemsPerPage.value != newItemsPerPage) {
      itemsPerPage.value = newItemsPerPage;
      currentPage.value = 0; // Reset to first page when items per page changes

      print('TV Screen: ${screenWidth}x${screenHeight}, Items per page: $newItemsPerPage');
    }
  }

  // Alternative method: Calculate based on card size
  void calculateItemsPerPageByCardSize(BuildContext context, {
    double cardHeight = 80.0,
    double cardMargin = 8.0,
    double headerHeight = 120.0,
    double footerHeight = 60.0,
  }) {
    final screenHeight = MediaQuery.of(context).size.height;

    // Calculate available height for cards
    final availableHeight = screenHeight - headerHeight - footerHeight - (cardMargin * 2);

    // Calculate how many cards can fit
    final totalCardHeight = cardHeight + (cardMargin * 2);
    final fittableItems = (availableHeight / totalCardHeight).floor();

    // Ensure reasonable limits
    final newItemsPerPage = fittableItems.clamp(4, 25);

    if (itemsPerPage.value != newItemsPerPage) {
      itemsPerPage.value = newItemsPerPage;
      currentPage.value = 0;

      print('Card-based calculation: $newItemsPerPage items per page');
    }
  }

  // Enhanced method: Combine both width and card size calculations
  void optimizeForTVDisplay(BuildContext context, {
    double cardHeight = 80.0,
    double cardMargin = 8.0,
    double headerHeight = 120.0,
    double footerHeight = 60.0,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Get base items per page from screen width
    int baseItems;
    if (screenWidth >= 3840) {
      baseItems = 20;
    } else if (screenWidth >= 2560) {
      baseItems = 16;
    } else if (screenWidth >= 1920) {
      baseItems = 12;
    } else if (screenWidth >= 1366) {
      baseItems = 10;
    } else if (screenWidth >= 1280) {
      baseItems = 8;
    } else {
      baseItems = 6;
    }

    // Calculate maximum items that can fit vertically
    final availableHeight = screenHeight - headerHeight - footerHeight - (cardMargin * 2);
    final totalCardHeight = cardHeight + (cardMargin * 2);
    final maxVerticalItems = (availableHeight / totalCardHeight).floor();

    // Use the smaller of the two calculations
    final optimizedItems = [baseItems, maxVerticalItems].reduce((a, b) => a < b ? a : b);

    // Apply final constraints
    final newItemsPerPage = optimizedItems.clamp(4, 25);

    if (itemsPerPage.value != newItemsPerPage) {
      itemsPerPage.value = newItemsPerPage;
      currentPage.value = 0;

      print('TV Optimized: ${screenWidth}x${screenHeight}, Items per page: $newItemsPerPage');
      print('Base from width: $baseItems, Max vertical: $maxVerticalItems, Final: $newItemsPerPage');
    }
  }

  // Future<void> fetchOrders() async {
  //   try {
  //     isLoading.value = true;
  //     errorMessage.value = '';
  //
  //     final response = await http.get(
  //       Uri.parse(apiUrl),
  //       headers: {'Content-Type': 'application/json'},
  //     );
  //
  //     if (response.statusCode == 200) {
  //       List<dynamic> jsonData = json.decode(response.body);
  //
  //       // Sort to show latest data first (using id as timestamp proxy)
  //       orders.value = jsonData.map((item) => OrderModel.fromJson(item)).toList()
  //         ..sort((a, b) => b.id.compareTo(a.id));
  //
  //       lastUpdated.value = DateTime.now();
  //       lastDataUpdate.value = DateTime.now();
  //       currentPage.value = 0;
  //
  //       _dataTimer?.cancel();
  //       _dataTimer = Timer.periodic(Duration(seconds: 30), (timer) {
  //         fetchOrders();
  //       });
  //     } else {
  //       errorMessage.value = 'Failed to load data: ${response.statusCode}';
  //     }
  //   } catch (e) {
  //     errorMessage.value = 'Error: $e';
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }
  Future<void> fetchOrders({bool showLoader = true}) async {
    try {
      if (showLoader) {
        isLoading.value = true; // only show loader on manual/first fetch
      }
      errorMessage.value = '';

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);

        // Keep old page index
        final oldPage = currentPage.value;

        // Sort newest first
        orders.value = jsonData
            .map((item) => OrderModel.fromJson(item))
            .toList()
          ..sort((a, b) => b.id.compareTo(a.id));

        lastUpdated.value = DateTime.now();
        lastDataUpdate.value = DateTime.now();

        // Restore page
        if (oldPage >= totalPages) {
          currentPage.value = totalPages > 0 ? totalPages - 1 : 0;
        } else {
          currentPage.value = oldPage;
        }

      } else {
        errorMessage.value = 'Failed to load data: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'Error: $e';
    } finally {
      if (showLoader) {
        isLoading.value = false;
      }
    }
  }

  List<OrderModel> get currentPageItems {
    final startIndex = currentPage.value * itemsPerPage.value;
    final endIndex = (startIndex + itemsPerPage.value).clamp(0, orders.length);
    return orders.sublist(startIndex, endIndex);
  }

  int get totalPages => orders.isEmpty ? 0 : (orders.length / itemsPerPage.value).ceil();

  // Method to manually adjust items per page for different TV sizes
  void setItemsPerPageForTVSize(String tvSize) {
    switch (tvSize.toUpperCase()) {
      case '32"':
        itemsPerPage.value = 6;
        break;
      case '43"':
        itemsPerPage.value = 8;
        break;
      case '55"':
        itemsPerPage.value = 10;
        break;
      case '65"':
        itemsPerPage.value = 12;
        break;
      case '75"':
        itemsPerPage.value = 14;
        break;
      case '85"+':
        itemsPerPage.value = 16;
        break;
      default:
        itemsPerPage.value = 10;
    }
    currentPage.value = 0;
  }
}


// import 'dart:async';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import '../models/order_model.dart';
//
// class OrderController extends GetxController {
//   static const String apiUrl = 'https://192.168.14.107:7023/api/Orders';
//
//   var orders = <OrderModel>[].obs;
//   var isLoading = true.obs;
//   var errorMessage = ''.obs;
//   var lastUpdated = DateTime.now().obs;
//   var currentTime = DateTime.now().obs;
//   var lastDataUpdate = DateTime.now().obs;
//   var currentPage = 0.obs;
//  var itemsPerPage = 11.obs;
//   var unitName = 'PRODUCTION-1'.obs;
//
//   Timer? _clockTimer;
//   Timer? _dataTimer;
//   Timer? _pageTimer;
//
//   @override
//   void onInit() {
//     fetchOrders();
//     _setupPageTimer();
//     _startRealTimeClock();
//     super.onInit();
//   }
//
//   @override
//   void onClose() {
//     _dataTimer?.cancel();
//     _pageTimer?.cancel();
//     _clockTimer?.cancel();
//     super.onClose();
//   }
//
//   void _startRealTimeClock() {
//     _clockTimer = Timer.periodic(Duration(seconds: 1), (timer) {
//       currentTime.value = DateTime.now();
//     });
//   }
//
//   void _setupPageTimer() {
//     _pageTimer = Timer.periodic(Duration(seconds: 10), (timer) {
//       if (!isLoading.value && errorMessage.value.isEmpty && orders.isNotEmpty) {
//         currentPage.value = (currentPage.value + 1) % totalPages;
//       }
//     });
//   }
//
//   Future<void> fetchOrders() async {
//     try {
//       isLoading.value = true;
//       errorMessage.value = '';
//
//       final response = await http.get(
//         Uri.parse(apiUrl),
//         headers: {'Content-Type': 'application/json'},
//       );
//
//       if (response.statusCode == 200) {
//         List<dynamic> jsonData = json.decode(response.body);
//
//         // Sort to show latest data first (using id as timestamp proxy)
//         orders.value = jsonData.map((item) => OrderModel.fromJson(item)).toList()
//           ..sort((a, b) => b.id.compareTo(a.id));
//
//         lastUpdated.value = DateTime.now();
//         lastDataUpdate.value = DateTime.now();
//         currentPage.value = 0;
//
//         _dataTimer?.cancel();
//         _dataTimer = Timer.periodic(Duration(seconds: 30), (timer) {
//           fetchOrders();
//         });
//       } else {
//         errorMessage.value = 'Failed to load data: ${response.statusCode}';
//       }
//     } catch (e) {
//       errorMessage.value = 'Error: $e';
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   List<OrderModel> get currentPageItems {
//     final startIndex = currentPage.value * itemsPerPage.value;
//     final endIndex = (startIndex + itemsPerPage.value).clamp(0, orders.length);
//     return orders.sublist(startIndex, endIndex);
//   }
//
//   int get totalPages => (orders.length / itemsPerPage.value).ceil();
// }