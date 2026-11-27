import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../models/smart_scale_model.dart';

/// Bluetooth 5.2 Smart Scale Driver for Coffee Labs.
///
/// Works strictly with real Bluetooth LE coffee scales — ZERO simulated/fake data:
/// - TIMEMORE Black Mirror Dot / Nano / Basic / 2
/// - Coffee Labs Scale C3 (Native BLE 5.2 protocol)
/// - Acaia Pearl / Lunar / Pyxis / Cinco / Orion
/// - Felicita Arc / Incline / Parallel
/// - Bookoo Themis Mini
/// - Decent / Hiroia / Skale / Eureka / DiFluid / MHW-3Bomber / Generic BLE SIG
class SmartScaleService extends ChangeNotifier {
  static final SmartScaleService instance = SmartScaleService._internal();

  SmartScaleService._internal() {
    _initBluetooth();
  }

  // Real Bluetooth Adapter & Connection State
  bool _isBluetoothSupported = true;
  bool _isBluetoothOn = false;
  bool _isScanning = false;
  bool _isConnecting = false;
  bool _isConnectionVerified = false;
  bool _includeAllBleDevices = false;
  String? _connectingDeviceId;
  String? _lastStatusMessage;
  DateTime? _lastPacketAt;
  int _packetCount = 0;

  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _commandCharacteristic;
  StreamSubscription<BluetoothAdapterState>? _adapterSub;
  StreamSubscription<List<ScanResult>>? _scanSub;
  StreamSubscription<bool>? _isScanningSub;
  StreamSubscription<List<int>>? _notifySub;
  StreamSubscription<BluetoothConnectionState>? _connectionSub;
  Timer? _scanTimeoutTimer;
  Timer? _heartbeatTimer;

  // Active Device Info
  SmartScaleDevice? _activeScaleDevice;
  final List<SmartScaleDevice> _discoveredDevices = [];

  // Active Brew Mode & Linked Recipe (shared between SmartScaleScreen & BrewTimerScreen)
  ScaleBrewMode _brewMode = ScaleBrewMode.pourOver;
  Map<String, dynamic>? _activeRecipe;

  // Tare & Readings (strictly from real BLE notify payloads)
  double _rawWeight = 0.0;
  double _tareOffset = 0.0;
  double _currentWeight = 0.0;
  double _flowRate = 0.0;
  bool _isStable = true;
  int? _batteryLevel;
  int? _scaleTimerSeconds;

  // Flow rate calculation window (1.2s sliding window with exponential smoothing)
  final List<MapEntry<DateTime, double>> _weightHistory = [];

  // Auto-features
  bool _autoStartTimerOnPour = true;
  bool _hasTriggeredAutoStart = false;
  VoidCallback? onAutoStartBrewTimer;

  // Getters
  bool get isBluetoothSupported => _isBluetoothSupported;
  bool get isBluetoothOn => _isBluetoothOn;
  bool get isScanning => _isScanning;
  bool get isConnecting => _isConnecting;
  String? get connectingDeviceId => _connectingDeviceId;
  bool get includeAllBleDevices => _includeAllBleDevices;

  /// Strictly true ONLY when a physical BLE device has an active verified GATT connection.
  bool get isConnected => _isConnectionVerified && _activeScaleDevice != null;

  bool get hasLiveTelemetry => isConnected && _packetCount > 0;
  DateTime? get lastPacketAt => _lastPacketAt;
  int get packetCount => _packetCount;
  String? get lastStatusMessage => _lastStatusMessage;
  SmartScaleDevice? get activeDevice => isConnected ? _activeScaleDevice : null;
  List<SmartScaleDevice> get discoveredDevices =>
      List.unmodifiable(_discoveredDevices);

  ScaleBrewMode get brewMode => _brewMode;
  Map<String, dynamic>? get activeRecipe => _activeRecipe;

  double get currentWeight => isConnected ? _currentWeight : 0.0;
  double get flowRate => isConnected ? _flowRate : 0.0;
  bool get isStable => _isStable;
  int? get batteryLevel => isConnected ? _batteryLevel : null;
  int? get scaleTimerSeconds => isConnected ? _scaleTimerSeconds : null;
  bool get autoStartTimerOnPour => _autoStartTimerOnPour;

  bool get _isRuntimeBlePlatform =>
      !kIsWeb &&
      (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) &&
      !Platform.environment.containsKey('FLUTTER_TEST');

  void setAutoStartTimerOnPour(bool value) {
    _autoStartTimerOnPour = value;
    notifyListeners();
  }

  void setIncludeAllBleDevices(bool value) {
    if (_includeAllBleDevices == value) return;
    _includeAllBleDevices = value;
    notifyListeners();
  }

  void setBrewMode(ScaleBrewMode mode) {
    if (_brewMode == mode) return;
    _brewMode = mode;
    notifyListeners();
  }

  void setActiveRecipe(Map<String, dynamic>? recipe) {
    _activeRecipe = recipe == null ? null : Map<String, dynamic>.from(recipe);
    if (recipe != null) {
      final method =
          '${recipe['method'] ?? ''} ${recipe['category'] ?? ''}'.toLowerCase();
      if (method.contains('espresso') || method.contains('ristretto')) {
        _brewMode = ScaleBrewMode.espresso;
      } else {
        _brewMode = ScaleBrewMode.pourOver;
      }
    }
    notifyListeners();
  }

  void _initBluetooth() {
    if (!_isRuntimeBlePlatform) {
      _isBluetoothSupported = false;
      _isBluetoothOn = false;
      return;
    }

    try {
      _adapterSub?.cancel();
      _adapterSub = FlutterBluePlus.adapterState.listen(
        (state) {
          if (state == BluetoothAdapterState.unknown) return;
          final nowOn = state == BluetoothAdapterState.on;
          final changed = _isBluetoothOn != nowOn;
          _isBluetoothOn = nowOn;

          if (!nowOn) {
            if (_isScanning) {
              _isScanning = false;
              _scanTimeoutTimer?.cancel();
            }
            if (_connectedDevice != null || _activeScaleDevice != null) {
              unawaited(disconnect(
                reason: 'Bluetooth dimatikan. Koneksi timbangan terputus.',
              ));
              return;
            }
          }
          if (changed) notifyListeners();
        },
        onError: (Object e) {
          debugPrint('Bluetooth stream notice: $e');
          _isBluetoothSupported = false;
          _isBluetoothOn = false;
          notifyListeners();
        },
      );

      _isScanningSub?.cancel();
      _isScanningSub = FlutterBluePlus.isScanning.listen((scanning) {
        if (_isScanning != scanning) {
          _isScanning = scanning;
          notifyListeners();
        }
      });
    } catch (e) {
      debugPrint('Bluetooth initialization notice: $e');
      _isBluetoothSupported = false;
      _isBluetoothOn = false;
    }
  }

  /// Requests Android OS to turn on Bluetooth adapter (no-op on iOS where OS settings control it).
  Future<bool> requestTurnOnBluetooth() async {
    if (!_isRuntimeBlePlatform) return false;
    try {
      if (Platform.isAndroid) {
        await FlutterBluePlus.turnOn();
        final state = await _resolveAdapterState();
        _isBluetoothOn = state == BluetoothAdapterState.on;
        if (_isBluetoothOn) {
          _lastStatusMessage = null;
        }
        notifyListeners();
        return _isBluetoothOn;
      }
    } catch (e) {
      debugPrint('Bluetooth turnOn notice: $e');
      _lastStatusMessage =
          'Tidak dapat menyalakan Bluetooth otomatis. Silakan aktifkan Bluetooth dari pengaturan ponsel.';
      notifyListeners();
    }
    return false;
  }

  Future<BluetoothAdapterState> _resolveAdapterState() async {
    try {
      return await FlutterBluePlus.adapterState
          .where((s) => s != BluetoothAdapterState.unknown)
          .first
          .timeout(
            const Duration(seconds: 3),
            onTimeout: () => FlutterBluePlus.adapterStateNow,
          );
    } catch (_) {
      return BluetoothAdapterState.unknown;
    }
  }

  // ==========================================
  // SCANNING FOR REAL BLUETOOTH 5.2 SCALES
  // ==========================================
  Future<void> startScan({
    Duration timeout = const Duration(seconds: 12),
    bool? includeAllDevices,
  }) async {
    if (includeAllDevices != null) {
      _includeAllBleDevices = includeAllDevices;
    }
    if (_isScanning) {
      await stopScan();
    }

    _discoveredDevices.clear();
    _lastStatusMessage = null;

    if (!_isRuntimeBlePlatform) {
      _isBluetoothSupported = false;
      _isBluetoothOn = false;
      _isScanning = false;
      _lastStatusMessage =
          'Bluetooth LE hanya aktif di perangkat Android / iOS.';
      notifyListeners();
      return;
    }

    _isScanning = true;
    notifyListeners();

    try {
      final isSupported = await FlutterBluePlus.isSupported;
      if (!isSupported) {
        _isBluetoothSupported = false;
        _isBluetoothOn = false;
        _isScanning = false;
        _lastStatusMessage = 'Perangkat ini tidak mendukung Bluetooth LE.';
        notifyListeners();
        return;
      }
      _isBluetoothSupported = true;

      final adapterState = await _resolveAdapterState();
      if (adapterState != BluetoothAdapterState.on) {
        _isBluetoothOn = false;
        _isScanning = false;
        _lastStatusMessage =
            'Bluetooth ponsel nonaktif. Aktifkan Bluetooth terlebih dahulu untuk memindai timbangan kopi.';
        notifyListeners();
        return;
      }
      _isBluetoothOn = true;

      // Include any already-connected real BLE coffee scale reported by the OS
      for (final connected in FlutterBluePlus.connectedDevices) {
        final name = connected.platformName;
        if (name.isEmpty) continue;
        final brand = detectBrand(name, const []);
        if (_includeAllBleDevices ||
            brand != ScaleBrand.generic ||
            isLikelyScale(name, const [])) {
          _upsertDiscoveredDevice(
            SmartScaleDevice(
              id: connected.remoteId.str,
              name: name,
              rssi: -50,
              brand: brand,
              isConnected: _activeScaleDevice?.id == connected.remoteId.str &&
                  _isConnectionVerified,
            ),
          );
        }
      }

      // Listen BEFORE starting scan so no early advertisement packets are missed
      await _scanSub?.cancel();
      _scanSub = FlutterBluePlus.scanResults.listen((results) {
        bool mutated = false;
        for (final r in results) {
          final name = r.device.platformName.isNotEmpty
              ? r.device.platformName
              : r.advertisementData.advName;
          final uuids = r.advertisementData.serviceUuids;
          final brand = detectBrand(name, uuids);

          final shouldInclude = brand != ScaleBrand.generic ||
              isLikelyScale(name, uuids) ||
              (_includeAllBleDevices && name.trim().isNotEmpty);

          if (!shouldInclude) continue;

          final deviceId = r.device.remoteId.str;
          final shortId = deviceId.length >= 5
              ? deviceId.substring(deviceId.length - 5)
              : deviceId;
          final device = SmartScaleDevice(
            id: deviceId,
            name: name.isNotEmpty ? name : 'BLE Smart Scale ($shortId)',
            rssi: r.rssi,
            brand: brand,
            isConnected:
                _activeScaleDevice?.id == deviceId && _isConnectionVerified,
          );
          _upsertDiscoveredDevice(device);
          mutated = true;
        }
        if (mutated) {
          notifyListeners();
        }
      });

      // Match AndroidManifest BLUETOOTH_SCAN neverForLocation flag so Android 12+
      // scans reliably without requiring GPS/Location services.
      await FlutterBluePlus.startScan(
        timeout: timeout,
        androidUsesFineLocation: false,
      );

      _scanTimeoutTimer?.cancel();
      _scanTimeoutTimer = Timer(timeout + const Duration(milliseconds: 300), () {
        if (_isScanning) {
          unawaited(stopScan());
        }
      });
    } catch (e) {
      debugPrint('Error starting Bluetooth scan: $e');
      _isScanning = false;
      final err = e.toString().toLowerCase();
      if (err.contains('permission') || err.contains('security')) {
        _lastStatusMessage =
            'Izin Bluetooth (Perangkat Terdekat) belum diberikan. Izinkan akses Bluetooth di Pengaturan Aplikasi.';
      } else if (err.contains('adapter') || err.contains('turned off')) {
        _isBluetoothOn = false;
        _lastStatusMessage =
            'Bluetooth ponsel belum menyala. Nyalakan Bluetooth lalu pindai ulang.';
      } else {
        _lastStatusMessage =
            'Gagal memindai Bluetooth. Pastikan Bluetooth aktif dan izin perangkat terdekat diizinkan.';
      }
      notifyListeners();
    }
  }

  void _upsertDiscoveredDevice(SmartScaleDevice device) {
    final existingIndex =
        _discoveredDevices.indexWhere((d) => d.id == device.id);
    if (existingIndex >= 0) {
      _discoveredDevices[existingIndex] = device;
    } else {
      _discoveredDevices.add(device);
    }
    _discoveredDevices.sort((a, b) => b.rssi.compareTo(a.rssi));
  }

  Future<void> stopScan() async {
    _scanTimeoutTimer?.cancel();
    _scanTimeoutTimer = null;
    if (_isRuntimeBlePlatform) {
      try {
        await FlutterBluePlus.stopScan();
      } catch (_) {}
    }
    await _scanSub?.cancel();
    _scanSub = null;
    if (_isScanning) {
      _isScanning = false;
      notifyListeners();
    }
  }

  @visibleForTesting
  static bool isLikelyScale(String name, List<Guid> serviceUuids) {
    final lower = name.toLowerCase();
    if (lower.contains('scale') ||
        lower.contains('coffee') ||
        lower.contains('timer') ||
        lower.contains('weigh') ||
        lower.contains('timbang') ||
        lower.contains('black') ||
        lower.contains('mirror') ||
        lower.contains('dot') ||
        lower.contains('nano') ||
        lower.contains('themis') ||
        lower.contains('bookoo') ||
        lower.contains('decent') ||
        lower.contains('hiroia') ||
        lower.contains('jimmy') ||
        lower.contains('skale') ||
        lower.contains('eureka') ||
        lower.contains('precisa') ||
        lower.contains('difluid') ||
        lower.contains('microbalance') ||
        lower.contains('varia') ||
        lower.contains('aku') ||
        lower.contains('mhw') ||
        lower.contains('bomber') ||
        lower.contains('searchpean') ||
        lower.contains('tiny2') ||
        lower.contains('kc200') ||
        lower.contains('c3')) {
      return true;
    }
    for (final uuid in serviceUuids) {
      final str = uuid.str.toLowerCase();
      if (str.contains('181d') ||
          str.contains('ffe0') ||
          str.contains('fff0') ||
          str.contains('ffb0') ||
          str.contains('1820') ||
          str.contains('ff00') ||
          str.contains('0e80') ||
          str.contains('c0ffee')) {
        return true;
      }
    }
    return false;
  }

  @visibleForTesting
  static ScaleBrand detectBrand(String name, List<Guid> serviceUuids) {
    final lower = name.toLowerCase();
    if (lower.contains('coffee labs') ||
        lower.contains('coffeelabs') ||
        lower.contains('scale c3') ||
        lower.contains('cl-scale') ||
        lower.contains('cl_c3')) {
      return ScaleBrand.coffeeLabsC3;
    }
    for (final uuid in serviceUuids) {
      if (uuid.str.toLowerCase().contains('c0ffee')) {
        return ScaleBrand.coffeeLabsC3;
      }
    }
    if (lower.contains('timemore') ||
        lower.contains('black mirror') ||
        lower.contains('dot scale') ||
        lower.contains('tm_') ||
        lower.contains('bm_')) {
      return ScaleBrand.timemore;
    }
    if (lower.contains('acaia') ||
        lower.contains('lunar') ||
        lower.contains('pearl') ||
        lower.contains('cinco') ||
        lower.contains('orion') ||
        lower.contains('pyxis')) {
      return ScaleBrand.acaia;
    }
    if (lower.contains('felicita') ||
        lower.contains('arc') ||
        lower.contains('incline') ||
        lower.contains('parallel')) {
      return ScaleBrand.felicita;
    }
    if (lower.contains('bookoo') || lower.contains('themis')) {
      return ScaleBrand.bookoo;
    }
    return ScaleBrand.generic;
  }

  // ==========================================
  // REAL BLE CONNECTION MANAGEMENT
  // ==========================================
  Future<bool> connect(SmartScaleDevice device) async {
    if (_isConnecting) return false;
    await stopScan();
    _lastStatusMessage = null;

    if (!_isRuntimeBlePlatform) {
      _lastStatusMessage =
          'Koneksi Bluetooth LE hanya tersedia pada perangkat Android / iOS.';
      notifyListeners();
      return false;
    }

    final adapterState = await _resolveAdapterState();
    if (adapterState != BluetoothAdapterState.on) {
      _isBluetoothOn = false;
      _lastStatusMessage =
          'Bluetooth belum aktif. Nyalakan Bluetooth sebelum menghubungkan ${device.name}.';
      notifyListeners();
      return false;
    }
    _isBluetoothOn = true;

    // Cleanly close any previous connection first
    if (_connectedDevice != null && _connectedDevice!.remoteId.str != device.id) {
      await disconnect();
    }

    _isConnecting = true;
    _connectingDeviceId = device.id;
    notifyListeners();

    BluetoothDevice? bluetoothDevice;
    try {
      bluetoothDevice = BluetoothDevice.fromId(device.id);
      await bluetoothDevice.connect(
        license: License.nonprofit,
        timeout: const Duration(seconds: 12),
      );

      // Verify real physical connection state before proceeding
      final currentConnState = await bluetoothDevice.connectionState.first
          .timeout(
            const Duration(seconds: 3),
            onTimeout: () => BluetoothConnectionState.disconnected,
          );
      if (currentConnState != BluetoothConnectionState.connected) {
        throw StateError('BLE device did not reach connected state');
      }

      _connectedDevice = bluetoothDevice;

      await _connectionSub?.cancel();
      _connectionSub = bluetoothDevice.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected) {
          final wasActive = _activeScaleDevice?.id == device.id ||
              _connectedDevice?.remoteId.str == device.id;
          if (wasActive) {
            _heartbeatTimer?.cancel();
            _heartbeatTimer = null;
            _notifySub?.cancel();
            _notifySub = null;
            _connectedDevice = null;
            _clearActiveConnectionState();
            _lastStatusMessage = 'Koneksi ke ${device.name} terputus.';
            notifyListeners();
          }
        }
      });

      final services = await bluetoothDevice.discoverServices();
      BluetoothCharacteristic? notifyChar;
      BluetoothCharacteristic? writeChar;
      int bestNotifyScore = -1;
      int bestWriteScore = -1;

      for (final service in services) {
        final sUuid = service.uuid.str.toLowerCase();
        // Skip standard GAP/GATT/Device Info services so we never subscribe to generic metadata
        if (sUuid.endsWith('1800') ||
            sUuid.endsWith('1801') ||
            sUuid.endsWith('180a')) {
          continue;
        }
        final servicePriority = _scoreServiceUuid(sUuid, device.brand);

        for (final char in service.characteristics) {
          final cUuid = char.uuid.str.toLowerCase();
          final charBonus = _scoreCharacteristicUuid(cUuid);
          final score = servicePriority + charBonus;

          if ((char.properties.notify || char.properties.indicate) &&
              score > bestNotifyScore) {
            bestNotifyScore = score;
            notifyChar = char;
          }
          if ((char.properties.write ||
                  char.properties.writeWithoutResponse) &&
              score > bestWriteScore) {
            bestWriteScore = score;
            writeChar = char;
          }
        }
      }

      if (notifyChar == null) {
        await bluetoothDevice.disconnect();
        _connectedDevice = null;
        _clearActiveConnectionState();
        _lastStatusMessage =
            'Karakteristik berat BLE tidak ditemukan pada ${device.name}. Pastikan perangkat adalah timbangan BLE yang kompatibel.';
        return false;
      }

      _commandCharacteristic = writeChar;
      await notifyChar.setNotifyValue(true);
      await _notifySub?.cancel();
      _notifySub = notifyChar.onValueReceived.listen((data) {
        _processScaleBytes(data, device.brand);
      });

      _activeScaleDevice = device.copyWith(isConnected: true);
      _isConnectionVerified = true;
      _hasTriggeredAutoStart = false;
      _lastPacketAt = null;
      _packetCount = 0;

      // Update discovered list badge
      _upsertDiscoveredDevice(_activeScaleDevice!);

      // Perform protocol-specific real BLE handshake when needed (e.g., Acaia)
      await _startScaleHandshakeIfNeeded(device.brand);

      return true;
    } catch (e) {
      debugPrint('Failed to connect to scale: $e');
      try {
        await bluetoothDevice?.disconnect();
      } catch (_) {}
      _connectedDevice = null;
      _clearActiveConnectionState();
      _lastStatusMessage =
          'Gagal terhubung ke ${device.name}. Pastikan timbangan menyala & tidak terhubung ke aplikasi lain.';
      return false;
    } finally {
      _isConnecting = false;
      _connectingDeviceId = null;
      notifyListeners();
    }
  }

  int _scoreServiceUuid(String sUuid, ScaleBrand brand) {
    if (brand == ScaleBrand.coffeeLabsC3 && sUuid.contains('c0ffee')) return 100;
    if (sUuid.contains('181d')) return 90; // BLE SIG Weight Scale Service
    if (sUuid.contains('ffe0') || sUuid.contains('fff0')) return 85; // Timemore / Felicita / Decent / Generic UART
    if (sUuid.contains('1820') || sUuid.contains('0e80')) return 85; // Acaia / Bookoo
    if (sUuid.contains('ffb0') || sUuid.contains('ff00')) return 80;
    if (sUuid.contains('c0ffee')) return 80;
    return 10;
  }

  int _scoreCharacteristicUuid(String cUuid) {
    if (cUuid.contains('2a9d')) return 30; // BLE SIG Weight Measurement
    if (cUuid.contains('ffe1') ||
        cUuid.contains('fff4') ||
        cUuid.contains('fff1') ||
        cUuid.contains('ff11') ||
        cUuid.contains('ff12') ||
        cUuid.contains('2a80')) {
      return 25;
    }
    return 5;
  }

  Future<void> _startScaleHandshakeIfNeeded(ScaleBrand brand) async {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    final cmd = _commandCharacteristic;
    if (cmd == null) return;

    if (brand == ScaleBrand.acaia) {
      try {
        // Acaia Identify + Notification Request so scale streams real weight frames
        const identPayload = [
          0xEF, 0xDD, 0x0B, 0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36,
          0x37, 0x38, 0x39, 0x30, 0x31, 0x32, 0x33, 0x34, 0x9A, 0x6D,
        ];
        const notifyConfig = [
          0xEF, 0xDD, 0x0C, 0x09, 0x00, 0x01, 0x01, 0x02, 0x02, 0x05,
          0x03, 0x04, 0x15, 0x06,
        ];
        const heartbeat = [0xEF, 0xDD, 0x00, 0x02, 0x00, 0x02, 0x00];
        final withoutResp = cmd.properties.writeWithoutResponse;
        await cmd.write(identPayload, withoutResponse: withoutResp);
        await Future.delayed(const Duration(milliseconds: 120));
        await cmd.write(notifyConfig, withoutResponse: withoutResp);

        _heartbeatTimer = Timer.periodic(const Duration(seconds: 3), (_) {
          if (!isConnected || _commandCharacteristic == null) {
            _heartbeatTimer?.cancel();
            return;
          }
          unawaited(
            _commandCharacteristic!
                .write(heartbeat, withoutResponse: withoutResp)
                .catchError((_) {}),
          );
        });
      } catch (e) {
        debugPrint('Acaia handshake notice: $e');
      }
    }
  }

  Future<void> disconnect({String? reason}) async {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    await _notifySub?.cancel();
    _notifySub = null;
    await _connectionSub?.cancel();
    _connectionSub = null;

    if (_connectedDevice != null) {
      try {
        await _connectedDevice?.disconnect();
      } catch (_) {}
      _connectedDevice = null;
    }

    _clearActiveConnectionState();
    if (reason != null) {
      _lastStatusMessage = reason;
    }
    // Clear connected flag in discovered list
    for (int i = 0; i < _discoveredDevices.length; i++) {
      if (_discoveredDevices[i].isConnected) {
        _discoveredDevices[i] = _discoveredDevices[i].copyWith(isConnected: false);
      }
    }
    notifyListeners();
  }

  void _clearActiveConnectionState() {
    _isConnectionVerified = false;
    _commandCharacteristic = null;
    _activeScaleDevice = null;
    _currentWeight = 0.0;
    _rawWeight = 0.0;
    _tareOffset = 0.0;
    _flowRate = 0.0;
    _isStable = true;
    _batteryLevel = null;
    _scaleTimerSeconds = null;
    _lastPacketAt = null;
    _packetCount = 0;
    _weightHistory.clear();
    _hasTriggeredAutoStart = false;
  }

  /// Legacy no-op retained so `SmartScaleRepository` stays source-compatible
  /// without injecting any fake virtual device or fake weight into user sessions.
  void setSimulatedFlowRate(double gramsPerSec) {}

  // ==========================================
  // PROTOCOL PARSING (TIMEMORE, C3, ACAIA, FELICITA, BOOKOO, SIG)
  // ==========================================
  @visibleForTesting
  static double? parseRawWeightBytes(List<int> bytes, ScaleBrand brand) {
    if (bytes.isEmpty) return null;

    // 1. Coffee Labs Scale C3 Native BLE 5.2 Protocol (Header 0xC3 0x01)
    // Frame: [0xC3, 0x01, flags(bit0=neg, bit1=stable), weightHi, weightMid, weightLo, battery, timerHi, timerLo]
    if (brand == ScaleBrand.coffeeLabsC3 &&
        bytes.length >= 6 &&
        bytes[0] == 0xC3 &&
        bytes[1] == 0x01) {
      final sign = (bytes[2] & 0x01) == 1 ? -1.0 : 1.0;
      final tenths = (bytes[3] << 16) | (bytes[4] << 8) | bytes[5];
      return sign * (tenths / 10.0);
    }

    // 2. TIMEMORE Protocol (Black Mirror Dot / Nano / Basic / 2)
    // Variant A: 0xAA 0x55 frame (Black Mirror 2 / Dot extended telemetry)
    if (bytes.length >= 10 && bytes[0] == 0xAA && bytes[1] == 0x55) {
      final sign = bytes[6] == 1 ? -1.0 : 1.0;
      final rawVal = (bytes[7] << 8) | bytes[8];
      return sign * (rawVal / 10.0);
    }
    // Variant B: 0x02 compact 7+ byte frame (Timemore Dot / Basic / Nano)
    if ((brand == ScaleBrand.timemore || bytes[0] == 0x02) &&
        bytes.length >= 7) {
      final sign = bytes[1] == 1 ? -1.0 : 1.0;
      final rawVal = (bytes[2] << 8) | bytes[3];
      return sign * (rawVal / 10.0);
    }

    // 3. Acaia Protocol (Header 0xEF 0xDD)
    if ((brand == ScaleBrand.acaia ||
            (bytes.length >= 6 && bytes[0] == 0xEF && bytes[1] == 0xDD)) &&
        bytes.length >= 7) {
      if (bytes[2] == 0x08) {
        final rawVal = (bytes[4] << 8) | bytes[5];
        final unit = bytes[6];
        return rawVal / (unit == 1 ? 10.0 : 100.0);
      }
      // Acaia Event Weight Message (0x0C, payload event type 0x05)
      if (bytes[2] == 0x0C && bytes.length >= 10 && bytes[4] == 0x05) {
        final rawVal =
            bytes[5] | (bytes[6] << 8) | (bytes[7] << 16) | (bytes[8] << 24);
        final unit = bytes[9];
        final isNeg = bytes.length > 10 && (bytes[10] & 0x02) != 0;
        final divisor = unit == 1 ? 10.0 : (unit == 2 ? 100.0 : 1.0);
        return (isNeg ? -1.0 : 1.0) * (rawVal / divisor);
      }
    }

    // 4. Bookoo Themis Mini Protocol (Header 0x03 0x0B, 20 bytes)
    if ((brand == ScaleBrand.bookoo ||
            (bytes.length >= 10 && bytes[0] == 0x03 && bytes[1] == 0x0B)) &&
        bytes.length >= 10) {
      final sign = bytes[6] == 0x2D ? -1.0 : 1.0; // '-' ASCII
      final hundredths = (bytes[7] << 16) | (bytes[8] << 8) | bytes[9];
      return sign * (hundredths / 100.0);
    }

    // 5. Felicita ASCII Protocol (Header 0x01 0x02, weight digits in ASCII)
    if (brand == ScaleBrand.felicita && bytes.length >= 9 && bytes[0] == 0x01) {
      final sign = bytes[2] == 0x2D ? -1.0 : 1.0;
      final digits = String.fromCharCodes(bytes.sublist(3, 9)).trim();
      final parsed = double.tryParse(digits);
      if (parsed != null) return sign * (parsed / 100.0);
    }

    // 6. Decent / DiFluid / Generic 7-byte (Header 0x03 0xCE)
    if (bytes.length >= 6 && bytes[0] == 0x03 && bytes[1] == 0xCE) {
      int signedVal = (bytes[2] << 8) | bytes[3];
      if (signedVal >= 0x8000) signedVal -= 0x10000;
      return signedVal / 10.0;
    }

    // 7. Generic ASCII UART scale payloads (e.g. "+0045.2g" or "123.4")
    if (brand == ScaleBrand.generic && bytes.length >= 4) {
      final isPrintableAscii = bytes.every(
        (b) => (b >= 0x20 && b <= 0x7E) || b == 0x0A || b == 0x0D,
      );
      if (isPrintableAscii) {
        final text = String.fromCharCodes(bytes).trim();
        final match = RegExp(r'([+-]?\d+(?:\.\d+)?)').firstMatch(text);
        if (match != null) {
          final parsed = double.tryParse(match.group(1)!);
          if (parsed != null) return parsed;
        }
      }
    }

    // 8. Generic Bluetooth SIG Weight Measurement (0x2A9D)
    if (bytes.length >= 3) {
      final rawVal = (bytes[1] << 8) | bytes[2];
      return rawVal / 10.0;
    }

    return null;
  }

  void _processScaleBytes(List<int> bytes, ScaleBrand brand) {
    if (bytes.isEmpty || !isConnected) return;

    try {
      // Optional battery & timer extraction for Coffee Labs Scale C3
      if (brand == ScaleBrand.coffeeLabsC3 &&
          bytes.length >= 9 &&
          bytes[0] == 0xC3 &&
          bytes[1] == 0x01) {
        _batteryLevel = bytes[6].clamp(0, 100);
        _scaleTimerSeconds = (bytes[7] << 8) | bytes[8];
      }

      final weight = parseRawWeightBytes(bytes, brand);
      if (weight != null && weight >= -500.0 && weight <= 5000.0) {
        _packetCount++;
        _lastPacketAt = DateTime.now();
        _rawWeight = weight;
        _updateCalculatedWeight(_rawWeight);
      }
    } catch (e) {
      debugPrint('Scale payload parse error: $e');
    }
  }

  void _updateCalculatedWeight(double raw, {DateTime? sampleTime}) {
    final net = math.max(-100.0, raw - _tareOffset);
    _currentWeight = (net * 10).round() / 10.0; // 0.1g precision

    final now = sampleTime ?? DateTime.now();
    _weightHistory.add(MapEntry(now, _currentWeight));

    // Keep sliding window to 1.2 seconds for responsive & smooth g/s flow rate
    _weightHistory.removeWhere((e) => now.difference(e.key).inMilliseconds > 1200);

    if (_weightHistory.length >= 2) {
      final first = _weightHistory.first;
      final last = _weightHistory.last;
      final deltaSec = last.key.difference(first.key).inMilliseconds / 1000.0;
      if (deltaSec > 0.18) {
        final deltaWeight = last.value - first.value;
        final rawRate = deltaWeight / deltaSec;
        final smoothed = (_flowRate * 0.65) + (rawRate * 0.35);
        _flowRate = (math.max(0.0, smoothed) * 10).round() / 10.0;
      }
    } else {
      _flowRate = 0.0;
    }

    _isStable = _flowRate < 0.2;

    // Auto-trigger brew timer start on first detected pour / espresso drop
    final double minWeightTrigger =
        _brewMode == ScaleBrewMode.espresso ? 0.5 : 1.5;
    final double minFlowTrigger =
        _brewMode == ScaleBrewMode.espresso ? 0.2 : 0.5;
    if (_autoStartTimerOnPour &&
        !_hasTriggeredAutoStart &&
        _flowRate >= minFlowTrigger &&
        _currentWeight >= minWeightTrigger) {
      _hasTriggeredAutoStart = true;
      onAutoStartBrewTimer?.call();
    }

    notifyListeners();
  }

  // ==========================================
  // HARDWARE COMMANDS (Tare, Timer Start/Stop/Reset)
  // ==========================================
  Future<void> tare() async {
    if (!isConnected) return;

    _tareOffset = _rawWeight;
    _currentWeight = 0.0;
    _flowRate = 0.0;
    _weightHistory.clear();
    _hasTriggeredAutoStart = false;

    final cmd = _commandCharacteristic;
    if (cmd != null) {
      try {
        final withoutResp = cmd.properties.writeWithoutResponse;
        switch (_activeScaleDevice?.brand) {
          case ScaleBrand.coffeeLabsC3:
            await cmd.write([0xC3, 0x02, 0x01, 0x00], withoutResponse: withoutResp);
            break;
          case ScaleBrand.timemore:
            await cmd.write([0x02, 0x01, 0x00, 0x00, 0x03], withoutResponse: withoutResp);
            break;
          case ScaleBrand.acaia:
            await cmd.write(
              [0xEF, 0xDD, 0x04, 0x00, 0x00, 0x00],
              withoutResponse: withoutResp,
            );
            break;
          case ScaleBrand.felicita:
            await cmd.write([0x54], withoutResponse: withoutResp); // 'T'
            break;
          case ScaleBrand.bookoo:
            await cmd.write(
              [0x03, 0x0A, 0x01, 0x00, 0x00, 0x08],
              withoutResponse: withoutResp,
            );
            break;
          default:
            break;
        }
      } catch (e) {
        debugPrint('Tare write command notice: $e');
      }
    }

    notifyListeners();
  }

  Future<void> sendStartTimerCommand() async {
    final cmd = _commandCharacteristic;
    if (!isConnected || cmd == null) return;
    try {
      final withoutResp = cmd.properties.writeWithoutResponse;
      switch (_activeScaleDevice?.brand) {
        case ScaleBrand.coffeeLabsC3:
          await cmd.write([0xC3, 0x02, 0x02, 0x01], withoutResponse: withoutResp);
          break;
        case ScaleBrand.timemore:
          await cmd.write([0x02, 0x02, 0x01, 0x00, 0x03], withoutResponse: withoutResp);
          break;
        case ScaleBrand.bookoo:
          await cmd.write(
            [0x03, 0x0A, 0x04, 0x00, 0x00, 0x0D],
            withoutResponse: withoutResp,
          );
          break;
        default:
          break;
      }
    } catch (e) {
      debugPrint('Timer start command notice: $e');
    }
  }

  Future<void> sendStopTimerCommand() async {
    final cmd = _commandCharacteristic;
    if (!isConnected || cmd == null) return;
    try {
      final withoutResp = cmd.properties.writeWithoutResponse;
      switch (_activeScaleDevice?.brand) {
        case ScaleBrand.coffeeLabsC3:
          await cmd.write([0xC3, 0x02, 0x02, 0x00], withoutResponse: withoutResp);
          break;
        case ScaleBrand.timemore:
          await cmd.write([0x02, 0x02, 0x00, 0x00, 0x03], withoutResponse: withoutResp);
          break;
        default:
          break;
      }
    } catch (e) {
      debugPrint('Timer stop command notice: $e');
    }
  }

  void resetAutoStartTrigger() {
    _hasTriggeredAutoStart = false;
  }

  // ==========================================
  // TEST-ONLY HOOKS (Never exposed in production UI)
  // ==========================================
  @visibleForTesting
  void debugAttachTestDevice(SmartScaleDevice device, {int? batteryPercent}) {
    _activeScaleDevice = device.copyWith(isConnected: true);
    _isConnectionVerified = true;
    _batteryLevel = batteryPercent;
    _hasTriggeredAutoStart = false;
    notifyListeners();
  }

  @visibleForTesting
  void debugSimulateHardwareDisconnect({String? reason}) {
    _clearActiveConnectionState();
    _lastStatusMessage = reason ?? 'Koneksi timbangan terputus.';
    notifyListeners();
  }

  @visibleForTesting
  void debugFeedRawBytes(List<int> bytes, {DateTime? sampleTime}) {
    if (!isConnected) return;
    final brand = _activeScaleDevice?.brand ?? ScaleBrand.timemore;
    final parsed = parseRawWeightBytes(bytes, brand);
    if (brand == ScaleBrand.coffeeLabsC3 &&
        bytes.length >= 9 &&
        bytes[0] == 0xC3 &&
        bytes[1] == 0x01) {
      _batteryLevel = bytes[6].clamp(0, 100);
      _scaleTimerSeconds = (bytes[7] << 8) | bytes[8];
    }
    if (parsed != null) {
      _packetCount++;
      _lastPacketAt = sampleTime ?? DateTime.now();
      _rawWeight = parsed;
      _updateCalculatedWeight(_rawWeight, sampleTime: sampleTime);
    }
  }

  @visibleForTesting
  void debugResetForTest() {
    _scanTimeoutTimer?.cancel();
    _scanTimeoutTimer = null;
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    _isScanning = false;
    _isConnecting = false;
    _connectingDeviceId = null;
    _includeAllBleDevices = false;
    _discoveredDevices.clear();
    _activeRecipe = null;
    _brewMode = ScaleBrewMode.pourOver;
    _lastStatusMessage = null;
    _clearActiveConnectionState();
    notifyListeners();
  }
}
