import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'controller/order_controller.dart';
import 'models/order_model.dart';

class OrdersDashboard extends StatelessWidget {
  final OrderController controller = Get.put(OrderController());

  OrdersDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: GestureDetector(
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity! < 0) {
              controller.nextPage();
            }
            // ডানে সোয়াইপ → আগের পেজ
            else if (details.primaryVelocity! > 0) {
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
    );
  }

  // Get responsive sizes based on screen dimensions
  double _getResponsiveFontSize(BuildContext context, double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth / 1920; // Base on 1920px width (typical TV)
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
            colors: [
              Color(0xFF00796B), // Dark teal
              Color(0xFF4DB6AC), // Light teal
            ],
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
          children: [

            Text(
              'UNIT: ${controller.unitName.value}',
              style: TextStyle(
                fontSize: _getResponsiveFontSize(context, 22),
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'CTPAT ',
              style: TextStyle(
                fontSize: _getResponsiveFontSize(context, 22),
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
            'Date: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}',
              style: TextStyle(
                fontSize: _getResponsiveFontSize(context, 22),
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'LIVE: ${DateFormat('HH:mm:ss').format(controller.currentTime.value)}',
              style: TextStyle(
                fontSize: _getResponsiveFontSize(context, 22),
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
                physics: NeverScrollableScrollPhysics(),
                itemCount: controller.currentPageItems.length,
                itemBuilder: (context, index) {
                  return _buildOrderRow(
                    context,
                    controller.currentPageItems[index],
                    index,
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
          _buildHeaderCell(context, 'Buyer', 1.3),
          _buildHeaderCell(context, 'Style', 2),
          _buildHeaderCell(context, 'PO', 1.5),
          _buildHeaderCell(context, 'Color', 1.5),
          _buildHeaderCell(context, 'Destination', 1.1),
          _buildHeaderCell(context, 'OrderQty', 0.9),
          _buildHeaderCell(context, 'Today Scan Qty', 0.9),
          _buildHeaderCell(context, 'Total Scan Qty', 0.9),
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
          vertical: _getResponsivePadding(context, 10),
          horizontal: _getResponsivePadding(context, 6),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: _getResponsiveFontSize(context, 14),
            color: Colors.white,
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildOrderRow(BuildContext context, OrderModel order, int index) {
    final rowColor = index % 2 == 0 ? Colors.grey[850]! : Colors.grey[800]!;
    final balanceColor =
        order.balance > 0 ? Colors.red[900]! : Colors.green[900]!;
    final remainColor =
        order.remainCtnToScan > 0 ? Colors.orange[900]! : Colors.green[900]!;

    return Container(
      color: rowColor,
      child: Row(
        children: [
          _buildDataCell(context, order.buyer, 1.3, Colors.transparent),
          _buildDataCell(
            context,
            _truncateText(order.style, 20),
            2,
            Colors.transparent,
          ),
          _buildDataCell(
            context,
            _truncateText(order.po, 20),
            1.5,
            Colors.transparent,
          ),
          _buildDataCell(
            context,
            _truncateText(order.color, 20),
            1.5,
            Colors.transparent,
          ),
          _buildDataCell(context, order.destination, 1.1, Colors.transparent),
          _buildDataCell(
            context,
            order.orderQty.toString(),
            0.9,
            Colors.transparent,
          ),
          _buildDataCell(
            context,
            order.todayScanQty.toString(),
            0.9,
            // Colors.blueGrey[900]!,
            Colors.transparent
          ),
          _buildDataCell(
            context,
            order.totalScanQty.toString(),
            0.9,
            // Colors.blueGrey[900]!,
            Colors.transparent,
          ),
          _buildDataCell(
            context,
            order.balance.toString(),
            0.8,
            balanceColor.withOpacity(0.7),
            textColor: Colors.white,
          ),
          _buildDataCell(
            context,
            order.reqCtn.toString(),
            0.9,
            Colors.transparent,
          ),
          _buildDataCell(
            context,
            order.todayScanCtn.toString(),
            0.9,
            // Colors.blueGrey[900]!,
              Colors.transparent
          ),
          _buildDataCell(
            context,
            order.totalScanCtn.toString(),
            0.9,
            // Colors.blueGrey[900]!,
              Colors.transparent
          ),
          _buildDataCell(
            context,
            order.remainCtnToScan.toString(),
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
      flex: (flex *10).toInt(),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: _getResponsivePadding(context, 10),
          horizontal: _getResponsivePadding(context, 6),
        ),
        margin: EdgeInsets.symmetric(vertical: 1),
        decoration: BoxDecoration(color: backgroundColor),
        child: Text(
          text,
          style: TextStyle(
            fontSize: _getResponsiveFontSize(context, 13),
            color: textColor,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
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
            vertical: _getResponsivePadding(context, 8),
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
                  width: _getResponsivePadding(context, 16),
                  height: _getResponsivePadding(context, 16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        i == controller.currentPage.value
                            ? Colors.blue
                            : Colors.grey[600],
                    boxShadow:
                        i == controller.currentPage.value
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
            child: Text(
              'RETRY',
              style: TextStyle(
                fontSize: _getResponsiveFontSize(context, 20),
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
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
          ),
        ],
      ),
    );
  }

  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
}
