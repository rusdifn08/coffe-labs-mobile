/// Configuration settings for On-Device Batch and Single Auto-Labeler.
class AutoLabelConfig {
  final bool enableSegmentation;
  final bool enableGatekeeper;
  final bool enableOcrSlug;
  final bool autoCreateNewClasses; // true: auto-create if < 85%, false: restrict to existing
  final double detectionThreshold; // default 0.42
  final double minAreaRatio; // default 0.025
  final double maxAreaRatio; // default 0.95
  final double minAspectRatio; // default 0.20
  final double maxAspectRatio; // default 2.40
  final double minSolidity; // default 0.62

  const AutoLabelConfig({
    this.enableSegmentation = true,
    this.enableGatekeeper = true,
    this.enableOcrSlug = true,
    this.autoCreateNewClasses = true,
    this.detectionThreshold = 0.42,
    this.minAreaRatio = 0.025,
    this.maxAreaRatio = 0.95,
    this.minAspectRatio = 0.20,
    this.maxAspectRatio = 2.40,
    this.minSolidity = 0.62,
  });

  AutoLabelConfig copyWith({
    bool? enableSegmentation,
    bool? enableGatekeeper,
    bool? enableOcrSlug,
    bool? autoCreateNewClasses,
    double? detectionThreshold,
    double? minAreaRatio,
    double? maxAreaRatio,
    double? minAspectRatio,
    double? maxAspectRatio,
    double? minSolidity,
  }) {
    return AutoLabelConfig(
      enableSegmentation: enableSegmentation ?? this.enableSegmentation,
      enableGatekeeper: enableGatekeeper ?? this.enableGatekeeper,
      enableOcrSlug: enableOcrSlug ?? this.enableOcrSlug,
      autoCreateNewClasses: autoCreateNewClasses ?? this.autoCreateNewClasses,
      detectionThreshold: detectionThreshold ?? this.detectionThreshold,
      minAreaRatio: minAreaRatio ?? this.minAreaRatio,
      maxAreaRatio: maxAreaRatio ?? this.maxAreaRatio,
      minAspectRatio: minAspectRatio ?? this.minAspectRatio,
      maxAspectRatio: maxAspectRatio ?? this.maxAspectRatio,
      minSolidity: minSolidity ?? this.minSolidity,
    );
  }
}
