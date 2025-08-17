import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../models/unit_model.dart';
import 'order_dashboard.dart';

class UnitSelectionScreen extends StatefulWidget {
  @override
  _UnitSelectionScreenState createState() => _UnitSelectionScreenState();
}

class _UnitSelectionScreenState extends State<UnitSelectionScreen> {
  Unit? selectedUnit;
  final FocusNode _gridFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  List<Unit> units = [];
  bool isLoadingUnits = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchUnits();
  }

  @override
  void dispose() {
    _gridFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> fetchUnits() async {
    setState(() {
      isLoadingUnits = true;
      errorMessage = null;
      selectedUnit = null;
      units.clear();
    });

    try {
      final response = await http.get(
        Uri.parse('http://apps.bitopibd.com:8090/bimobapiv2/api/FinishingBarcode/GetUnitData'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(Duration(seconds: 30), onTimeout: () {
        throw Exception('Server is not responding. Please check your internet connection or try again later.');
      });

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        setState(() {
          units = jsonData.map((json) => Unit.fromJson(json)).toList();
          isLoadingUnits = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load units. Status: ${response.statusCode}';
          isLoadingUnits = false;
        });
      }
    } on Exception catch (e) {
      setState(() {
        errorMessage = 'Error: ${e.toString().replaceAll('Exception: ', '')}';
        isLoadingUnits = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: RawKeyboardListener(
        focusNode: FocusNode(),
        autofocus: true,
        onKey: _handleKeyPress,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blue.shade900, Colors.black87],
            ),
          ),
          child: Center(
            child: Container(
              padding: EdgeInsets.all(20),
              constraints: BoxConstraints(maxWidth: 1000),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Unit Selection',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),

                  // Unit GridView
                  Focus(
                    focusNode: _gridFocusNode,
                    child: Container(
                      height: 300,
                      child: _buildUnitGrid(),
                    ),
                  ),

                  SizedBox(height: 20),

                  // Instructions
                  Text(
                    'Use arrow keys to navigate, Enter to select',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUnitGrid() {
    if (isLoadingUnits) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (units.isEmpty) {
      return Center(
        child: Text(
          errorMessage ?? 'No units available',
          style: TextStyle(color: Colors.white70, fontSize: 18),
        ),
      );
    }

    return GridView.builder(
      controller: _scrollController,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: units.length,
      itemBuilder: (context, index) {
        final unit = units[index];
        final isSelected = selectedUnit?.unitID == unit.unitID;

        return Focus(
          onFocusChange: (hasFocus) {
            if (hasFocus) {
              setState(() {
                selectedUnit = unit;
              });
              // Auto-navigate when focused (for remote control)
              Future.delayed(Duration(milliseconds: 300), () {
                if (selectedUnit?.unitID == unit.unitID) {
                  _navigateToDashboard(unit);
                }
              });
            }
          },
          child: Card(
            color: isSelected ? Colors.blue.shade800 : Colors.grey.shade800,
            child: InkWell(
              onTap: () => _navigateToDashboard(unit),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        unit.unitName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'ID: ${unit.unitID}',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleKeyPress(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowDown:
          _moveSelectionInGrid(3); // Move down (3 columns)
          break;
        case LogicalKeyboardKey.arrowUp:
          _moveSelectionInGrid(-3); // Move up (3 columns)
          break;
        case LogicalKeyboardKey.arrowLeft:
          _moveSelectionInGrid(-1); // Move left
          break;
        case LogicalKeyboardKey.arrowRight:
          _moveSelectionInGrid(1); // Move right
          break;
        case LogicalKeyboardKey.enter:
        case LogicalKeyboardKey.select:
          if (selectedUnit != null) {
            _navigateToDashboard(selectedUnit!);
          }
          break;
      }
    }
  }

  void _moveSelectionInGrid(int offset) {
    if (units.isEmpty) return;

    final currentIndex = selectedUnit != null
        ? units.indexOf(selectedUnit!)
        : 0;

    var newIndex = currentIndex + offset;

    // Boundary checks
    if (newIndex < 0) newIndex = 0;
    if (newIndex >= units.length) newIndex = units.length - 1;

    if (newIndex != currentIndex) {
      setState(() {
        selectedUnit = units[newIndex];
      });

      // Calculate scroll position
      final row = (newIndex / 3).floor(); // Assuming 3 columns
      final itemHeight = 100; // Approximate height of each item
      final scrollPosition = row * itemHeight;

      // Animate scroll
      _scrollController.animateTo(
        scrollPosition.toDouble(),
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _navigateToDashboard(Unit unit) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrdersDashboard(unit: unit),
      ),
    );
  }
}