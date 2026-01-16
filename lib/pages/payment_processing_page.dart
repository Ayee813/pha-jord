import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../app_color.dart';
import '../core/phapay_service.dart';

class PaymentProcessingPage extends StatefulWidget {
  final double amount;
  final PaymentMethod paymentMethod;

  const PaymentProcessingPage({
    super.key,
    required this.amount,
    required this.paymentMethod,
  });

  @override
  State<PaymentProcessingPage> createState() => _PaymentProcessingPageState();
}

class _PaymentProcessingPageState extends State<PaymentProcessingPage>
    with SingleTickerProviderStateMixin {
  final PhapayService _phapayService = PhapayService();
  bool _isProcessing = true;
  PaymentResult? _result;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _processPayment();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    // Show payment process for a bit
    await Future.delayed(const Duration(seconds: 3));

    final result = await _phapayService.initiatePayment(
      amount: widget.amount,
      method: widget.paymentMethod,
    );

    setState(() {
      _isProcessing = false;
      _result = result;
    });

    _animationController.forward();

    // Auto navigate back after showing result
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textColor),
          onPressed: () =>
              Navigator.of(context).popUntil((route) => route.isFirst),
        ),
        title: const Text(
          'Payment',
          style: TextStyle(
            color: AppColors.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _isProcessing ? _buildProcessingView() : _buildResultView(),
        ),
      ),
    );
  }

  Widget _buildProcessingView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Phapay Logo/Branding
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryColor.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Icon(
            Icons.payment,
            size: 80,
            color: AppColors.primaryColor,
          ),
        ),
        const SizedBox(height: 32),

        const Text(
          'Phapay',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Secure Payment Gateway',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 48),

        // QR Code (if using QR payment)
        if (widget.paymentMethod == PaymentMethod.phapayQR)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: QrImageView(
              data: _phapayService.generateQRCode(widget.amount),
              version: QrVersions.auto,
              size: 200.0,
              backgroundColor: Colors.white,
            ),
          ),

        if (widget.paymentMethod == PaymentMethod.phapayQR)
          const SizedBox(height: 24),

        // Amount
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              const Text(
                'Amount',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                '₭${widget.amount.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Processing indicator
        const SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
            strokeWidth: 3,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Processing payment...',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),

        if (widget.paymentMethod == PaymentMethod.phapayQR) ...[
          const SizedBox(height: 32),
          const Text(
            'Scan QR code with your banking app',
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildResultView() {
    final isSuccess = _result?.success ?? false;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Success/Error Icon
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: isSuccess
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              size: 100,
              color: isSuccess ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(height: 32),

          Text(
            isSuccess ? 'Payment Successful!' : 'Payment Failed',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isSuccess ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(height: 16),

          Text(
            _result?.message ?? '',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Transaction Details
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildDetailRow(
                  'Amount',
                  '₭${widget.amount.toStringAsFixed(0)}',
                ),
                const Divider(height: 24),
                _buildDetailRow(
                  'Payment Method',
                  widget.paymentMethod.displayName,
                ),
                const Divider(height: 24),
                _buildDetailRow(
                  'Transaction ID',
                  _result?.transactionId ?? 'N/A',
                ),
                if (isSuccess) ...[
                  const Divider(height: 24),
                  _buildDetailRow(
                    'New Balance',
                    '₭${_result?.newBalance.toStringAsFixed(0) ?? '0'}',
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 32),

          const Text(
            'Redirecting...',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
