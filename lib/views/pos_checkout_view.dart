import 'package:flutter/material.dart';
import 'package:neopop/neopop.dart';
import '../l10n/app_strings.dart';
import '../models/split_order.dart';
import '../services/currency_formatter.dart';
import '../services/split_engine.dart';
import '../services/upi_validator.dart';
import '../theme/app_theme.dart';
import '../widgets/soundbox_speaker_widget.dart';
import '../widgets/split_checkout_modal.dart';
import 'qr_scanner_view.dart';
import '../widgets/prank_video_dialog.dart' as import_prank;

class KiranaPreset {
  final String title;
  final double amount;

  const KiranaPreset({required this.title, required this.amount});
}

class PosCheckoutView extends StatefulWidget {
  final Map<String, String>? initialScannedData;
  const PosCheckoutView({super.key, this.initialScannedData});

  @override
  State<PosCheckoutView> createState() => PosCheckoutViewState();
}

class PosCheckoutViewState extends State<PosCheckoutView> {
  final _amountController = TextEditingController(text: '0');
  final _vpaController = TextEditingController(text: '');
  final _nameController = TextEditingController(text: '');

  SplitOrder? _currentOrder;
  String? _soundboxAnnouncement;
  String? _selectedPresetTitle;

  List<KiranaPreset> get _kiranaPresets => [
    KiranaPreset(title: AppStrings.presetAttaOil, amount: 2450),
    KiranaPreset(title: AppStrings.presetDairyGhee, amount: 3200),
    KiranaPreset(title: AppStrings.presetDhabaDinner, amount: 3850),
    KiranaPreset(title: AppStrings.presetDryFruits, amount: 4500),
    KiranaPreset(title: AppStrings.presetFullRation, amount: 7500),
  ];

  static const List<String> _upiHandles = [
    '@okhdfcbank',
    '@okaxis',
    '@paytm',
    '@ybl',
    '@upi',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialScannedData != null) {
      applyScannedData(widget.initialScannedData!);
    } else {
      _recalculateOrder();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _vpaController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void applyScannedData(Map<String, String> result) {
    final vpa = result['pa'] ?? '';
    final name = result['pn'] ?? '';
    final am = result['am'] ?? '';

    setState(() {
      if (vpa.isNotEmpty) _vpaController.text = vpa;
      if (name.isNotEmpty) _nameController.text = Uri.decodeComponent(name);
      if (am.isNotEmpty &&
          double.tryParse(am) != null &&
          double.parse(am) > 0) {
        _amountController.text = IndianNumberFormat.format(double.parse(am));
      }
      _recalculateOrder();
    });

    _openCheckoutDialog();
  }

  Future<void> scanMerchantQr() async {
    final result = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(builder: (context) => const QrScannerView()),
    );

    if (result != null && mounted) {
      applyScannedData(result);
    }
  }

  void _showUpiInputDialog() {
    final tempVpaController = TextEditingController(text: _vpaController.text);
    final tempNameController = TextEditingController(
      text: _nameController.text,
    );

    final isDark = ThemeController.isDark(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          decoration: BoxDecoration(
            color: AppColors.cardBg(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(color: AppColors.border(context), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withAlpha(180)
                    : Colors.black.withAlpha(30),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.enterMerchantUpiId,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      color: AppColors.text(context),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: Icon(
                      Icons.close,
                      color: AppColors.textSub(context),
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // UPI ID (VPA) Input
              Text(
                AppStrings.upiIdVpa,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black : const Color(0xFFF1F5F9),
                  border: Border.all(
                    color: AppColors.border(context),
                    width: 1.2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: tempVpaController,
                  autofocus: true,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text(context),
                  ),
                  decoration: const InputDecoration(
                    hintText: 'e.g. ghost-404@axl',
                    hintStyle: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Quick Handle Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _upiHandles.map((handle) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: InkWell(
                        onTap: () {
                          final current = tempVpaController.text
                              .split('@')
                              .first;
                          if (current.isNotEmpty) {
                            tempVpaController.text = '$current$handle';
                          } else {
                            tempVpaController.text = handle;
                          }
                          setModalState(() {});
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.blueSurface
                                : const Color(0xFFE8F0FE),
                            border: Border.all(
                              color: AppColors.primaryBlue.withAlpha(100),
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            handle,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 14),

              // Store / Merchant Name Input
              Text(
                AppStrings.merchantNameOptional,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black : const Color(0xFFF1F5F9),
                  border: Border.all(
                    color: AppColors.border(context),
                    width: 1.2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: tempNameController,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text(context),
                  ),
                  decoration: const InputDecoration(
                    hintText: 'e.g. Anand - Developer',
                    hintStyle: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Scan QR Alternative Button
              InkWell(
                onTap: () {
                  Navigator.pop(ctx);
                  scanMerchantQr();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF14151B)
                        : const Color(0xFFF1F5F9),
                    border: Border.all(color: AppColors.border(context)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.qr_code_scanner,
                        size: 16,
                        color: AppColors.text(context),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'OR SCAN MERCHANT QR CODE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          color: AppColors.text(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Confirm Button
              NeoPopButton(
                color: AppColors.primaryBlue,
                border: Border.all(color: Colors.black, width: 1.5),
                depth: 3.0,
                onTapUp: () {
                  final vpa = tempVpaController.text.trim();
                  final validation = UpiValidator.validate(vpa);
                  if (!validation.isValid) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          validation.errorMessage ??
                              'Please enter a valid UPI ID (e.g. store@upi)',
                        ),
                        backgroundColor: AppColors.alertRed,
                      ),
                    );
                    return;
                  }

                  setState(() {
                    _vpaController.text = validation.vpa!;
                    _nameController.text =
                        tempNameController.text.trim().isNotEmpty
                        ? tempNameController.text.trim()
                        : validation.merchantName!;
                    _recalculateOrder();
                  });

                  Navigator.pop(ctx);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Center(
                    child: Text(
                      AppStrings.saveUpiId,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _recalculateOrder() {
    final amt = IndianNumberFormat.parseAmount(_amountController.text);
    if (amt <= 0) return;

    final vpa = _vpaController.text.trim().isNotEmpty
        ? _vpaController.text.trim()
        : 'ghost-404@axl';
    final name = _nameController.text.trim().isNotEmpty
        ? _nameController.text.trim()
        : 'Anand - Developer';

    setState(() {
      _currentOrder = SplitEngine.createTrancheOrder(
        totalAmount: amt,
        merchantVpa: vpa,
        merchantName: name,
        note: _selectedPresetTitle ?? AppStrings.customBill,
      );
    });
  }

  void _openCheckoutDialog() {
    if (_vpaController.text.trim().isEmpty) {
      _showUpiInputDialog();
      return;
    }

    _recalculateOrder();
    if (_currentOrder == null) return;

    SplitCheckoutDialog.show(
      context,
      order: _currentOrder!,
      onOrderUpdated: (updatedOrder) {
        setState(() {
          _currentOrder = updatedOrder;
          if (updatedOrder.isFullyPaid) {
            _soundboxAnnouncement =
                'SETTLED: ₹${IndianNumberFormat.format(updatedOrder.totalAmount)} VIA 0% MDR';
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = _currentOrder;
    final amt = IndianNumberFormat.parseAmount(_amountController.text);
    final baseMdr = (amt <= 2000 ? 0.0 : (amt * 0.004 > 300 ? 300.0 : amt * 0.004));
    final gstFee = baseMdr * 0.18;
    final totalFee = baseMdr + gstFee;
    final standardFee = IndianNumberFormat.formatWithDecimals(totalFee, 2);
    final isVpaSet = _vpaController.text.trim().isNotEmpty;
    final isDark = ThemeController.isDark(context);

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        title: const Text('Smart POS Checkout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        backgroundColor: AppColors.bg(context),
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Sleek Modern Amount Input
                  Center(
                    child: Column(
                      children: [
                        Text('AMOUNT TO PAY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: AppColors.textSub(context))),
                        const SizedBox(height: 12),
                        IntrinsicWidth(
                          child: TextField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: AppColors.text(context), letterSpacing: -1.0),
                            decoration: const InputDecoration(
                              prefixText: '₹ ',
                              prefixStyle: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: AppColors.primaryBlue),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onChanged: (v) => _recalculateOrder(),
                          ),
                        ),
                        if (amt > 2000)
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.alertRed.withAlpha(20),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.alertRed.withAlpha(50)),
                            ),
                            child: Text(
                              'Saves ₹$standardFee in MDR',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.alertRed),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Pill Presets (Horizontal Scroll)
                  SizedBox(
                    height: 36,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _kiranaPresets.length,
                      itemBuilder: (context, index) {
                        final preset = _kiranaPresets[index];
                        final isSelected = _selectedPresetTitle == preset.title;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedPresetTitle = preset.title;
                                _amountController.text = preset.amount.toInt().toString();
                              });
                              _recalculateOrder();
                            },
                            borderRadius: BorderRadius.circular(18),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primaryBlue : (isDark ? const Color(0xFF1E1E24) : const Color(0xFFF1F5F9)),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: isSelected ? AppColors.primaryBlue : AppColors.border(context)),
                              ),
                              child: Text(
                                preset.title,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected ? Colors.white : AppColors.text(context),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Beautiful Merchant VPA Card
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardBg(context),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border(context)),
                      boxShadow: [
                        BoxShadow(
                          color: isDark ? Colors.black.withAlpha(100) : Colors.black.withAlpha(10),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: AppColors.primaryBlue.withAlpha(20), shape: BoxShape.circle),
                          child: const Icon(Icons.storefront_rounded, color: AppColors.primaryBlue, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: _showUpiInputDialog,
                            child: Container(
                              color: Colors.transparent,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isVpaSet ? _nameController.text.isNotEmpty ? _nameController.text : 'Unknown Merchant' : 'Tap to add Merchant',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.text(context)),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    isVpaSet ? _vpaController.text : 'No UPI ID specified',
                                    style: TextStyle(fontSize: 12, color: AppColors.textSub(context)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_rounded, color: AppColors.primaryBlue),
                          onPressed: _showUpiInputDialog,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Prank Button (Kept Intact)
                  Align(
                    alignment: Alignment.center,
                    child: InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => const import_prank.PrankVideoDialog(),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2E1313) : const Color(0xFFFFF0F0),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.alertRed.withAlpha(100)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🎁', style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 8),
                            const Text(
                              'Get fre 500 RS',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: AppColors.alertRed,
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
          ),

          // Fixed Bottom Bar
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cardBg(context),
              border: Border(top: BorderSide(color: AppColors.border(context), width: 1.5)),
            ),
            child: SafeArea(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isVpaSet ? AppColors.primaryBlue : AppColors.primaryBlue.withAlpha(100),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: isVpaSet && amt > 0 ? _openCheckoutDialog : null,
                child: Text(
                  isVpaSet ? (amt <= 2000 ? 'PAY ₹$amt' : 'PROCESS BILL (0% MDR)') : 'ENTER UPI ID',
                  style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}