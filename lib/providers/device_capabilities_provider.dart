import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:light/light.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';

class DeviceCapabilitiesProvider with ChangeNotifier {
  // Connectivity
  ConnectivityResult _connectivityResult = ConnectivityResult.none;
  bool _isConnected = false;

  // Location
  Position? _currentPosition;
  bool _locationPermissionGranted = false;

  // Battery
  int _batteryLevel = 0;
  BatteryState _batteryState = BatteryState.unknown;

  // Sensors
  double _accelerometerX = 0.0;
  double _accelerometerY = 0.0;
  double _accelerometerZ = 0.0;

  double _gyroscopeX = 0.0;
  double _gyroscopeY = 0.0;
  double _gyroscopeZ = 0.0;

  // Light sensor
  double _lightLevel = 0.0;

  // Contacts
  int _contactCount = 0;
  bool _contactsPermissionGranted = false;

  // Getters
  ConnectivityResult get connectivityResult => _connectivityResult;
  bool get isConnected => _isConnected;
  Position? get currentPosition => _currentPosition;
  bool get locationPermissionGranted => _locationPermissionGranted;
  int get batteryLevel => _batteryLevel;
  BatteryState get batteryState => _batteryState;
  double get accelerometerX => _accelerometerX;
  double get accelerometerY => _accelerometerY;
  double get accelerometerZ => _accelerometerZ;
  double get gyroscopeX => _gyroscopeX;
  double get gyroscopeY => _gyroscopeY;
  double get gyroscopeZ => _gyroscopeZ;
  double get lightLevel => _lightLevel;
  int get contactCount => _contactCount;
  bool get contactsPermissionGranted => _contactsPermissionGranted;

  String get connectivityStatus {
    switch (_connectivityResult) {
      case ConnectivityResult.wifi:
        return 'WiFi';
      case ConnectivityResult.mobile:
        return 'Mobile Data';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.bluetooth:
        return 'Bluetooth';
      case ConnectivityResult.vpn:
        return 'VPN';
      case ConnectivityResult.other:
        return 'Other';
      case ConnectivityResult.none:
        return 'No Connection';
    }
  }

  String get batteryStatusText {
    switch (_batteryState) {
      case BatteryState.charging:
        return 'Charging ($_batteryLevel%)';
      case BatteryState.discharging:
        return 'Discharging ($_batteryLevel%)';
      case BatteryState.full:
        return 'Full (100%)';
      case BatteryState.unknown:
        return 'Unknown ($_batteryLevel%)';
    }
  }

  // Stream subscriptions
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;
  StreamSubscription<int>? _lightSubscription;

  void initialize() {
    _initializeConnectivity();
    _initializeBattery();
    _initializeSensors();
    _initializeLightSensor();
    _requestPermissions();
  }

  void _initializeConnectivity() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
      _connectivityResult = result;
      _isConnected = result != ConnectivityResult.none;
      notifyListeners();
    });

    // Get initial connectivity state
    Connectivity().checkConnectivity().then((result) {
      _connectivityResult = result;
      _isConnected = result != ConnectivityResult.none;
      notifyListeners();
    });
  }

  void _initializeBattery() {
    final battery = Battery();

    // Get initial battery level
    battery.batteryLevel.then((level) {
      _batteryLevel = level;
      notifyListeners();
    });

    // Get initial battery state
    battery.batteryState.then((state) {
      _batteryState = state;
      notifyListeners();
    });

    // Listen to battery changes
    battery.onBatteryStateChanged.listen((state) {
      _batteryState = state;
      notifyListeners();
    });
  }

  void _initializeSensors() {
    _accelerometerSubscription = accelerometerEventStream().listen((event) {
      _accelerometerX = event.x;
      _accelerometerY = event.y;
      _accelerometerZ = event.z;
      notifyListeners();
    });

    _gyroscopeSubscription = gyroscopeEventStream().listen((event) {
      _gyroscopeX = event.x;
      _gyroscopeY = event.y;
      _gyroscopeZ = event.z;
      notifyListeners();
    });
  }

  void _initializeLightSensor() {
    try {
      Light light = Light();
      _lightSubscription = light.lightSensorStream.listen((lux) {
        _lightLevel = lux.toDouble();
        notifyListeners();
      });
    } catch (e) {
      debugPrint('Light sensor not available: $e');
    }
  }

  Future<void> _requestPermissions() async {
    // Request location permission
    try {
      final locationPermission = await Permission.location.request();
      _locationPermissionGranted = locationPermission.isGranted;

      if (_locationPermissionGranted) {
        await _getCurrentLocation();
      }
    } catch (e) {
      debugPrint('Location permission error: $e');
    }

    // Request contacts permission
    try {
      final contactsPermission = await Permission.contacts.request();
      _contactsPermissionGranted = contactsPermission.isGranted;

      if (_contactsPermissionGranted) {
        await _getContactCount();
      }
    } catch (e) {
      debugPrint('Contacts permission error: $e');
    }

    notifyListeners();
  }

  Future<void> _getCurrentLocation() async {
    try {
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  Future<void> _getContactCount() async {
    try {
      final contacts = await ContactsService.getContacts();
      _contactCount = contacts.length;
      notifyListeners();
    } catch (e) {
      debugPrint('Error getting contacts: $e');
    }
  }

  Future<void> refreshLocation() async {
    if (_locationPermissionGranted) {
      await _getCurrentLocation();
    }
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _accelerometerSubscription?.cancel();
    _gyroscopeSubscription?.cancel();
    _lightSubscription?.cancel();
    super.dispose();
  }
}
