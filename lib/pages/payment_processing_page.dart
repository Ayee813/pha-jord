import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../app_color.dart';
import '../core/phapay_service.dart';
import '../core/models/phapay_bank.dart';

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
  bool _isProcessing = false; // Start false to allow bank selection if needed

  PhaPayBank? _selectedBank;
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

    // If not PhaPay QR, process immediately. If PhaPay QR, wait for bank selection.
    if (widget.paymentMethod != PaymentMethod.phapayQR) {
      _isProcessing = true;
      _processPayment();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onBankSelected(PhaPayBank bank) {
    setState(() {
      _selectedBank = bank;
      _isProcessing = true;
    });
    _processPayment();
  }

  Future<void> _processPayment() async {
    // Show loading state
    await Future.delayed(const Duration(milliseconds: 500));

    // Create payment using PhaPay Service (defaults to QR generation now)
    final result = await _phapayService.initiatePayment(
      amount: widget.amount,
      method: widget.paymentMethod,
      description: 'Wallet Top Up - ₭${widget.amount.toStringAsFixed(0)}',
      bank: _selectedBank,
    );

    setState(() {
      _isProcessing = false;
      _result = result;
    });

    if (result.success && result.paymentUrl != null) {
      if (result.isQrData) {
        // Show QR code in-app
        print('✅ QR Code generated successfully: ${result.paymentUrl}');
        _animationController.forward();
      } else {
        // Fallback: Launch payment URL in browser (old method)
        try {
          final uri = Uri.parse(result.paymentUrl!);
          print('🚀 Launching Payment URL: $uri');

          final launched = await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );

          if (launched) {
            print('✅ Payment URL launched successfully');
            _animationController.forward();
            await Future.delayed(const Duration(seconds: 3));
            if (mounted) {
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
          } else {
            print('⚠️ Failed to launch payment URL');
            setState(() {
              _result = PaymentResult(
                success: false,
                message: 'Cannot open payment link in browser',
                transactionId: result.transactionId,
                newBalance: result.newBalance,
              );
            });
            _animationController.forward();
          }
        } catch (e) {
          setState(() {
            _result = PaymentResult(
              success: false,
              message: 'Error opening payment link: ${e.toString()}',
              transactionId: result.transactionId,
              newBalance: result.newBalance,
            );
          });
          _animationController.forward();
        }
      }
    } else {
      // Payment failed
      _animationController.forward();
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: _isProcessing
              ? _buildProcessingView()
              : (_result != null
                    ? _buildResultView()
                    : _buildBankSelectionView()),
        ),
      ),
    );
  }

  Widget _buildBankSelectionView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Select Bank Processing',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'Choose your preferred banking app',
          style: TextStyle(fontSize: 14, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        _buildBankButton(PhaPayBank.bcel, Colors.red[700]!),
        const SizedBox(height: 16),
        _buildBankButton(PhaPayBank.jdb, Colors.blue[800]!),
        const SizedBox(height: 16),
        _buildBankButton(PhaPayBank.ldb, Colors.green[700]!),
        const SizedBox(height: 16),
        _buildBankButton(PhaPayBank.other, Colors.orange[700]!),
      ],
    );
  }

  Widget _buildBankButton(PhaPayBank bank, Color color) {
    return ElevatedButton(
      onPressed: () => _onBankSelected(bank),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: color, // Text/Icon color
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: color, width: 2),
        ),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // You could add an Image.asset here if you had icons
          // Image.asset(bank.logoAsset, width: 30, height: 30),
          // const SizedBox(width: 12),
          Text(
            bank.displayName,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // ... (Same header as before)
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
            Icons.qr_code_scanner,
            size: 80,
            color: AppColors.primaryColor,
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'PhaPay QR',
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
          'Generating QR Code...',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildResultView() {
    final isSuccess = _result?.success ?? false;
    final isQrData = _result?.isQrData ?? false;
    final paymentData = _result?.paymentUrl ?? '';

    if (isSuccess && isQrData && paymentData.isNotEmpty) {
      // Show QR Code
      return ScaleTransition(
        scale: _scaleAnimation,
        child: Column(
          children: [
            const Text(
              'Scan to Pay',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Use your banking app to scan this QR code',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // QR Code Container
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: QrImageView(
                data: paymentData,
                version: QrVersions.auto,
                size: 250,
                gapless: false,
                embeddedImage: const AssetImage(
                  'assets/icons/PhaJord_icon.png',
                ),
                embeddedImageStyle: const QrEmbeddedImageStyle(
                  size: Size(40, 40),
                ),
                errorStateBuilder: (cxt, err) {
                  return const Center(
                    child: Text(
                      'Error generating QR code',
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),

            // Amount
            Text(
              '₭${widget.amount.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            if (_result?.orderNo != null)
              Text(
                'Order: ${_result!.orderNo}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),

            const SizedBox(height: 48),

            // Done Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Default error/legacy success view
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
            isSuccess ? 'Payment Link Opened!' : 'Failed to Generate QR',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isSuccess ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _result?.message ?? 'Unknown error',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }
}
