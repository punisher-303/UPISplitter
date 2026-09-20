import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../l10n/app_strings.dart';
import '../models/split_order.dart';
import '../models/tranche.dart';
import '../services/currency_formatter.dart';
import '../services/split_engine.dart';
import '../theme/app_theme.dart';
import '../widgets/neopop_components.dart';
import '../widgets/qr_tranche_card.dart';

class GroupSplitView extends StatefulWidget {
  const GroupSplitView({super.key});

  @override
  State<GroupSplitView> createState() => _GroupSplitViewState();
}

class _GroupSplitViewState extends State<GroupSplitView> {
  final _amountController = TextEditingController(text: '0');
  int _peopleCount = 4;

  SplitOrder? _groupOrder;

  @override
  void initState() {
    super.initState();
    _recalculateGroup();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _recalculateGroup() {
    final amt = IndianNumberFormat.parseAmount(_amountController.text);
    if (amt <= 0) {
      setState(() => _groupOrder = null);
      return;
    }

    setState(() {
      _groupOrder = SplitEngine.createGroupSplitOrder(
        totalAmount: amt,
        numberOfPeople: _peopleCount,
        merchantVpa: 'restaurant@okhdfcbank',
        merchantName: 'Social Bistro',
        friendNames: List.generate(_peopleCount, (i) => 'Friend ${i + 1}'),
      );
    });
  }

  void _shareAllViaWhatsApp() {
    if (_groupOrder == null) return;
    final perPerson = IndianNumberFormat.formatWithDecimals(_groupOrder!.totalAmount / _peopleCount, 2);
    final totalFormatted = IndianNumberFormat.format(_groupOrder!.totalAmount);
    final msg = '🍻 Dinner Bill Split on UPI Splitter (0% MDR)!\nTotal: ₹$totalFormatted | Friends: $_peopleCount\nShare per person: ₹$perPerson\n\nPay your share directly via UPI without any surcharge!';
    SharePlus.instance.share(ShareParams(text: msg));
  }

  @override
  Widget build(BuildContext context) {
    final order = _groupOrder;
    final isDark = ThemeController.isDark(context);

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        title: Text(AppStrings.groupBillSplit, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        backgroundColor: AppColors.bg(context),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // SPLIT SETUP HUB
            Text(
              'SPLIT SETUP',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                color: AppColors.textSub(context),
              ),
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                // Total Bill Card
                Expanded(
                  flex: 3,
                  child: NeoPopSurfaceCard(
                    backgroundColor: AppColors.cardBg(context),
                    borderColor: AppColors.primaryBlue,
                    depth: 4.0,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Bill', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textSub(context))),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            prefixText: '₹ ',
                            border: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primaryBlue)),
                          ),
                          onChanged: (_) => _recalculateGroup(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // People Slider Card
                Expanded(
                  flex: 2,
                  child: NeoPopSurfaceCard(
                    backgroundColor: AppColors.cardBg(context),
                    borderColor: const Color(0xFFF59E0B),
                    depth: 4.0,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Friends', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textSub(context))),
                        const SizedBox(height: 8),
                        Text(
                          '$_peopleCount',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFFF59E0B)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Slider outside for friends
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: const Color(0xFFF59E0B),
                thumbColor: const Color(0xFFF59E0B),
                inactiveTrackColor: isDark ? const Color(0xFF27272A) : const Color(0xFFE2E8F0),
                trackHeight: 6,
              ),
              child: Slider(
                value: _peopleCount.toDouble(),
                min: 2,
                max: 50,
                divisions: 48,
                onChanged: (val) {
                  setState(() {
                    _peopleCount = val.toInt();
                  });
                  _recalculateGroup();
                },
              ),
            ),

            const SizedBox(height: 24),

            if (order != null && order.totalAmount > 0) ...[
              // Summary Pop-out
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFFF59E0B), const Color(0xFFD97706)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFFF59E0B).withAlpha(100), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Share per person', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text(
                          '₹${IndianNumberFormat.formatWithDecimals(order.totalAmount / _peopleCount, 2)}',
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(50),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.share_rounded, color: Colors.white),
                        onPressed: _shareAllViaWhatsApp,
                        tooltip: 'Share on WhatsApp',
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              Text(
                'COLLECTION TRANCHES',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: AppColors.textSub(context),
                ),
              ),
              const SizedBox(height: 12),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: order.tranches.length,
                itemBuilder: (context, index) {
                  final tranche = order.tranches[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: QrTrancheCard(
                      tranche: tranche,
                      totalTranches: order.tranches.length,
                      isCurrentActive: !tranche.isPaid && index == 0,
                      onSimulatePayment: () {
                        setState(() {
                          tranche.status = TrancheStatus.paid;
                          tranche.paidAt = DateTime.now();
                        });
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
            ],
          ],
        ),
      ),
    );
  }
}