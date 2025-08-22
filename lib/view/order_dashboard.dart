import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tv_app_order/models/unit_model.dart';
import 'package:tv_app_order/view/unit_selection_screen.dart';
import '../controller/order_controller.dart';
import '../models/order_model.dart';

class OrdersDashboard extends StatefulWidget {
  final Unit unit;

  const OrdersDashboard({super.key, required this.unit});

  @override
  State<OrdersDashboard> createState() => _OrdersDashboardState();
}

class _OrdersDashboardState extends State<OrdersDashboard> {
  late OrderController controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    try {
      Get.delete<OrderController>(force: true);
    } catch (e) {}

    controller = Get.put(OrderController(unit: widget.unit), permanent: false);
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    try {
      controller.dispose();
      Get.delete<OrderController>(force: true);
    } catch (e) {}
    _focusNode.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {


    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: FocusableActionDetector(
          focusNode: _focusNode,
          autofocus: true,
          shortcuts: {
            LogicalKeySet(LogicalKeyboardKey.goBack): const ActivateIntent(),
          },
          actions: {
            ActivateIntent: CallbackAction(
              onInvoke: (_) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UnitSelectionScreen(),
                  ),
                );
                return null;
              },
            ),
          },
          child: GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity! < 0) {
                controller.nextPage();
              } else if (details.primaryVelocity! > 0) {
                controller.previousPage();
              }
            },
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return _buildLoadingWidget(context);
                    }
                    if (controller.errorMessage.value.isNotEmpty) {
                      return _buildErrorWidget(context);
                    }
                    return _buildPagedContent(context);
                  }),
                ),
                _buildFooter(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _getResponsiveFontSize(BuildContext context, double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth / 1920;
    return (baseSize * scaleFactor).clamp(baseSize * 0.8, baseSize * 2.0);
  }

  double _getResponsivePadding(BuildContext context, double basePadding) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth / 1920;
    return (basePadding * scaleFactor).clamp(
      basePadding * 0.8,
      basePadding * 2.0,
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Obx(
          () => Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          vertical: _getResponsivePadding(context, 10),
          horizontal: _getResponsivePadding(context, 30),
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00796B), Color(0xFF4DB6AC)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 15,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'UNIT: ${widget.unit.unitName}',
              style: TextStyle(
                fontSize: _getResponsiveFontSize(context, 18),
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'CTPAT ',
              style: TextStyle(
                fontSize: _getResponsiveFontSize(context, 18),
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'Date: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}',
              style: TextStyle(
                fontSize: _getResponsiveFontSize(context, 18),
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'LIVE: ${DateFormat('HH:mm:ss').format(controller.currentTime.value)}',
              style: TextStyle(
                fontSize: _getResponsiveFontSize(context, 18),
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPagedContent(BuildContext context) {
    return Column(
      children: [
        _buildTableHeader(context),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              top: 0,
              left: _getResponsivePadding(context, 10),
              right: _getResponsivePadding(context, 10),
              bottom: 0,
            ),
            child: Obx(
                  () => ListView.builder(
                // physics: NeverScrollableScrollPhysics(),
                itemCount: controller.currentPageItems.length,
                itemBuilder: (context, index) {
                  return _buildOrderRow(
                    context,
                    controller.currentPageItems[index],
                    index,
                    controller.currentPage.value * controller.itemsPerPage.value + index + 1,
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeader(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: _getResponsivePadding(context, 10),
        left: _getResponsivePadding(context, 10),
        right: _getResponsivePadding(context, 10),
        bottom: 0,
      ),
      decoration: BoxDecoration(
        color: Colors.blueGrey[800],
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      child: Row(
        children: [
          _buildHeaderCell(context, 'SL', 0.4),
          _buildHeaderCell(context, 'Buyer', 1.3),
          _buildHeaderCell(context, 'Style', 2.2),
          _buildHeaderCell(context, 'PO', 1.5),
          _buildHeaderCell(context, 'Color', 2),
          _buildHeaderCell(context, 'Shipping Date',0.9),
          _buildHeaderCell(context, 'Destination', 1.1),
          _buildHeaderCell(context, 'OrderQty', 0.9),
          // _buildHeaderCell(context, 'Today Scan Qty', 0.9),
          // _buildHeaderCell(context, 'Total Scan Qty', 0.9),
          _buildHeaderCell(context, 'Balance Qty', 0.8),
          _buildHeaderCell(context, 'REQ.CTN', 0.9),
          _buildHeaderCell(context, 'Today Scan CTN', 0.9),
          _buildHeaderCell(context, 'Total Scan CTN', 0.9),
          _buildHeaderCell(context, 'Remain CTN to Scan', 1.1),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(BuildContext context, String text, double flex) {
    return Expanded(
      flex: (flex * 10).toInt(),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: _getResponsivePadding(context, 6),
          horizontal: _getResponsivePadding(context, 6),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            // fontSize: _getResponsiveFontSize(context, 13),
            fontSize: 16.sp,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildOrderRow(BuildContext context, OrderModel order, int index, int serialNumber) {
    final rowColor = index % 2 == 0 ? Colors.grey[850]! : Colors.grey[800]!;
    final balanceColor = double.parse(order.balanceQty) > 0
        ? Colors.red[900]!
        : Colors.green[900]!;
    final remainColor = double.parse(order.ctnPerQty) > 0
        ? Colors.orange[900]!
        : Colors.green[900]!;

    return Container(
      color: rowColor,
      child: Row(
        children: [
          _buildDataCell(context, serialNumber.toString(), 0.4, Colors.transparent), // Added index column data
          _buildDataCell(context, order.buyer, 1.3, Colors.transparent),
          _buildDataCell(context, order.style, 2.2, Colors.transparent),
          _buildDataCell(context, order.poNo, 1.5, Colors.transparent),
          _buildDataCell(context, order.color, 2, Colors.transparent),
          _buildDataCell(context, order.deliveryDate, 0.9, Colors.transparent),
          _buildDataCell(context, order.country, 1.1, Colors.transparent),
          _buildDataCell(
            context,
            order.orderQty.toString(),
            0.9,
            Colors.transparent,
          ),
          // _buildDataCell(
          //   context,
          //   order.todayPeaceFinish.toString(),
          //   0.9,
          //   Colors.transparent,
          // ),
          // _buildDataCell(
          //   context,
          //   order.todayPeaceShip.toString(),
          //   0.9,
          //   Colors.transparent,
          // ),
          _buildDataCell(
            context,
            order.balanceQty.toString(),
            0.8,
            balanceColor.withOpacity(0.7),
            textColor: Colors.white,
          ),
          _buildDataCell(
            context,
            order.ctnQty.toString(),
            0.9,
            Colors.transparent,
          ),
          _buildDataCell(
            context,
            order.todayCTNFinish.toString(),
            0.9,
            Colors.transparent,
          ),
          _buildDataCell(
            context,
            order.totalCTNFinish.toString(),
            0.9,
            Colors.transparent,
          ),
          _buildDataCell(
            context,
            order.balanceCTNQty.toString(),
            1.1,
            remainColor.withOpacity(0.7),
            textColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildDataCell(
      BuildContext context,
      String text,
      double flex,
      Color backgroundColor, {
        Color textColor = Colors.white,
      }) {
    return Expanded(
      flex: (flex * 10).toInt(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.05,
        padding: EdgeInsets.symmetric(
          vertical: _getResponsivePadding(context, 02),
          horizontal: _getResponsivePadding(context, 2),
        ),
        margin: EdgeInsets.symmetric(vertical: 1),
        decoration: BoxDecoration(color: backgroundColor),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              // fontSize: _getResponsiveFontSize(context, 12),
              fontSize: 15.sp,
              color: textColor,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Obx(
          () => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: _getResponsivePadding(context, 4),
          ),
          color: Colors.grey[900],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < controller.totalPages; i++)
                Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: _getResponsivePadding(context, 8),
                  ),
                  width: _getResponsivePadding(context, 10),
                  height: _getResponsivePadding(context, 10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i == controller.currentPage.value
                        ? Colors.blue
                        : Colors.grey[600],
                    boxShadow: i == controller.currentPage.value
                        ? [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
                        : null,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingWidget(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            strokeWidth: 6,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          SizedBox(height: _getResponsivePadding(context, 32)),
          Text(
            'Loading Production Data...',
            style: TextStyle(
              fontSize: _getResponsiveFontSize(context, 28),
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: _getResponsiveFontSize(context, 80),
            color: Colors.red,
          ),
          SizedBox(height: _getResponsivePadding(context, 32)),
          Text(
            'Connection Error',
            style: TextStyle(
              fontSize: _getResponsiveFontSize(context, 32),
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          SizedBox(height: _getResponsivePadding(context, 16)),
          Obx(
                () => Container(
              padding: EdgeInsets.symmetric(
                horizontal: _getResponsivePadding(context, 48),
              ),
              child: Text(
                controller.errorMessage.value,
                style: TextStyle(
                  fontSize: _getResponsiveFontSize(context, 20),
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(height: _getResponsivePadding(context, 32)),
          ElevatedButton(
            onPressed: () => controller.fetchOrders(),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: _getResponsivePadding(context, 48),
                vertical: _getResponsivePadding(context, 20),
              ),
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'RETRY',
              style: TextStyle(
                fontSize: _getResponsiveFontSize(context, 20),
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}