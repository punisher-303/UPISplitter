import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'currency_formatter.dart';

class UpiService {
  /// Launches UPI intent URI (opens Google Pay, PhonePe, Paytm, etc. on mobile)
  static Future<bool> launchUpiIntent(String upiUri) async {
    final uri = Uri.parse(upiUri);
    try {
      // Direct launch attempt for Android & iOS intent handlers
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalNonBrowserApplication,
      );
      if (launched) return true;

      // Fallback attempt with externalApplication
      return await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      try {
        return await launchUrl(uri);
      } catch (_) {
        return false;
      }
    }
  }

  /// Copies UPI link or VPA to clipboard
  static Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  static String generateViralShareText({
    required double totalAmount,
    required double mdrSaved,
    required int trancheCount,
  }) {
    return '⚡ Saved ₹${IndianNumberFormat.formatWithDecimals(mdrSaved, 2)} MDR on a ₹${IndianNumberFormat.format(totalAmount)} bill!\n\n'
        'Used $trancheCount sub-₹2k tranches with @UPISplitter to pay 0% fee legally 🚀\n'
        '#UPISplitter #ZeroMDR';
  }

  /// Generates group payment link message for WhatsApp
  static String generateGroupShareMessage({
    required String merchantName,
    required String payerName,
    required double amount,
    required String upiUri,
  }) {
    return 'Hey $payerName, your share for $merchantName is ₹${IndianNumberFormat.formatWithDecimals(amount, 2)}.\n'
        'Click to pay via UPI (0% MDR): $upiUri';
  }
}

