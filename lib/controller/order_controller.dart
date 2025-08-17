import 'dart:async';
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
  var itemsPerPage = 20.obs;
  var unitName = ''.obs;

  Timer? _clockTimer;
  Timer? _dataTimer;
  Timer? _pageTimer;

  @override
  void onInit() {
    super.onInit();
    orders.clear();
    isLoading.value = true;
    errorMessage.value = '';
    currentPage.value = 0;
    unitName.value = unit.unitName;

    fetchOrders(showLoader: true);
    _setupPageTimer();
    _startRealTimeClock();
    _dataTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      fetchOrders(showLoader: false);
    });
  }

  @override
  void onClose() {
    _dataTimer?.cancel();
    _pageTimer?.cancel();
    _clockTimer?.cancel();
    orders.clear();

    super.onClose();
  }

  @override
  void dispose() {
    super.dispose();
    _dataTimer?.cancel();
    _pageTimer?.cancel();
    _clockTimer?.cancel();
    orders.clear();
    isLoading.value = false;
    errorMessage.value = '';
    currentPage.value = 0;
  }

  void _startRealTimeClock() {
    _clockTimer?.cancel();
    _clockTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      currentTime.value = DateTime.now();
    });
  }

  void _setupPageTimer() {
    _pageTimer?.cancel();
    _pageTimer = Timer.periodic(Duration(seconds: 15), (timer) {
      if (!isLoading.value && errorMessage.value.isEmpty && orders.isNotEmpty) {
        currentPage.value = (currentPage.value + 1) % totalPages;
      }
    });
  }

  void nextPage() {
    if (currentPage.value < totalPages - 1) {
      currentPage.value++;
    } else {
      currentPage.value = 0;
    }
  }

  void previousPage() {
    if (currentPage.value > 0) {
      currentPage.value--;
    } else {
      currentPage.value = totalPages - 1;
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
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        final oldPage = currentPage.value;
        orders.value = jsonData
            .map((item) => OrderModel.fromJson(item))
            .toList()
          ..sort((a, b) => b.orderID.compareTo(a.orderID));

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
      print('Fetch Orders Error: $e');
    } finally {
      if (showLoader) {
        isLoading.value = false;
      }
    }
  }

  List<OrderModel> get currentPageItems {
    if (orders.isEmpty) return [];
    final startIndex = currentPage.value * itemsPerPage.value;
    final endIndex = (startIndex + itemsPerPage.value).clamp(0, orders.length);
    return orders.sublist(startIndex, endIndex);
  }

  int get totalPages => orders.isEmpty ? 0 : (orders.length / itemsPerPage.value).ceil();

}
