import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:intl/intl.dart';
import '../../controller/packing_production_controller.dart';
import '../../models/unit_model.dart';

class PackingProductionDashboard extends StatefulWidget {
  final Unit unit;

  const PackingProductionDashboard({super.key, required this.unit});

  @override
  State<PackingProductionDashboard> createState() =>
      _PackingProductionDashboardState();
}

class _PackingProductionDashboardState
    extends State<PackingProductionDashboard> {
  late PackingProductionController controller;

  @override
  void initState() {
    super.initState();
    try {
      Get.delete<PackingProductionController>(force: true);
    } catch (e) {}

    controller = Get.put(
        PackingProductionController(unit: widget.unit),
        permanent: false);
  }

  @override
  void dispose() {
    try {
      controller.dispose();
      Get.delete<PackingProductionController>(force: true);
    } catch (e) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingWidget();
        }
        if (controller.errorMessage.value.isNotEmpty) {
          return _buildErrorWidget();
        }
        return _buildDashboardContent(context);
      }),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red),
          SizedBox(height: 16),
          Text(
            controller.errorMessage.value,
            style: TextStyle(fontSize: 16, color: Colors.red),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => controller.fetchData(),
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Column(
              children: [
                // Top Panel - Hourly Production Chart
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: EdgeInsets.only(bottom: 8),
                    padding: EdgeInsets.only(
                        left: 20, right: 20, top: 5, bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Obx(() {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Running Day (${controller.runningDayDate}) - Hourly Production',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.yellow,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Total: ${NumberFormat('#,###').format(controller.hourlyTotal.toInt())}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Expanded(
                            child: controller.hourlyScanData.isEmpty
                                ? Center(child: Text('No hourly data available'))
                                : CustomLineChart(
                                    data: controller.hourlyDataList,
                                    labels: controller.hourlyLabels,
                                  ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),

                // Bottom Panel - Daily Production Chart
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: EdgeInsets.only(top: 0),
                    padding: EdgeInsets.only(
                        left: 20, right: 20, top: 5, bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Obx(() {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Day-wise ${widget.unit.unitName} Packing Production (${controller.dailyDateRange})',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              Container(
                                width: 400,
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Colors.green[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${widget.unit.unitName} Summary (${controller.dailyDateRange}):',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                            'Total: ${NumberFormat('#,###').format(controller.dailyTotal.toInt())}',
                                            style: TextStyle(fontSize: 12)),
                                        Text(
                                            'Daily Average: ${NumberFormat('#,###').format(controller.dailyAverage.toInt())}',
                                            style: TextStyle(fontSize: 12)),
                                        Text(
                                            'Highest: ${NumberFormat('#,###').format(controller.dailyHighest.toInt())}',
                                            style: TextStyle(fontSize: 12)),
                                        Text(
                                            'Lowest: ${NumberFormat('#,###').format(controller.dailyLowest.toInt())}',
                                            style: TextStyle(fontSize: 12)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Expanded(
                            child: controller.dailyScanData.isEmpty
                                ? Center(child: Text('No daily data available'))
                                : CustomBarChart(
                                    data: controller.dailyDataList,
                                    labels: controller.dailyLabels,
                                  ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CustomLineChart extends StatelessWidget {
  final List<double> data;
  final List<String> labels;

  const CustomLineChart({super.key, required this.data, required this.labels});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: LineChartPainter(data, labels),
      child: Container(),
    );
  }
}

class LineChartPainter extends CustomPainter {
  final List<double> data;
  final List<String> labels;

  LineChartPainter(this.data, this.labels);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final pointPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 1;

    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: ui.TextDirection.ltr,
    );

    const topPadding = 10.0;
    const bottomPadding = 40.0;
    const leftPadding = 50.0;
    const rightPadding = 20.0;

    final chartWidth = size.width - leftPadding - rightPadding;
    final chartHeight = size.height - topPadding - bottomPadding;

    // Dynamic data range
    final maxValue = data.reduce((a, b) => a > b ? a : b) * 1.1;
    final minValue = (data.reduce((a, b) => a < b ? a : b) * 0.9).clamp(0.0, double.infinity);

    final startOffset = 15.0;

    // Horizontal grid lines
    for (int i = 0; i <= 4; i++) {
      final y = topPadding + (chartHeight * i / 4);
      canvas.drawLine(
        Offset(leftPadding, y),
        Offset(size.width - rightPadding, y),
        gridPaint,
      );
    }

    // Axes
    final axisPaint = Paint()
      ..color = Colors.grey[600]!
      ..strokeWidth = 2;

    canvas.drawLine(
      Offset(leftPadding, topPadding),
      Offset(leftPadding, size.height - bottomPadding),
      axisPaint,
    );
    canvas.drawLine(
      Offset(leftPadding, size.height - bottomPadding),
      Offset(size.width - rightPadding, size.height - bottomPadding),
      axisPaint,
    );

    // Vertical grid lines aligned with points
    for (int i = 0; i < labels.length; i++) {
      final x = leftPadding +
          startOffset +
          (chartWidth - startOffset) * i / (labels.length - 1);
      canvas.drawLine(
        Offset(x, topPadding),
        Offset(x, size.height - bottomPadding),
        gridPaint,
      );
    }

    // Y-axis labels
    for (int i = 0; i <= 4; i++) {
      final value = maxValue - (i * (maxValue - minValue) / 4);
      final y = topPadding + (chartHeight * i / 4);

      textPainter.text = TextSpan(
        text: value.toInt().toString(),
        style: TextStyle(color: Colors.black, fontSize: 12),
      );
      textPainter.layout();
      textPainter.paint(
          canvas, Offset(leftPadding - 35, y - textPainter.height / 2));
    }

    // X-axis labels
    for (int i = 0; i < labels.length; i++) {
      final x = leftPadding +
          startOffset +
          (chartWidth - startOffset) * i / (labels.length - 1);

      textPainter.text = TextSpan(
        text: labels[i],
        style: TextStyle(color: Colors.black, fontSize: 12),
      );
      textPainter.layout();
      textPainter.paint(canvas,
          Offset(x - textPainter.width / 2, size.height - bottomPadding + 10));
    }

    // Draw line and points
    final path = Path();
    final points = <Offset>[];

    for (int i = 0; i < data.length; i++) {
      final x = leftPadding +
          startOffset +
          (chartWidth - startOffset) * i / (data.length - 1);
      final y = size.height -
          bottomPadding -
          ((data[i] - minValue) / (maxValue - minValue) * chartHeight);
      points.add(Offset(x, y));

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Draw points with value labels inside a container
    for (int i = 0; i < points.length; i++) {
      canvas.drawCircle(points[i], 6, pointPaint);

      final valueText = data[i].toInt().toString();
      textPainter.text = TextSpan(
        text: valueText,
        style: TextStyle(
            color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold),
      );
      textPainter.layout();

      final rectWidth = textPainter.width + 8;
      final rectHeight = textPainter.height + 4;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          points[i].dx - rectWidth / 2,
          points[i].dy - rectHeight - 12,
          rectWidth,
          rectHeight,
        ),
        Radius.circular(6),
      );

      final containerPaint = Paint()..color = Colors.white;
      canvas.drawRRect(rect, containerPaint);

      final borderPaint = Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawRRect(rect, borderPaint);

      textPainter.paint(
          canvas,
          Offset(points[i].dx - textPainter.width / 2,
              points[i].dy - rectHeight - 12 + 2));
    }

    // Axis titles
    textPainter.text = TextSpan(
      text: 'Hours',
      style:
          TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
    );
    textPainter.layout();
    textPainter.paint(canvas,
        Offset(size.width / 2 - textPainter.width / 2, size.height - 10));

    canvas.save();
    canvas.translate(-10, size.height / 2);
    canvas.rotate(-math.pi / 2);
    textPainter.text = TextSpan(
      text: 'Production Quantity',
      style:
          TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(-textPainter.width / 2, 0));
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class CustomBarChart extends StatelessWidget {
  final List<double> data;
  final List<String> labels;

  const CustomBarChart({super.key, required this.data, required this.labels});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: BarChartPainter(data, labels),
      child: Container(),
    );
  }
}

class BarChartPainter extends CustomPainter {
  final List<double> data;
  final List<String> labels;

  BarChartPainter(this.data, this.labels);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final barPaint = Paint()
      ..color = Colors.green[400]!
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 1;

    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: ui.TextDirection.ltr,
    );

    const topPadding = 10.0;
    const bottomPadding = 25.0;
    const leftPadding = 50.0;
    const rightPadding = 20.0;

    final chartWidth = size.width - leftPadding - rightPadding;
    final chartHeight = size.height - topPadding - bottomPadding;

    // Dynamic max value
    final maxValue = (data.reduce((a, b) => a > b ? a : b) * 1.2).ceilToDouble();
    final barWidth = chartWidth / data.length * 0.6;

    // Horizontal grid lines
    for (int i = 0; i <= 6; i++) {
      final y = topPadding + (chartHeight * i / 6);
      canvas.drawLine(
        Offset(leftPadding, y),
        Offset(size.width - rightPadding, y),
        gridPaint,
      );
    }

    // Draw axes
    final axisPaint = Paint()
      ..color = Colors.grey[600]!
      ..strokeWidth = 2;

    canvas.drawLine(
      Offset(leftPadding, topPadding),
      Offset(leftPadding, size.height - bottomPadding),
      axisPaint,
    );
    canvas.drawLine(
      Offset(leftPadding, size.height - bottomPadding),
      Offset(size.width - rightPadding, size.height - bottomPadding),
      axisPaint,
    );

    // Draw y-axis labels
    for (int i = 0; i <= 6; i++) {
      final value = maxValue - (i * maxValue / 6);
      final y = topPadding + (chartHeight * i / 6);

      textPainter.text = TextSpan(
        text: '${value.toInt()}K',
        style: TextStyle(color: Colors.black, fontSize: 12),
      );
      textPainter.layout();
      textPainter.paint(
          canvas, Offset(leftPadding - 35, y - textPainter.height / 2));
    }

    // Draw bars with value labels
    for (int i = 0; i < data.length; i++) {
      final x = leftPadding +
          (chartWidth * (i + 0.5) / data.length) -
          barWidth / 2;
      final barHeight = (data[i] / maxValue) * chartHeight;
      final y = size.height - bottomPadding - barHeight;

      // Draw bar
      canvas.drawRect(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        barPaint,
      );

      // Draw value label on top of bar
      textPainter.text = TextSpan(
        text: '${data[i].toStringAsFixed(1)}K',
        style: TextStyle(
            color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(
        x + barWidth / 2 - textPainter.width / 2,
        y - 18,
      ));

      // Draw x-axis label (rotated)
      canvas.save();
      final labelX = x + barWidth / 2;
      canvas.translate(labelX, size.height - bottomPadding + 5);
      canvas.rotate(math.pi / 4);
      textPainter.text = TextSpan(
        text: labels[i],
        style: TextStyle(color: Colors.black, fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(0, 0));
      canvas.restore();
    }

    // Axis titles
    textPainter.text = TextSpan(
      text: 'Date',
      style:
          TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
    );
    textPainter.layout();
    textPainter.paint(canvas,
        Offset(size.width / 2 - textPainter.width / 2, size.height - bottomPadding + 30));

    // Y-axis title (rotated)
    canvas.save();
    canvas.translate(-18, size.height / 2);
    canvas.rotate(-math.pi / 2);
    textPainter.text = TextSpan(
      text: 'Production Quantity',
      style:
          TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(-textPainter.width / 2, 0));
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
