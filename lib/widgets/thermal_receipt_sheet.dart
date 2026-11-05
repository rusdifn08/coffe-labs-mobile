import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../services/language_service.dart';
import '../services/receipt_print_service.dart';
import '../services/receipt_settings_service.dart';
import '../theme/app_theme.dart';
import 'receipt_customization_sheet.dart';

class ThermalReceiptSheet extends StatefulWidget {
  final Map<String, dynamic> recipe;
  final List<String>? tastingNotes;

  const ThermalReceiptSheet({
    super.key,
    required this.recipe,
    this.tastingNotes,
  });

  static Future<void> show(
    BuildContext context,
    Map<String, dynamic> recipe, {
    List<String>? tastingNotes,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ThermalReceiptSheet(recipe: recipe, tastingNotes: tastingNotes),
    );
  }

  @override
  State<ThermalReceiptSheet> createState() => _ThermalReceiptSheetState();
}

class _ThermalReceiptSheetState extends State<ThermalReceiptSheet> {
  final GlobalKey _receiptBoundaryKey = GlobalKey();
  ReceiptSettings _settings = ReceiptSettings.defaultSettings;
  int _selectedViewMode = 0; // 0 = Visual Kertas Digital, 1 = Teks Monospace Thermal
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    ReceiptSettingsService.settingsNotifier.addListener(_onSettingsChanged);
  }

  @override
  void dispose() {
    ReceiptSettingsService.settingsNotifier.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() {
    if (mounted) {
      setState(() {
        _settings = ReceiptSettingsService.settingsNotifier.value;
      });
    }
  }

  Future<void> _loadSettings() async {
    final s = await ReceiptSettingsService.getSettings();
    if (mounted) {
      setState(() => _settings = s);
    }
  }

  Future<void> _handleExportImage() async {
    setState(() => _isExporting = true);
    final title = widget.recipe['title']?.toString() ?? 'Resep Seduh';
    final success = await ReceiptPrintService.captureAndShareReceiptImage(
      _receiptBoundaryKey,
      recipeTitle: title,
      storeName: _settings.storeName,
    );
    if (!mounted) return;
    setState(() => _isExporting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📸 Gambar struk resolusi tinggi berhasil diekspor!'),
          backgroundColor: AppTheme.primaryBrown,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _handleExportPdf() async {
    setState(() => _isExporting = true);
    try {
      await ReceiptPrintService.exportOrPrintPdf(
        widget.recipe,
        tastingNotes: widget.tastingNotes,
        settings: _settings,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📄 Struk seduh PDF mini berhasil digenerate & siap dibagikan!'),
          backgroundColor: Colors.teal,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengekspor PDF: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEn = LanguageService.isEnglish;
    final receiptText = ReceiptPrintService.generateThermalReceiptText(
      widget.recipe,
      tastingNotes: widget.tastingNotes,
      settings: _settings,
    );
    final sessionCode = ReceiptPrintService.generateSessionCode(widget.recipe);

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.bgCream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Header (Tanpa kata bertanda kurung "(Thermal POS)")
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBrown.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(CupertinoIcons.printer_fill, color: AppTheme.primaryBrown, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEn ? 'Brew Barista Receipt' : 'Struk Seduh Kasir',
                      style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                    ),
                    Text(
                      isEn
                          ? 'Format struk Bluetooth 58mm untuk pelanggan coffee shop'
                          : 'Format struk kasir Bluetooth 58mm untuk pelanggan coffee shop',
                      style: const TextStyle(fontSize: 10.5, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),
              // Tombol Kustomisasi Struk
              IconButton(
                tooltip: isEn ? 'Customize Receipt' : 'Kustomisasi Struk',
                icon: const Icon(CupertinoIcons.slider_horizontal_3, color: AppTheme.primaryBrown, size: 21),
                onPressed: () => ReceiptCustomizationSheet.show(context, onSettingsSaved: _loadSettings),
              ),
              IconButton(
                icon: const Icon(CupertinoIcons.xmark_circle_fill, color: AppTheme.textMuted, size: 22),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Mode Selector: Kertas Digital vs Teks Monospace
          Container(
            height: 36,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedViewMode = 0),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _selectedViewMode == 0 ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: _selectedViewMode == 0
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                )
                              ]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.doc_text_fill,
                            size: 14,
                            color: _selectedViewMode == 0 ? AppTheme.primaryBrown : AppTheme.textMuted,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isEn ? 'Digital Receipt' : 'Kertas Struk Digital',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: _selectedViewMode == 0 ? FontWeight.bold : FontWeight.normal,
                              color: _selectedViewMode == 0 ? AppTheme.primaryBrown : AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedViewMode = 1),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _selectedViewMode == 1 ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: _selectedViewMode == 1
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                )
                              ]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.text_quote,
                            size: 14,
                            color: _selectedViewMode == 1 ? AppTheme.primaryBrown : AppTheme.textMuted,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isEn ? 'Thermal Monospace' : 'Teks ESC/POS',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: _selectedViewMode == 1 ? FontWeight.bold : FontWeight.normal,
                              color: _selectedViewMode == 1 ? AppTheme.primaryBrown : AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Receipt Preview Container
          Expanded(
            child: _selectedViewMode == 0
                ? _buildDigitalReceiptVisual(sessionCode)
                : _buildThermalPlainText(receiptText),
          ),
          const SizedBox(height: 14),

          // 4 Action Buttons Grid (Salin, Gambar, PDF, Print Bluetooth)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  // 1. Ekspor Gambar (PNG)
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryBrown,
                        side: BorderSide(color: AppTheme.primaryBrown.withValues(alpha: 0.4)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _isExporting ? null : _handleExportImage,
                      icon: const Icon(CupertinoIcons.photo_fill_on_rectangle_fill, size: 15),
                      label: Text(
                        isEn ? 'Export Image' : 'Ekspor Gambar',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // 2. Ekspor PDF Mini
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.teal.shade800,
                        side: BorderSide(color: Colors.teal.shade400),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _isExporting ? null : _handleExportPdf,
                      icon: const Icon(CupertinoIcons.doc_fill, size: 15),
                      label: Text(
                        isEn ? 'Export PDF' : 'Ekspor PDF',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  // 3. Salin Struk Teks
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey.shade800,
                        side: BorderSide(color: Colors.grey.shade400),
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        await ReceiptPrintService.copyReceiptToClipboard(
                          widget.recipe,
                          tastingNotes: widget.tastingNotes,
                          settings: _settings,
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('📋 Format struk berhasil disalin ke clipboard!'),
                              backgroundColor: AppTheme.primaryBrown,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      icon: const Icon(CupertinoIcons.doc_on_clipboard, size: 15),
                      label: Text(
                        isEn ? 'Copy Text' : 'Salin Teks',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // 4. Print via Bluetooth Thermal Printer
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBrown,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 1,
                      ),
                      onPressed: () async {
                        await ReceiptPrintService.launchThermalPrintIntent(
                          widget.recipe,
                          tastingNotes: widget.tastingNotes,
                          settings: _settings,
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('🖨️ Struk siap dicetak ke printer Bluetooth thermal!'),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 3),
                            ),
                          );
                        }
                      },
                      icon: const Icon(CupertinoIcons.printer_fill, size: 15),
                      label: Text(
                        isEn ? 'Print Bluetooth' : 'Print Bluetooth',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Tampilan Grafis Kertas Struk Digital yang Elegan & Proporsional
  Widget _buildDigitalReceiptVisual(String sessionCode) {
    final title = widget.recipe['title']?.toString() ?? 'Specialty Brew';
    final author = _settings.baristaName.isNotEmpty
        ? _settings.baristaName
        : (widget.recipe['author']?.toString() ?? 'Coffee Labs Barista');
    final method = widget.recipe['method']?.toString() ?? 'V60 Pour Over';
    final coffeeWeight = widget.recipe['coffeeWeightGrams'] ?? 15;
    final waterWeight = widget.recipe['totalWaterWeightGrams'] ?? 225;
    final iceWeight = widget.recipe['iceWeightGrams'] ?? 0;
    final grindSize = widget.recipe['grindSize']?.toString() ?? 'Medium-Fine';
    final waterTemp = widget.recipe['waterTempCelsius'] ?? 92;
    final notes = (widget.tastingNotes != null && widget.tastingNotes!.isNotEmpty)
        ? widget.tastingNotes!.join(' • ')
        : (widget.recipe['tastingNotes']?.toString() ?? 'Sweet, Balanced, Clean');
    final ratio = (waterWeight / (coffeeWeight > 0 ? coffeeWeight : 1)).toStringAsFixed(1);
    final now = DateTime.now();
    final dateStr =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final steps = widget.recipe['steps'] as List<dynamic>? ?? [];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAF7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: RepaintBoundary(
            key: _receiptBoundaryKey,
            child: Container(
              color: const Color(0xFFFAFAF7),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Perforated Top Edge
                  _buildPerforatedDivider(),
                  const SizedBox(height: 10),

                  // STORE HEADER DENGAN IKON PROPORSIONAL
                  Text(
                    '===========================',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.grey.shade600, letterSpacing: 1),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_settings.icon, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          _settings.storeName.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(_settings.icon, style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _settings.tagline.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '===========================',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.grey.shade600, letterSpacing: 1),
                  ),
                  const SizedBox(height: 12),

                  // METADATA SEDUH
                  _buildVisualRow('Waktu', dateStr),
                  _buildVisualRow('No. Sesi', sessionCode),
                  _buildVisualRow('Barista', author),
                  _buildVisualRow('Resep', title),
                  _buildVisualRow('Metode', method),
                  const SizedBox(height: 8),
                  _buildDashedLine(),
                  const SizedBox(height: 8),

                  // PARAMETER SEDUH (Tanpa tanda kurung seperti Dose atau Yield)
                  const Text(
                    'PARAMETER SEDUH:',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF222222),
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildVisualRow('  Dosis Kopi', '${coffeeWeight}g'),
                  if (iceWeight > 0) ...[
                    _buildVisualRow('  Es Batu', '${iceWeight}g'),
                    _buildVisualRow('  Air Panas', '${waterWeight}ml'),
                    _buildVisualRow('  Total Yield', '${waterWeight + iceWeight}g'),
                  ] else ...[
                    _buildVisualRow('  Total Air', '${waterWeight}ml'),
                  ],
                  _buildVisualRow('  Rasio Seduh', '1 : $ratio'),
                  _buildVisualRow('  Ukuran Giling', grindSize),
                  _buildVisualRow('  Suhu Air', '$waterTemp°C'),
                  const SizedBox(height: 8),
                  _buildDashedLine(),
                  const SizedBox(height: 8),

                  // TAHAPAN TUANGAN (Tanpa tanda kurung)
                  const Text(
                    'TAHAPAN TUANGAN:',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF222222),
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (steps.isNotEmpty) ...[
                    ...() {
                      int accWater = 0;
                      int accTime = 0;
                      final List<Widget> widgets = [];
                      for (int i = 0; i < steps.length; i++) {
                        final step = steps[i];
                        final dur = step['durationSeconds'] ?? 30;
                        final water = step['waterWeightGrams'] ?? 0;
                        accWater += (water as num).toInt();
                        final startSec = accTime;
                        accTime += (dur as num).toInt();
                        final endSec = accTime;
                        final sFmt =
                            '${(startSec ~/ 60).toString().padLeft(2, '0')}:${(startSec % 60).toString().padLeft(2, '0')}';
                        final eFmt =
                            '${(endSec ~/ 60).toString().padLeft(2, '0')}:${(endSec % 60).toString().padLeft(2, '0')}';
                        final label = water > 0
                            ? '+$water g - Total $accWater g'
                            : 'Drawdown - Total $accWater g';
                        widgets.add(
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 1.5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('  ${i + 1}. $sFmt-$eFmt',
                                    style: const TextStyle(fontFamily: 'monospace', fontSize: 10.5, color: Color(0xFF333333))),
                                Text(label,
                                    style: const TextStyle(
                                        fontFamily: 'monospace', fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF222222))),
                              ],
                            ),
                          ),
                        );
                      }
                      return widgets;
                    }(),
                  ] else ...[
                    const Text('  1. Tuang air perlahan & stabil',
                        style: TextStyle(fontFamily: 'monospace', fontSize: 10.5, color: Color(0xFF444444))),
                  ],
                  const SizedBox(height: 8),
                  _buildDashedLine(),
                  const SizedBox(height: 8),

                  // CATATAN RASA (Tanpa tanda kurung)
                  const Text(
                    'CATATAN RASA:',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF222222),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      notes,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: Color(0xFF333333),
                        height: 1.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // AUTHENTIC BARCODE VISUAL
                  Center(
                    child: Column(
                      children: [
                        _buildBarcodeVisual(),
                        const SizedBox(height: 3),
                        Text(
                          sessionCode,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 9.5,
                            letterSpacing: 2,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // FOOTER
                  Text(
                    '===========================',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.grey.shade600, letterSpacing: 1),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _settings.footerNote.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF222222),
                    ),
                  ),
                  Text(
                    _settings.subFooter,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  if (_settings.socialHandle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      'IG: ${_settings.socialHandle}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  _buildPerforatedDivider(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Tampilan Monospace Thermal ESC/POS
  Widget _buildThermalPlainText(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAF7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPerforatedDivider(),
            const SizedBox(height: 8),
            SelectableText(
              text,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 11.5,
                color: Color(0xFF222222),
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisualRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontFamily: 'monospace', fontSize: 10.5, color: Color(0xFF444444))),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF222222),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashedLine() {
    return Text(
      '- - - - - - - - - - - - - - - - - - - - - - - -',
      textAlign: TextAlign.center,
      style: TextStyle(fontFamily: 'monospace', fontSize: 9.5, color: Colors.grey.shade400, letterSpacing: 2),
    );
  }

  Widget _buildPerforatedDivider() {
    return Text(
      '• • • • • • • • • • • • • • • • • • • • • • • •',
      textAlign: TextAlign.center,
      style: TextStyle(fontFamily: 'monospace', fontSize: 8.5, color: Colors.grey.shade400, letterSpacing: 3),
    );
  }

  /// Barcode Visual bergaya struk kasir profesional
  Widget _buildBarcodeVisual() {
    return SizedBox(
      height: 28,
      width: 190,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List.generate(42, (index) {
          final isThick = index % 3 == 0;
          final isGap = index % 5 == 2 || index % 7 == 4;
          if (isGap) return const SizedBox(width: 2);
          return Container(
            width: isThick ? 2.5 : 1.2,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            color: const Color(0xFF222222),
          );
        }),
      ),
    );
  }
}
