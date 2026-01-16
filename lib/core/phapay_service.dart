import 'dart:async';
import 'dart:math';

/// Mock Phapay Payment Service
/// In production, this would connect to actual Phapay API
class PhapayService {
  static final PhapayService _instance = PhapayService._internal();
  factory PhapayService() => _instance;
  PhapayService._internal();

  // Mock wallet balance (in Lao Kip)
  double _walletBalance = 150000;
  double get walletBalance => _walletBalance;

  // Transaction history
  final List<Transaction> _transactions = [];
  List<Transaction> get transactions => List.unmodifiable(_transactions);

  /// Initiate a payment with Phapay
  Future<PaymentResult> initiatePayment({
    required double amount,
    required PaymentMethod method,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Simulate 90% success rate
    final random = Random();
    final isSuccess = random.nextInt(10) < 9;

    if (isSuccess) {
      // Add to wallet balance
      _walletBalance += amount;

      // Create transaction record
      final transaction = Transaction(
        id: _generateTransactionId(),
        amount: amount,
        type: TransactionType.topUp,
        method: method,
        status: TransactionStatus.success,
        timestamp: DateTime.now(),
        reference: _generateReference(),
      );

      _transactions.insert(0, transaction);

      return PaymentResult(
        success: true,
        message:
            'Payment successful! ₭${amount.toStringAsFixed(0)} added to wallet.',
        transactionId: transaction.id,
        newBalance: _walletBalance,
      );
    } else {
      // Create failed transaction record
      final transaction = Transaction(
        id: _generateTransactionId(),
        amount: amount,
        type: TransactionType.topUp,
        method: method,
        status: TransactionStatus.failed,
        timestamp: DateTime.now(),
        reference: _generateReference(),
      );

      _transactions.insert(0, transaction);

      return PaymentResult(
        success: false,
        message: 'Payment failed. Please try again.',
        transactionId: transaction.id,
        newBalance: _walletBalance,
      );
    }
  }

  /// Generate QR code data for QR payment
  String generateQRCode(double amount) {
    return 'PHAPAY://pay?amount=$amount&merchant=PHAJORD&ref=${_generateReference()}';
  }

  String _generateTransactionId() {
    return 'TXN${DateTime.now().millisecondsSinceEpoch}${Random().nextInt(1000)}';
  }

  String _generateReference() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(
      12,
      (index) => chars[Random().nextInt(chars.length)],
    ).join();
  }

  /// Add a mock transaction for demo purposes
  void addMockTransaction(TransactionType type, double amount) {
    final transaction = Transaction(
      id: _generateTransactionId(),
      amount: amount,
      type: type,
      method: PaymentMethod.phapayQR,
      status: TransactionStatus.success,
      timestamp: DateTime.now().subtract(Duration(days: Random().nextInt(30))),
      reference: _generateReference(),
    );
    _transactions.add(transaction);
  }
}

/// Payment Method Enum
enum PaymentMethod { phapayQR, bankTransfer, creditCard }

extension PaymentMethodExtension on PaymentMethod {
  String get displayName {
    switch (this) {
      case PaymentMethod.phapayQR:
        return 'Phapay QR Code';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethod.creditCard:
        return 'Credit/Debit Card';
    }
  }

  String get icon {
    switch (this) {
      case PaymentMethod.phapayQR:
        return '📱';
      case PaymentMethod.bankTransfer:
        return '🏦';
      case PaymentMethod.creditCard:
        return '💳';
    }
  }
}

/// Transaction Type Enum
enum TransactionType { topUp, payment, refund }

extension TransactionTypeExtension on TransactionType {
  String get displayName {
    switch (this) {
      case TransactionType.topUp:
        return 'Top Up';
      case TransactionType.payment:
        return 'Payment';
      case TransactionType.refund:
        return 'Refund';
    }
  }
}

/// Transaction Status Enum
enum TransactionStatus { success, pending, failed }

extension TransactionStatusExtension on TransactionStatus {
  String get displayName {
    switch (this) {
      case TransactionStatus.success:
        return 'Success';
      case TransactionStatus.pending:
        return 'Pending';
      case TransactionStatus.failed:
        return 'Failed';
    }
  }
}

/// Transaction Model
class Transaction {
  final String id;
  final double amount;
  final TransactionType type;
  final PaymentMethod method;
  final TransactionStatus status;
  final DateTime timestamp;
  final String reference;

  Transaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.method,
    required this.status,
    required this.timestamp,
    required this.reference,
  });
}

/// Payment Result Model
class PaymentResult {
  final bool success;
  final String message;
  final String transactionId;
  final double newBalance;

  PaymentResult({
    required this.success,
    required this.message,
    required this.transactionId,
    required this.newBalance,
  });
}
