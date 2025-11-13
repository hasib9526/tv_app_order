import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../models/unit_model.dart';
import 'order_dashboard.dart';

class UnitSelectionScreen extends StatefulWidget {
  const UnitSelectionScreen({super.key});

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
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
    try {
      fetchUnits();
    } catch (e) {
      print('InitState error: $e');
      setState(() {
        errorMessage = 'Initialization error occurred';
        isLoadingUnits = false;
      });
    }
  }

  @override
  void dispose() {
    try {
      _gridFocusNode.dispose();
      _scrollController.dispose();
    } catch (e) {
      print('Dispose error: $e');
    }
    super.dispose();
  }

  Future<void> fetchUnits() async {
    try {
      setState(() {
        isLoadingUnits = true;
        errorMessage = null;
        selectedUnit = null;
        units.clear();
      });

      final response = await http
          .get(
        Uri.parse(
          'http://apps.bitopibd.com:8090/bimobapiv2/api/FinishingBarcode/GetUnitData',
        ),
        headers: {'Content-Type': 'application/json'},
      )
          .timeout(
        Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException(
            'Server is not responding. Please check your internet connection or try again later.',
            Duration(seconds: 30),
          );
        },
      );

      if (response.statusCode == 200) {
        try {
          final responseBody = response.body.trim();
          if (responseBody.isEmpty) {
            throw FormatException('Server returned empty response');
          }

          final List<dynamic> jsonData = json.decode(responseBody);

          if (jsonData == null) {
            throw FormatException('Invalid JSON data received');
          }

          final List<Unit> parsedUnits = [];
          for (int i = 0; i < jsonData.length; i++) {
            try {
              final unitData = jsonData[i];
              if (unitData != null) {
                parsedUnits.add(Unit.fromJson(unitData));
              } else {
                print('Warning: Null unit data at index $i');
              }
            } catch (e) {
              print('Error parsing unit at index $i: $e, Data: ${jsonData[i]}');
              // Continue with other units even if one fails
            }
          }

          if (mounted) {
            setState(() {
              units = parsedUnits;
              isLoadingUnits = false;
              if (units.isEmpty) {
                errorMessage = 'No valid units found';
              }
            });
          }
        } catch (e) {
          if (mounted) {
            setState(() {
              if (e is FormatException) {
                errorMessage = 'Invalid data format received from server';
              } else {
                errorMessage = 'Error processing server response';
              }
              isLoadingUnits = false;
            });
          }
          print('Response processing error: $e');
        }
      } else if (response.statusCode >= 500) {
        if (mounted) {
          setState(() {
            errorMessage = 'Server error (${response.statusCode}). Please try again later.';
            isLoadingUnits = false;
          });
        }
      } else if (response.statusCode == 404) {
        if (mounted) {
          setState(() {
            errorMessage = 'Unit data service not found';
            isLoadingUnits = false;
          });
        }
      } else if (response.statusCode == 401) {
        if (mounted) {
          setState(() {
            errorMessage = 'Authentication failed';
            isLoadingUnits = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            errorMessage = 'Failed to load units. Status: ${response.statusCode}';
            isLoadingUnits = false;
          });
        }
      }
    } on TimeoutException catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Request timeout. Please check your internet connection or try again later.';
          isLoadingUnits = false;
        });
      }
      print('Timeout error: $e');
    } on SocketException catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Network error. Please check your internet connection.';
          isLoadingUnits = false;
        });
      }
      print('Socket error: $e');
    } on FormatException catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Invalid server response format';
          isLoadingUnits = false;
        });
      }
      print('Format error: $e');
    } on http.ClientException catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Connection failed. Please try again.';
          isLoadingUnits = false;
        });
      }
      print('HTTP Client error: $e');
    } catch (e) {
      if (mounted) {
        setState(() {
          if (e.toString().contains('XMLHttpRequest')) {
            errorMessage = 'Network connection failed';
          } else {
            errorMessage = 'An unexpected error occurred';
          }
          isLoadingUnits = false;
        });
      }
      print('Unexpected error: $e');
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

                  Focus(
                    focusNode: _gridFocusNode,
                    child: Container(height: 300, child: _buildUnitGrid()),
                  ),

                  SizedBox(height: 20),

                  Text(
                    'Use arrow keys to navigate, Enter to select',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),

                  // Add retry button when there's an error
                  if (errorMessage != null && !isLoadingUnits) ...[
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: fetchUnits,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Retry'),
                    ),
                  ],
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
          textAlign: TextAlign.center,
        ),
      );
    }

    try {
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
          try {
            final unit = units[index];
            final isSelected = selectedUnit?.unitID == unit.unitID;

            return Focus(
              onFocusChange: (hasFocus) {
                try {
                  if (hasFocus) {
                    setState(() {
                      selectedUnit = unit;
                    });
                    Future.delayed(Duration(milliseconds: 300), () {
                      try {
                        if (selectedUnit?.unitID == unit.unitID && mounted) {
                          _navigateToDashboard(unit);
                        }
                      } catch (e) {
                        print('Navigation delay error: $e');
                      }
                    });
                  }
                } catch (e) {
                  print('Focus change error: $e');
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
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          } catch (e) {
            print('Error building unit item at index $index: $e');
            return Container(
              child: Card(
                color: Colors.red.shade800,
                child: Center(
                  child: Text(
                    'Error loading unit',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ),
            );
          }
        },
      );
    } catch (e) {
      print('Error building unit grid: $e');
      return Center(
        child: Text(
          'Error displaying units',
          style: TextStyle(color: Colors.white70, fontSize: 18),
        ),
      );
    }
  }

  void _handleKeyPress(RawKeyEvent event) {
    try {
      if (event is RawKeyDownEvent) {
        switch (event.logicalKey) {
          case LogicalKeyboardKey.arrowDown:
            _moveSelectionInGrid(3);
            break;
          case LogicalKeyboardKey.arrowUp:
            _moveSelectionInGrid(-3);
            break;
          case LogicalKeyboardKey.arrowLeft:
            _moveSelectionInGrid(-1);
            break;
          case LogicalKeyboardKey.arrowRight:
            _moveSelectionInGrid(1);
            break;
          case LogicalKeyboardKey.enter:
          case LogicalKeyboardKey.select:
            if (selectedUnit != null) {
              _navigateToDashboard(selectedUnit!);
            }
            break;
        }
      }
    } catch (e) {
      print('Key press handling error: $e');
    }
  }

  void _moveSelectionInGrid(int offset) {
    try {
      if (units.isEmpty) return;

      final currentIndex = selectedUnit != null
          ? units.indexOf(selectedUnit!)
          : 0;

      var newIndex = currentIndex + offset;

      if (newIndex < 0) newIndex = 0;
      if (newIndex >= units.length) newIndex = units.length - 1;

      if (newIndex != currentIndex) {
        setState(() {
          selectedUnit = units[newIndex];
        });

        try {
          final row = (newIndex / 3).floor();
          final itemHeight = 100;
          final scrollPosition = row * itemHeight;

          _scrollController.animateTo(
            scrollPosition.toDouble(),
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        } catch (e) {
          print('Scroll animation error: $e');
        }
      }
    } catch (e) {
      print('Move selection error: $e');
    }
  }

  void _navigateToDashboard(Unit unit) {
    try {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => OrdersDashboard(unit: unit)),
        ).catchError((error) {
          print('Navigation error: $error');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to open dashboard'),
                backgroundColor: Colors.red,
              ),
            );
          }
        });
      }
    } catch (e) {
      print('Navigate to dashboard error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Navigation failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}



// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import '../models/unit_model.dart';
// import 'order_dashboard.dart';
//
// class UnitSelectionScreen extends StatefulWidget {
//   const UnitSelectionScreen({super.key});
//
//   @override
//   _UnitSelectionScreenState createState() => _UnitSelectionScreenState();
// }
//
// class _UnitSelectionScreenState extends State<UnitSelectionScreen> {
//   Unit? selectedUnit;
//   final FocusNode _gridFocusNode = FocusNode();
//   final ScrollController _scrollController = ScrollController();
//
//   List<Unit> units = [];
//   bool isLoadingUnits = false;
//   String? errorMessage;
//
//   @override
//   void initState() {
//     super.initState();
//     fetchUnits();
//   }
//
//   @override
//   void dispose() {
//     _gridFocusNode.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }
//
//   Future<void> fetchUnits() async {
//     setState(() {
//       isLoadingUnits = true;
//       errorMessage = null;
//       selectedUnit = null;
//       units.clear();
//     });
//
//     try {
//       final response = await http
//           .get(
//             Uri.parse(
//               'http://apps.bitopibd.com:8090/bimobapiv2/api/FinishingBarcode/GetUnitData',
//             ),
//             headers: {'Content-Type': 'application/json'},
//           )
//           .timeout(
//             Duration(seconds: 30),
//             onTimeout: () {
//               throw Exception(
//                 'Server is not responding. Please check your internet connection or try again later.',
//               );
//             },
//           );
//
//       if (response.statusCode == 200) {
//         final List<dynamic> jsonData = json.decode(response.body);
//         setState(() {
//           units = jsonData.map((json) => Unit.fromJson(json)).toList();
//           isLoadingUnits = false;
//         });
//       } else {
//         setState(() {
//           errorMessage = 'Failed to load units. Status: ${response.statusCode}';
//           isLoadingUnits = false;
//         });
//       }
//     } on Exception catch (e) {
//       setState(() {
//         errorMessage = 'Error: ${e.toString().replaceAll('Exception: ', '')}';
//         isLoadingUnits = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black87,
//       body: RawKeyboardListener(
//         focusNode: FocusNode(),
//         autofocus: true,
//         onKey: _handleKeyPress,
//         child: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//               colors: [Colors.blue.shade900, Colors.black87],
//             ),
//           ),
//           child: Center(
//             child: Container(
//               padding: EdgeInsets.all(20),
//               constraints: BoxConstraints(maxWidth: 1000),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     'Unit Selection',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 32,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   SizedBox(height: 20),
//
//                   Focus(
//                     focusNode: _gridFocusNode,
//                     child: Container(height: 300, child: _buildUnitGrid()),
//                   ),
//
//                   SizedBox(height: 20),
//
//                   Text(
//                     'Use arrow keys to navigate, Enter to select',
//                     style: TextStyle(color: Colors.white70, fontSize: 16),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildUnitGrid() {
//     if (isLoadingUnits) {
//       return Center(
//         child: CircularProgressIndicator(
//           valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//         ),
//       );
//     }
//
//     if (units.isEmpty) {
//       return Center(
//         child: Text(
//           errorMessage ?? 'No units available',
//           style: TextStyle(color: Colors.white70, fontSize: 18),
//         ),
//       );
//     }
//
//     return GridView.builder(
//       controller: _scrollController,
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 3,
//         childAspectRatio: 3,
//         crossAxisSpacing: 10,
//         mainAxisSpacing: 10,
//       ),
//       itemCount: units.length,
//       itemBuilder: (context, index) {
//         final unit = units[index];
//         final isSelected = selectedUnit?.unitID == unit.unitID;
//
//         return Focus(
//           onFocusChange: (hasFocus) {
//             if (hasFocus) {
//               setState(() {
//                 selectedUnit = unit;
//               });
//               Future.delayed(Duration(milliseconds: 300), () {
//                 if (selectedUnit?.unitID == unit.unitID) {
//                   _navigateToDashboard(unit);
//                 }
//               });
//             }
//           },
//           child: Card(
//             color: isSelected ? Colors.blue.shade800 : Colors.grey.shade800,
//             child: InkWell(
//               onTap: () => _navigateToDashboard(unit),
//               child: Center(
//                 child: Padding(
//                   padding: EdgeInsets.all(8),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Text(
//                         unit.unitName,
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                       Text(
//                         'ID: ${unit.unitID}',
//                         style: TextStyle(color: Colors.white70, fontSize: 12),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   void _handleKeyPress(RawKeyEvent event) {
//     if (event is RawKeyDownEvent) {
//       switch (event.logicalKey) {
//         case LogicalKeyboardKey.arrowDown:
//           _moveSelectionInGrid(3);
//           break;
//         case LogicalKeyboardKey.arrowUp:
//           _moveSelectionInGrid(-3);
//           break;
//         case LogicalKeyboardKey.arrowLeft:
//           _moveSelectionInGrid(-1);
//           break;
//         case LogicalKeyboardKey.arrowRight:
//           _moveSelectionInGrid(1);
//           break;
//         case LogicalKeyboardKey.enter:
//         case LogicalKeyboardKey.select:
//           if (selectedUnit != null) {
//             _navigateToDashboard(selectedUnit!);
//           }
//           break;
//       }
//     }
//   }
//
//   void _moveSelectionInGrid(int offset) {
//     if (units.isEmpty) return;
//
//     final currentIndex = selectedUnit != null
//         ? units.indexOf(selectedUnit!)
//         : 0;
//
//     var newIndex = currentIndex + offset;
//
//     if (newIndex < 0) newIndex = 0;
//     if (newIndex >= units.length) newIndex = units.length - 1;
//
//     if (newIndex != currentIndex) {
//       setState(() {
//         selectedUnit = units[newIndex];
//       });
//
//       final row = (newIndex / 3).floor();
//       final itemHeight = 100;
//       final scrollPosition = row * itemHeight;
//
//       _scrollController.animateTo(
//         scrollPosition.toDouble(),
//         duration: Duration(milliseconds: 300),
//         curve: Curves.easeInOut,
//       );
//     }
//   }
//
//   void _navigateToDashboard(Unit unit) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => OrdersDashboard(unit: unit)),
//     );
//   }
// }
