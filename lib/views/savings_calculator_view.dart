import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_strings.dart';
import '../theme/app_theme.dart';
import '../widgets/neopop_components.dart';

class SavingsCalculatorView extends StatefulWidget {
  const SavingsCalculatorView({super.key});

  @override
  State<SavingsCalculatorView> createState() => _SavingsCalculatorViewState();
}

class _SavingsCalculatorViewState extends State<SavingsCalculatorView> {
  double _monthlyTurnover = 1500000;
  double _avgBillSize = 4500;
  final _currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '?', decimalDigits: 0);

  double get _monthlyBaseMdrLoss {
    if (_avgBillSize <= 2000) return 0.0;
    final feePerBill = _avgBillSize * 0.004;
    final cappedFee = feePerBill > 300.0 ? 300.0 : feePerBill;
    final numberOfBills = _monthlyTurnover / _avgBillSize;
    return numberOfBills * cappedFee;
  }

  double get _monthlyGstLoss => _monthlyBaseMdrLoss * 0.18;
  double get _monthlyMdrLoss => _monthlyBaseMdrLoss + _monthlyGstLoss;
  double get _annualMdrLoss => _monthlyMdrLoss * 12;
  double get _annualBaseMdrLoss => _monthlyBaseMdrLoss * 12;
  double get _annualGstLoss => _monthlyGstLoss * 12;

  String get _roastCommentary {
    if (_annualMdrLoss >= 100000) {
      return '💸 You are losing ${_currencyFormat.format(_annualMdrLoss)}/yr (MDR + 18% GST)! That is literally a brand new M3 MacBook Pro or a Bali trip funded for payment gateways.';
    } else if (_annualMdrLoss >= 30000) {
      return '☕ You are losing ${_currencyFormat.format(_annualMdrLoss)}/yr (MDR + 18% GST)! That is 1,500 cups of premium filter coffee down the drain.';
    } else {
      return '🛡️ UPI Splitter shields every single rupee with compliant sub-₹2,000 tranche routing (Zero MDR & Zero GST).';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeController.isDark(context);

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        title: const Text('MDR Dashboard', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        backgroundColor: AppColors.bg(context),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // HUGE Dashboard Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0C1B2E) : const Color(0xFFF0F7FF),
                border: Border(bottom: BorderSide(color: AppColors.primaryBlue.withAlpha(50), width: 2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const NeoPopPillBadge(
                    label: 'TOTAL ANNUAL SAVINGS',
                    color: AppColors.primaryBlue,
                    textColor: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _currencyFormat.format(_annualMdrLoss),
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryBlue,
                      letterSpacing: -1.5,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Retained using 0% MDR Routing',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Roast Alert Box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2E2413) : const Color(0xFFFFF7E6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.goldenYellow.withAlpha(150)),
                      boxShadow: [
                        BoxShadow(color: AppColors.goldenYellow.withAlpha(20), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('???', style: TextStyle(fontSize: 24)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _roastCommentary,
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.4,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),

                  // Business Metrics Control Panel
                  Text(
                    'BUSINESS METRICS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: AppColors.textSub(context),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  NeoPopSurfaceCard(
                    backgroundColor: AppColors.cardBg(context),
                    borderColor: AppColors.border(context),
                    depth: 4.0,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Monthly Turnover Slider
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppStrings.monthlyUpiTurnover,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppColors.text(context),
                              ),
                            ),
                            Text(
                              _currencyFormat.format(_monthlyTurnover),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: AppColors.goldenYellow,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: AppColors.goldenYellow,
                            thumbColor: AppColors.goldenYellow,
                            inactiveTrackColor: isDark ? const Color(0xFF27272A) : const Color(0xFFE2E8F0),
                            trackHeight: 8,
                          ),
                          child: Slider(
                            value: _monthlyTurnover,
                            min: 100000,
                            max: 10000000,
                            divisions: 99,
                            onChanged: (val) {
                              setState(() {
                                _monthlyTurnover = val;
                              });
                            },
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Average Bill Size Slider
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppStrings.avgTicketSize,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppColors.text(context),
                              ),
                            ),
                            Text(
                              _currencyFormat.format(_avgBillSize),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: AppColors.primaryBlue,
                            thumbColor: AppColors.primaryBlue,
                            inactiveTrackColor: isDark ? const Color(0xFF27272A) : const Color(0xFFE2E8F0),
                            trackHeight: 8,
                          ),
                          child: Slider(
                            value: _avgBillSize,
                            min: 500,
                            max: 50000,
                            divisions: 99,
                            onChanged: (val) {
                              setState(() {
                                _avgBillSize = val;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  if (_annualMdrLoss > 0) ...[
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Includes Base MDR: ${_currencyFormat.format(_annualBaseMdrLoss)} ', style: TextStyle(fontSize: 10, color: AppColors.textSub(context))),
                        Text('+ 18% GST: ${_currencyFormat.format(_annualGstLoss)}', style: const TextStyle(fontSize: 10, color: AppColors.alertRed, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Viral Clout Share Button
                  NeoPopActionButton(
                    text: 'SHARE ROAST ON X ??',
                    color: isDark ? Colors.white : AppColors.primaryBlue,
                    textColor: isDark ? Colors.black : Colors.white,
                    prefixIcon: Icon(
                      Icons.send_rounded,
                      color: isDark ? Colors.black : Colors.white,
                      size: 16,
                    ),
                    onTap: () {
                      final tweet =
                          '🚨 New 0.4% UPI MDR + 18% GST is costing me ${_currencyFormat.format(_annualMdrLoss)}/yr!\n\n'
                          '🛡️ Now I bypass it completely using @UPISplitter (0% MDR).\n\n'
                          'Link: https://punisher-303.github.io/UPISplitter/\n'
                          '#Fintech #UPI #UPISplitter';
                      final url = Uri.parse(
                        'https://twitter.com/intent/tweet?text=${Uri.encodeComponent(tweet)}',
                      );
                      launchUrl(url, mode: LaunchMode.externalApplication);
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}