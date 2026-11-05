import 'dart:io';
import 'resolved_coffee_bean.dart';

sealed class BeanScanState {
  const BeanScanState();
}

class BeanScanStateIdle extends BeanScanState {
  const BeanScanStateIdle();
}

class BeanScanStateCapturing extends BeanScanState {
  const BeanScanStateCapturing();
}

class BeanScanStateAnalyzing extends BeanScanState {
  final File imageFile;
  const BeanScanStateAnalyzing(this.imageFile);
}

class BeanScanStateResolved extends BeanScanState {
  final ResolvedCoffeeBean bean;
  final File imageFile;
  const BeanScanStateResolved({required this.bean, required this.imageFile});
}

class BeanScanStateError extends BeanScanState {
  final String message;
  const BeanScanStateError(this.message);
}
