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
      backgroundColor: Color(0xFF263238),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topCenter,
              radius: 1.5,
              colors: [Color(0xFF263238).withOpacity(0.3), Color(0xFF37474F)], // Changed from very dark to medium dark
            ),
          ),
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
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Obx(
          () => Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          vertical: _getResponsivePadding(context, 4),
          horizontal: _getResponsivePadding(context, 30),
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF263238).withOpacity(0.3), Color(0xFF37474F)], // Changed from dark purples to bright blues
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.7),
              blurRadius: 20,
              offset: Offset(0, 10),
              spreadRadius: 2,
            ),
          ],
          border: Border(
            bottom: BorderSide(
              color: Colors.blueAccent.withOpacity(0.3),
              width: 2,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'UNIT: ${widget.unit.unitName}',
              style: TextStyle(
                fontSize: _getResponsiveFontSize(context, 20),
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 4,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
            ),
            Text(
              'CT PAT ',
              style: TextStyle(
                fontSize: _getResponsiveFontSize(context, 18),
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              'Date: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}',
              style: TextStyle(
                fontSize: _getResponsiveFontSize(context, 18),
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 4,
                    offset: Offset(1, 1),
                  ),
                ],
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
                    controller.currentPage.value *
                        controller.itemsPerPage.value +
                        index +
                        1,
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
        top: _getResponsivePadding(context, 3),
        left: _getResponsivePadding(context, 10),
        right: _getResponsivePadding(context, 10),
        bottom: 0,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF37474F), Color(0xFF546E7A)], // Brighter grays
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        border: Border.all(color: Color(0xFF06B6D4).withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF06B6D4).withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildHeaderCell(context, 'SL', 0.4),
          _buildHeaderCell(context, 'Buyer', 1.3),
          _buildHeaderCell(context, 'Style', 2.2),
          _buildHeaderCell(context, 'PO', 1.5),
          _buildHeaderCell(context, 'Color', 2),
          _buildHeaderCell(context, 'Inspection Offer Date', 0.9),
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
            fontSize: 17.sp,
            // color: Color(0xFF06B6D4),
            color:Colors.white,
            letterSpacing: 0.5,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.8), // Stronger shadow
                blurRadius: 6,
                offset: Offset(2, 2),
              ),
            ],
          ),
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildOrderRow(
      BuildContext context,
      OrderModel order,
      int index,
      int serialNumber,
      ) {
    final rowColor = index % 2 == 0
        ? Color(0xFF37474F).withOpacity(0.9) // Brighter gray
        : Color(0xFF455A64).withOpacity(0.9);

    final balanceColor = double.parse(order.balanceQty) > 0
        ? Colors.red
        : Color(0xFF10B981);

    final remainColor = double.parse(order.balanceCTNQty) > 0
        ? Color(0xFFF59E0B)
        : Color(0xFF10B981);

    return Container(
      decoration: BoxDecoration(
        color: rowColor,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFF06B6D4).withOpacity(0.1),
            width: 0.5,
          ),
        ),
      ),
      child: Row(

        children: [
          _buildDataCell(
              context,
              serialNumber.toString(),
              0.4,
              Colors.transparent,
              fontSize: 16.sp
          ),
          _buildDataCell(context, order.buyer, 1.3, Colors.transparent,fontSize: 16.sp),
          _buildDataCell(context, order.style, 2.2, Colors.transparent,fontSize: 16.sp),
          _buildDataCell(context, order.poNo, 1.5, Colors.transparent,fontSize: 16.sp),
          _buildDataCell(context, order.color, 2, Colors.transparent,fontSize: 16.sp),
          _buildDataCell(
              context,
              _formatShippingDate(order.shipmentDate),
              0.9,
              _getShippingDateBackgroundColor(order.shipmentDate),
              textColor: Colors.white,
              hasBorder:
              _getShippingDateBackgroundColor(order.shipmentDate) !=
                  Colors.transparent,
              borderColor: _getShippingDateColor(order.shipmentDate),
              fontWeight: FontWeight.bold,
              fontSize: 16.sp
          ),
          _buildDataCell(context, order.country, 1.1, Colors.transparent,fontSize: 16.sp),
          _buildDataCell(
              context,
              order.orderQty.toString(),
              0.9,
              Colors.transparent,
              fontSize: 16.sp
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
              balanceColor.withOpacity(0.3),
              textColor: Colors.white,
              hasBorder: true,
              borderColor: balanceColor,
              fontWeight: FontWeight.bold,
              fontSize: 16.sp
          ),
          _buildDataCell(
              context,
              order.ctnQty.toString(),
              0.9,
              Colors.transparent,
              fontSize: 16.sp
          ),
          _buildDataCell(
              context,
              order.todayCTNFinish.toString(),
              0.9,
              Colors.transparent,
              fontSize: 16.sp
          ),
          _buildDataCell(
              context,
              order.totalCTNFinish.toString(),
              0.9,
              Colors.transparent,
              fontSize: 16.sp
          ),
          _buildDataCell(
              context,
              order.balanceCTNQty.toString(),
              1.1,
              remainColor.withOpacity(0.3),
              textColor: Colors.white,
              hasBorder: true,
              borderColor: remainColor,
              fontWeight: FontWeight.bold,
              fontSize: 16.sp
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
        bool hasBorder = false,
        Color? borderColor,
        FontWeight fontWeight = FontWeight.w600, // 🔑 default w600, changeable
        double? fontSize,
      }) {
    return Expanded(
      flex: (flex * 10).toInt(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.0499,
        padding: EdgeInsets.symmetric(
          vertical: _getResponsivePadding(context, 01),
          horizontal: _getResponsivePadding(context, 2),
        ),
        margin: EdgeInsets.symmetric(vertical: 1),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: hasBorder ? BorderRadius.circular(4) : null,
          border: hasBorder && borderColor != null
              ? Border.all(color: borderColor.withOpacity(0.5), width: 1)
              : null,
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: fontSize ?? 15.sp,
              color: textColor,
              fontWeight: fontWeight, // 🔑 now configurable
              letterSpacing: 0.3,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.8), // Stronger shadow
                  blurRadius: 3,
                  offset: Offset(1, 1),
                ),
              ],
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
          () => Container(
        padding: EdgeInsets.symmetric(
          vertical: _getResponsivePadding(context, 3),
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF37474F),
              Color(0xFF546E7A).withOpacity(0.8),
              Color(0xFF37474F),
            ],
          ),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < controller.totalPages; i++)
                Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: _getResponsivePadding(context, 6),
                  ),
                  width: _getResponsivePadding(context, 12),
                  height: _getResponsivePadding(context, 12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: i == controller.currentPage.value
                        ? LinearGradient(
                      colors: [Color(0xFF06B6D4), Color(0xFF8B5CF6)],
                    )
                        : null,
                    color: i != controller.currentPage.value
                        ? Color(0xFF374151)
                        : null,
                    border: Border.all(
                      color: Color(0xFF06B6D4).withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: i == controller.currentPage.value
                        ? [
                      BoxShadow(
                        color: Color(0xFF06B6D4).withOpacity(0.4),
                        blurRadius: 12,
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
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF06B6D4), Color(0xFF8B5CF6)],
              ),
            ),
            child: CircularProgressIndicator(
              strokeWidth: 6,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              backgroundColor: Colors.transparent,
            ),
          ),
          SizedBox(height: _getResponsivePadding(context, 32)),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: LinearGradient(
                colors: [
                  Color(0xFF06B6D4).withOpacity(0.1),
                  Color(0xFF8B5CF6).withOpacity(0.1),
                ],
              ),
              border: Border.all(color: Color(0xFF06B6D4).withOpacity(0.3)),
            ),
            child: Text(
              'Loading Production Data...',
              style: TextStyle(
                fontSize: _getResponsiveFontSize(context, 28),
                color: Color(0xFF06B6D4),
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
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
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFFEF4444), Color(0xFFF97316)],
              ),
            ),
            child: Icon(
              Icons.error_outline,
              size: _getResponsiveFontSize(context, 60),
              color: Colors.white,
            ),
          ),
          SizedBox(height: _getResponsivePadding(context, 32)),
          Text(
            'Connection Error',
            style: TextStyle(
              fontSize: _getResponsiveFontSize(context, 32),
              fontWeight: FontWeight.bold,
              color: Color(0xFFEF4444),
            ),
          ),
          SizedBox(height: _getResponsivePadding(context, 16)),
          Obx(
                () => Container(
              padding: EdgeInsets.symmetric(
                horizontal: _getResponsivePadding(context, 48),
                vertical: _getResponsivePadding(context, 16),
              ),
              margin: EdgeInsets.symmetric(horizontal: 40),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Color(0xFFEF4444).withOpacity(0.1),
                border: Border.all(color: Color(0xFFEF4444).withOpacity(0.3)),
              ),
              child: Text(
                controller.errorMessage.value,
                style: TextStyle(
                  fontSize: _getResponsiveFontSize(context, 20),
                  color: Color(0xFFF1F5F9),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(height: _getResponsivePadding(context, 32)),
          ElevatedButton(
            onPressed: () => controller.fetchOrders(),
            style:
            ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: _getResponsivePadding(context, 48),
                vertical: _getResponsivePadding(context, 20),
              ),
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ).copyWith(
              backgroundColor: WidgetStateProperty.all(Colors.transparent),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF06B6D4), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Text(
                'RETRY',
                style: TextStyle(
                  fontSize: _getResponsiveFontSize(context, 20),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatShippingDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);

      return DateFormat('dd-MMM').format(date);
    } catch (e) {
      return dateString;
    }
  }

  Color _getShippingDateColor(String dateString) {
    try {
      DateTime shippingDate = DateTime.parse(dateString);
      DateTime currentDate = DateTime.now();

      DateTime shippingDateOnly = DateTime(
        shippingDate.year,
        shippingDate.month,
        shippingDate.day,
      );
      DateTime currentDateOnly = DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day,
      );

      // if (shippingDateOnly.isBefore(currentDateOnly)) {
      //
      //   return Color(0xFFEF4444); // Red
      // }
      //
      // else if (shippingDateOnly.isAtSameMomentAs(currentDateOnly)) {
      //
      //   return Color(0xFFEF4444); // Red
      // }
      //
      // else {
      //
      //   if (_isNearestUpcomingDate(dateString)) {
      //
      //     return Color(0xFFF97316);
      //   } else {
      //
      //     return Color(0xFFF1F5F9);
      //   }
      // }

      if (shippingDateOnly.isBefore(currentDateOnly)) {
        return Color(0xFFE53E3E); // Brighter red
      }
      else if (shippingDateOnly.isAtSameMomentAs(currentDateOnly)) {
        return Color(0xFFE53E3E); // Brighter red
      }
      else {
        if (_isNearestUpcomingDate(dateString)) {
          return Color(0xFFED8936); // Brighter orange
        } else {
          return Colors.white; // Pure white
        }
      }
    } catch (e) {

      return Color(0xFFF1F5F9);
    }
  }

  Color _getShippingDateBackgroundColor(String dateString) {
    try {
      DateTime shippingDate = DateTime.parse(dateString);
      DateTime currentDate = DateTime.now();

      DateTime shippingDateOnly = DateTime(
        shippingDate.year,
        shippingDate.month,
        shippingDate.day,
      );
      DateTime currentDateOnly = DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day,
      );

      int daysDifference = shippingDateOnly.difference(currentDateOnly).inDays;


      if (daysDifference <= 0) {
        return Color(0xFFEF4444).withOpacity(0.2);
      }

      else {
        if (_isNearestUpcomingDate(dateString)) {
          return Color(0xFFF97316).withOpacity(0.2);
        } else {
          return Color(0xFFF1F5F9).withOpacity(0.2);
        }
      }
    } catch (e) {
      return Colors.transparent;
    }
  }

  bool _isNearestUpcomingDate(String dateString) {
    try {
      DateTime currentDate = DateTime.now();
      DateTime currentDateOnly = DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day,
      );

      DateTime targetDate = DateTime.parse(dateString);
      DateTime targetDateOnly = DateTime(
        targetDate.year,
        targetDate.month,
        targetDate.day,
      );

      // যদি target date past বা current হয় তাহলে false
      if (targetDateOnly.isBefore(currentDateOnly) ||
          targetDateOnly.isAtSameMomentAs(currentDateOnly)) {
        return false;
      }

      // সব orders থেকে সবচেয়ে কাছের future date খুঁজে বের করা (যে কোন month/year হোক না কেন)
      DateTime? nearestDate;
      int minDifference = 999999;

      // Current page এর সব orders check করা
      for (OrderModel order in controller.currentPageItems) {
        try {
          DateTime orderDate = DateTime.parse(order.shipmentDate);
          DateTime orderDateOnly = DateTime(
            orderDate.year,
            orderDate.month,
            orderDate.day,
          );

          // শুধুমাত্র future dates consider করা (যে কোন month/year এ থাকুক)
          if (orderDateOnly.isAfter(currentDateOnly)) {
            int difference = orderDateOnly.difference(currentDateOnly).inDays;
            if (difference < minDifference) {
              minDifference = difference;
              nearestDate = orderDateOnly;
            }
          }
        } catch (e) {
          continue;
        }
      }

      // All orders থেকেও check করা যদি আছে (global nearest date)
      if (controller.orders.isNotEmpty) {
        for (OrderModel order in controller.orders) {
          try {
            DateTime orderDate = DateTime.parse(order.shipmentDate);
            DateTime orderDateOnly = DateTime(
              orderDate.year,
              orderDate.month,
              orderDate.day,
            );

            // শুধুমাত্র future dates consider করা
            if (orderDateOnly.isAfter(currentDateOnly)) {
              int difference = orderDateOnly.difference(currentDateOnly).inDays;
              if (difference < minDifference) {
                minDifference = difference;
                nearestDate = orderDateOnly;
              }
            }
          } catch (e) {
            continue;
          }
        }
      }

      // target date টি nearest upcoming date কিনা check করা
      return nearestDate != null &&
          targetDateOnly.isAtSameMomentAs(nearestDate);
    } catch (e) {
      return false;
    }
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
}
