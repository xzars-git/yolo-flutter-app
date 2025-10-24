import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer.dart';
import 'package:flutter_bluetooth_printer_platform_interface/flutter_bluetooth_printer_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Bluetooth Printer Service with Auto-Connect Feature
///
/// This service manages Bluetooth printer connections with automatic reconnection
/// to the user's selected default printer.
///
/// Features:
/// - Auto-connect to last selected printer on app start
/// - Persistent printer selection using SharedPreferences
/// - Real-time connection status updates via ChangeNotifier
/// - Discovery and device listing
///
/// Usage:
/// ```dart
/// // Get service instance
/// final printerService = BluetoothPrinterService();
///
/// // Listen to changes
/// ListenableBuilder(
///   listenable: printerService,
///   builder: (context, child) {
///     return Text(printerService.isConnected ? 'Connected' : 'Disconnected');
///   },
/// )
///
/// // Connect to a device (becomes default printer)
/// await printerService.connectToDevice(deviceAddress);
///
/// // Forget default printer
/// await printerService.forgetDevice();
/// ```
class BluetoothPrinterService extends ChangeNotifier {
  static final BluetoothPrinterService _instance = BluetoothPrinterService._internal();
  factory BluetoothPrinterService() => _instance;
  BluetoothPrinterService._internal();

  BluetoothDevice? _selectedDevice;
  bool _isConnected = false;
  bool _isDiscovering = false;
  bool _isAutoConnecting = false; // New: track auto-connect state
  List<BluetoothDevice> _discoveredDevices = [];
  String? _errorMessage;
  StreamSubscription? _discoverySubscription;

  BluetoothDevice? get selectedDevice => _selectedDevice;
  bool get isConnected => _isConnected;
  bool get isDiscovering => _isDiscovering;
  bool get isAutoConnecting => _isAutoConnecting; // New getter
  List<BluetoothDevice> get discoveredDevices => _discoveredDevices;
  String? get errorMessage => _errorMessage;
  String? get address => _selectedDevice?.address;

  static const String _savedDeviceAddressKey = 'saved_printer_address';
  static const String _savedDeviceNameKey = 'saved_printer_name';

  /// Initialize service and try to auto-connect to last saved device
  Future<void> initialize() async {
    await _loadSavedDevice();
    _listenToDiscovery();

    // If we have a saved device, wait for discovery to find it
    if (_selectedDevice != null) {
      debugPrint('📱 Found saved device: ${_selectedDevice?.name}');
      debugPrint('🔍 Waiting for discovery to find the device...');
      // Discovery stream will auto-connect when device is found
    } else {
      debugPrint('ℹ️ No saved device found');
    }
  }

  /// Load saved device from SharedPreferences
  Future<void> _loadSavedDevice() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedAddress = prefs.getString(_savedDeviceAddressKey);
      final savedName = prefs.getString(_savedDeviceNameKey);

      if (savedAddress != null) {
        // Create a simple device reference without type
        // The actual device details will be updated when discovered
        _selectedDevice = BluetoothDevice(
          name: savedName,
          address: savedAddress,
          type: 0, // Default type as int
        );
        notifyListeners();
        debugPrint('Loaded saved device: ${_selectedDevice?.name} (${_selectedDevice?.address})');
      }
    } catch (e) {
      debugPrint('Error loading saved device: $e');
    }
  }

  /// Save device to SharedPreferences
  Future<void> _saveDevice(BluetoothDevice device) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_savedDeviceAddressKey, device.address);
      await prefs.setString(_savedDeviceNameKey, device.name ?? 'Unknown');
      debugPrint('Saved device: ${device.name} (${device.address})');
    } catch (e) {
      debugPrint('Error saving device: $e');
    }
  }

  /// Clear saved device from SharedPreferences
  Future<void> _clearSavedDevice() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_savedDeviceAddressKey);
      await prefs.remove(_savedDeviceNameKey);
      debugPrint('Cleared saved device');
    } catch (e) {
      debugPrint('Error clearing saved device: $e');
    }
  }

  /// Listen to discovery stream
  void _listenToDiscovery() {
    _discoverySubscription?.cancel();
    _discoverySubscription = FlutterBluetoothPrinter.discovery.listen(
      (result) {
        if (result is DiscoveryResult) {
          _discoveredDevices = result.devices;
          _isDiscovering = false;
          _errorMessage = null;
          notifyListeners();

          debugPrint('📡 Discovered ${_discoveredDevices.length} devices');

          // Auto-connect to saved device if found during discovery and not yet connected
          if (_selectedDevice != null && !_isConnected && !_isAutoConnecting) {
            final savedDevice = _discoveredDevices.firstWhere(
              (device) => device.address == _selectedDevice!.address,
              orElse: () => BluetoothDevice(name: null, address: '', type: 0),
            );

            if (savedDevice.address.isNotEmpty) {
              debugPrint('✅ Found saved device in discovery: ${savedDevice.name}');
              _isAutoConnecting = true;
              notifyListeners();

              // Connect to the discovered device
              connectToDevice(savedDevice.address).then((success) {
                _isAutoConnecting = false;
                if (success) {
                  debugPrint('🎉 Auto-connect successful!');
                } else {
                  debugPrint('❌ Auto-connect failed');
                }
                notifyListeners();
              });
            } else {
              debugPrint('⚠️ Saved device not found in current discovery');
            }
          }
        }
      },
      onError: (error) {
        _errorMessage = error.toString();
        _isDiscovering = false;
        _isAutoConnecting = false;
        notifyListeners();
        debugPrint('❌ Discovery error: $error');
      },
    );
  }

  /// Connect to a device
  Future<bool> connectToDevice(String address) async {
    try {
      _errorMessage = null;
      debugPrint('🔄 Attempting to connect to device: $address');

      final isConnect = await FlutterBluetoothPrinter.connect(address);

      if (isConnect) {
        // Update device info from discovered devices or use existing
        final device = _discoveredDevices.firstWhere(
          (d) => d.address == address,
          orElse: () =>
              _selectedDevice ??
              BluetoothDevice(
                name: 'Unknown',
                address: address,
                type: 0, // Default type
              ),
        );

        _selectedDevice = device;
        _isConnected = true;

        // Save as default printer for future auto-connect
        await _saveDevice(device);

        debugPrint('✅ Connected successfully to ${device.name}');
        debugPrint('💾 Saved as default printer for auto-connect');
      } else {
        _errorMessage = 'Failed to connect to device';
        _isConnected = false;
        debugPrint('❌ Connection failed to $address');
      }

      notifyListeners();
      return isConnect;
    } catch (e) {
      _errorMessage = 'Connection error: $e';
      _isConnected = false;
      notifyListeners();
      debugPrint('❌ Connection error: $_errorMessage');
      return false;
    }
  }

  /// Disconnect from current device
  Future<void> disconnect() async {
    try {
      if (_selectedDevice != null) {
        await FlutterBluetoothPrinter.disconnect(_selectedDevice!.address);
        debugPrint('🔌 Disconnected from ${_selectedDevice?.name}');
      }
      _isConnected = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error disconnecting: $e');
    }
  }

  /// Forget saved device (disconnect and clear from memory)
  Future<void> forgetDevice() async {
    await disconnect();
    await _clearSavedDevice();
    _selectedDevice = null;
    debugPrint('🗑️ Default printer removed - will not auto-connect');
    notifyListeners();
  }

  /// Get printer connection state
  Future<void> checkConnectionState() async {
    try {
      final state = await FlutterBluetoothPrinter.getState();
      debugPrint('Printer State: $state');
      // State is never null based on the API, just check it
      notifyListeners();
    } catch (e) {
      debugPrint('Error checking state: $e');
    }
  }

  /// Select device using built-in selector
  Future<BluetoothDevice?> selectDeviceWithDialog(BuildContext context) async {
    try {
      final selected = await FlutterBluetoothPrinter.selectDevice(context);
      if (selected != null) {
        await connectToDevice(selected.address);
        return selected;
      }
      return null;
    } catch (e) {
      _errorMessage = 'Error selecting device: $e';
      debugPrint(_errorMessage);
      notifyListeners();
      return null;
    }
  }

  /// Check if there's a saved default printer
  bool get hasDefaultPrinter => _selectedDevice != null;

  /// Get the default printer name
  String get defaultPrinterName => _selectedDevice?.name ?? 'No default printer';

  @override
  void dispose() {
    _discoverySubscription?.cancel();
    super.dispose();
  }
}
