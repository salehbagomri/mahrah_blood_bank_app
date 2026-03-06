import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

/// خدمة مراقبة حالة الاتصال بالإنترنت
class ConnectivityService {
  final InternetConnectionChecker _checker = InternetConnectionChecker.instance;

  StreamSubscription<InternetConnectionStatus>? _subscription;
  bool _isConnected = true;
  final _controller = StreamController<bool>.broadcast();

  // Getters
  bool get isConnected => _isConnected;
  Stream<bool> get onConnectivityChanged => _controller.stream;

  /// بدء مراقبة الاتصال
  Future<void> initialize() async {
    _isConnected = await _checker.hasConnection;

    _subscription = _checker.onStatusChange.listen((status) {
      final connected = status == InternetConnectionStatus.connected;
      if (_isConnected != connected) {
        _isConnected = connected;
        _controller.add(_isConnected);
        debugPrint(
          _isConnected ? '🟢 Network: Connected' : '🔴 Network: Disconnected',
        );
      }
    });

    debugPrint('✅ ConnectivityService: initialized (connected=$_isConnected)');
  }

  /// فحص الاتصال مرة واحدة
  Future<bool> checkConnection() async {
    _isConnected = await _checker.hasConnection;
    return _isConnected;
  }

  /// إيقاف المراقبة
  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}
