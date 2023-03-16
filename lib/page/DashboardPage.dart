// ignore_for_file: prefer_const_literals_to_create_immutables, avoid_unnecessary_containers, curly_braces_in_flow_control_structures, unrelated_type_equality_checks

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isoja_application/global/color.dart';
import 'package:isoja_application/page/selectbonded.dart';
import 'package:isoja_application/page/ScanPage.dart';
import 'package:isoja_application/widget/Appbar.dart';
import 'package:ripple_wave/ripple_wave.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';

// import './helpers/LineChart.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPage createState() => new _DashboardPage();
}

class _DashboardPage extends State<DashboardPage> {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  String _address = "...";
  String _name = "...";

  Timer? _discoverableTimeoutTimer;
  int _discoverableTimeoutSecondsLeft = 0;

  // BackgroundCollectingTask? _collectingTask;

  bool _autoAcceptPairingRequests = false;
  bool enableSwitch = false;
  bool enablePair = false;

  @override
  void initState() {
    super.initState();
    try {
      FlutterBluetoothSerial.instance.state.then((state) {
        setState(() {
          _bluetoothState = state;
        });
      });

      Future.doWhile(() async {
        // Wait if adapter not enabled
        if ((await FlutterBluetoothSerial.instance.isEnabled) ?? false) {
          return false;
        }
        await Future.delayed(const Duration(milliseconds: 0xDD));
        return true;
      }).then((_) {
        // Update the address field
        FlutterBluetoothSerial.instance.address.then((address) {
          setState(() {
            _address = address!;
          });
        });
      });

      FlutterBluetoothSerial.instance.name.then((name) {
        setState(() {
          _name = name!;
        });
      });

      // Listen for futher state changes
      FlutterBluetoothSerial.instance
          .onStateChanged()
          .listen((BluetoothState state) {
        setState(() {
          _bluetoothState = state;
          _discoverableTimeoutTimer = null;
          _discoverableTimeoutSecondsLeft = 0;
        });
      });
    } catch (e) {
      print(e);
    }
  }

  goToSettings() => FlutterBluetoothSerial.instance.openSettings();

  @override
  void dispose() {
    try {
      FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
      _discoverableTimeoutTimer?.cancel();
      super.dispose();
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
        backgroundColor: base,
        appBar: DashboardAppbar(),
        body: Container(
          child: Column(
            children: [
              Expanded(
                  child: SizedBox(
                width: width,
                height: 20,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 18.0),
                  padding: const EdgeInsets.symmetric(vertical: 22.0),
                  width: width,
                  height: width / 10,
                  child: Container(
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      color: bgColor,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Enable Bluetooth",
                                style: GoogleFonts.inter(
                                  fontSize: 16.0,
                                  color: base,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              FlutterSwitch(
                                activeToggleColor: bgColor,
                                toggleColor: bgColor,
                                activeColor: base,
                                inactiveColor: bg,
                                width: width * 0.12,
                                height: width * 0.07,
                                value: _bluetoothState.isEnabled,
                                onToggle: (bool value) {
                                  try {
                                    future() async {
                                      if (value)
                                        await FlutterBluetoothSerial.instance
                                            .requestEnable();
                                      else
                                        await FlutterBluetoothSerial.instance
                                            .requestDisable();
                                    }

                                    future().then((_) {
                                      setState(() {});
                                    });
                                  } catch (e) {
                                    print(e);
                                  }
                                },
                              ),
                            ]),
                      ),
                    ),
                  ),
                ),
              )),
              Expanded(
                  flex: 3,
                  child: Container(
                      child: RippleAnimation(
                    color: _bluetoothState.isEnabled ? bg : base,
                    delay: const Duration(milliseconds: 300),
                    repeat: true,
                    minRadius: 85,
                    ripplesCount: 4,
                    duration: const Duration(seconds: 3),
                    child: InkWell(
                      hoverColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      onTap: () {
                        if (_bluetoothState.isEnabled) {
                          goToSettings();
                        } else {
                          print('e');
                        }
                      },
                      child: CircleAvatar(
                        backgroundColor:
                            _bluetoothState.isEnabled ? bgColor : bg,
                        minRadius: 85,
                        maxRadius: 85,
                        child: Icon(
                          Icons.bluetooth,
                          size: 100.0,
                          color: base,
                        ),
                      ),
                    ),
                  ))),
              Expanded(
                  flex: 3,
                  child: Container(
                    color: base,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(22.0),
                            topRight: Radius.circular(22.0),
                          ),
                          child: Container(
                            height: width / 1.5,
                            color: bgColor,
                            child: Container(
                              margin: const EdgeInsets.all(20.0),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Device Name",
                                            style: GoogleFonts.inter(
                                              color: textColor,
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            _name,
                                            style: GoogleFonts.inter(
                                              color: base,
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Device Address",
                                            style: GoogleFonts.inter(
                                              color: textColor,
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            _address,
                                            style: GoogleFonts.inter(
                                              color: base,
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        enablePair = !enablePair;
                                      });
                                    },
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Auto Pairing",
                                            style: GoogleFonts.inter(
                                              fontSize: 16.0,
                                              color: base,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          FlutterSwitch(
                                            activeToggleColor: bgColor,
                                            toggleColor: bgColor,
                                            activeColor: base,
                                            inactiveColor: bg,
                                            width: width * 0.12,
                                            height: width * 0.07,
                                            value: _autoAcceptPairingRequests,
                                            onToggle: (bool value) {
                                              try {
                                                setState(() {
                                                  _autoAcceptPairingRequests =
                                                      value;
                                                });
                                                if (value) {
                                                  FlutterBluetoothSerial
                                                      .instance
                                                      .setPairingRequestHandler(
                                                          (BluetoothPairingRequest
                                                              request) {
                                                    print(
                                                        "Trying to auto-pair with Pin 1234");
                                                    if (request
                                                            .pairingVariant ==
                                                        PairingVariant.Pin) {
                                                      return Future.value(
                                                          "1234");
                                                    }
                                                    return Future.value(null);
                                                  });
                                                } else {
                                                  FlutterBluetoothSerial
                                                      .instance
                                                      .setPairingRequestHandler(
                                                          null);
                                                }
                                              } catch (e) {
                                                print(e);
                                              }
                                            },
                                          ),
                                        ]),
                                  ),
                                  InkWell(
                                    onTap: () async {
                                      try {
                                        final BluetoothDevice? selectedDevice =
                                            await Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) {
                                              return ScanPage();
                                            },
                                          ),
                                        );

                                        if (selectedDevice != null) {
                                          print('Discovery -> selected ' +
                                              selectedDevice.address);
                                        } else {
                                          print(
                                              'Discovery -> no device selected');
                                        }
                                      } catch (e) {
                                        print(e);
                                      }
                                    },
                                    child: Container(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Scan Devices",
                                            style: GoogleFonts.inter(
                                              color: base,
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const Icon(
                                            Icons.arrow_forward,
                                            size: 24.0,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        primary: base,
                                      ),
                                      onPressed: () async {
                                        try {
                                          final BluetoothDevice?
                                              selectedDevice =
                                              await Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) {
                                                return SelectBondedDevicePage(
                                                    checkAvailability: false);
                                              },
                                            ),
                                          );
                                        } catch (e) {
                                          print(e);
                                        }
                                      },
                                      child: Container(
                                        child: Text(
                                          "Connect",
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.bold,
                                            color: bgColor,
                                            fontSize: 16.0,
                                          ),
                                        ),
                                      ))
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ))
            ],
          ),
        ));
  }
}


// Container(
//         child: ListView(
//           children: <Widget>[
//             Divider(),
//             SwitchListTile(
//               title: const Text('Enable Bluetooth'),
//               value: _bluetoothState.isEnabled,
//               onChanged: (bool value) {
//                 try {
//                   future() async {
//                     if (value)
//                       await FlutterBluetoothSerial.instance.requestEnable();
//                     else
//                       await FlutterBluetoothSerial.instance.requestDisable();
//                   }

//                   future().then((_) {
//                     setState(() {});
//                   });
//                 } catch (e) {
//                   print(e);
//                 }
//               },
//             ),
//             ListTile(
//               title: const Text('Bluetooth status'),
//               subtitle: Text(_bluetoothState.toString()),
//               trailing: ElevatedButton(
//                 child: const Text('Settings'),
//                 onPressed: () {
//                   FlutterBluetoothSerial.instance.openSettings();
//                 },
//               ),
//             ),
//             ListTile(
//               title: const Text('Local adapter address'),
//               subtitle: Text(_address),
//             ),
//             ListTile(
//               title: const Text('Local adapter name'),
//               subtitle: Text(_name),
//               onLongPress: null,
//             ),
//             Divider(),
//             ListTile(title: const Text('Devices discovery and connection')),
//             SwitchListTile(
//               title: const Text('Auto-try specific pin when pairing'),
//               subtitle: const Text('Pin 1234'),
//               value: _autoAcceptPairingRequests,
//               onChanged: (bool value) {
//                 try {
//                   setState(() {
//                     _autoAcceptPairingRequests = value;
//                   });
//                   if (value) {
//                     FlutterBluetoothSerial.instance.setPairingRequestHandler(
//                         (BluetoothPairingRequest request) {
//                       print("Trying to auto-pair with Pin 1234");
//                       if (request.pairingVariant == PairingVariant.Pin) {
//                         return Future.value("1234");
//                       }
//                       return Future.value(null);
//                     });
//                   } else {
//                     FlutterBluetoothSerial.instance
//                         .setPairingRequestHandler(null);
//                   }
//                 } catch (e) {
//                   print(e);
//                 }
//               },
//             ),
//             ListTile(
//               title: ElevatedButton(
//                   child: const Text('Explore discovered devices'),
//                   onPressed: () async {
//                     try {
//                       final BluetoothDevice? selectedDevice =
//                           await Navigator.of(context).push(
//                         MaterialPageRoute(
//                           builder: (context) {
//                             return ScanPage();
//                           },
//                         ),
//                       );

//                       if (selectedDevice != null) {
//                         print(
//                             'Discovery -> selected ' + selectedDevice.address);
//                       } else {
//                         print('Discovery -> no device selected');
//                       }
//                     } catch (e) {
//                       print(e);
//                     }
//                   }),
//             ),
//             ListTile(
//               title: ElevatedButton(
//                 child: const Text('Connect to paired device to chat'),
//                 onPressed: () async {
//                   try {
//                     final BluetoothDevice? selectedDevice =
//                         await Navigator.of(context).push(
//                       MaterialPageRoute(
//                         builder: (context) {
//                           return SelectBondedDevicePage(
//                               checkAvailability: false);
//                         },
//                       ),
//                     );
//                   } catch (e) {
//                     print(e);
//                   }
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),