import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app_color.dart';
import '../core/phapay_service.dart';
import 'payment_processing_page.dart';

class WalletTopUpPage extends StatefulWidget {
  const WalletTopUpPage({super.key});

  @override
  State<WalletTopUpPage> createState() => _WalletTopUpPageState();
}

class _WalletTopUpPageState extends State<WalletTopUpPage> {
  final TextEditingController _amountController = TextEditingController();
  final PhapayService _phapayService = PhapayService();

  double? selectedAmount;
  PaymentMethod selectedPaymentMethod = PaymentMethod.phapayQR;

  final List<double> presetAmounts = [20000, 50000, 100000, 200000, 500000];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _selectAmount(double amount) {
    setState(() {
      selectedAmount = amount;
      _amountController.clear();
    });
  }

  void _onCustomAmountChanged(String value) {
    if (value.isNotEmpty) {
      setState(() {
        selectedAmount = double.tryParse(value);
      });
    } else {
      setState(() {
        selectedAmount = null;
      });
    }
  }

  void _proceedToPayment() {
    if (selectedAmount == null || selectedAmount! <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select or enter a valid amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (selectedAmount! < 10000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Minimum top-up amount is ₭10,000'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Navigate to payment processing page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentProcessingPage(
          amount: selectedAmount!,
          paymentMethod: selectedPaymentMethod,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentBalance = _phapayService.walletBalance;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Top Up Wallet',
          style: TextStyle(
            color: AppColors.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Balance Card
            _buildBalanceCard(currentBalance),
            const SizedBox(height: 24),

            // Amount Selection
            const Text(
              'Select Amount',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
            const SizedBox(height: 12),
            _buildPresetAmounts(),
            const SizedBox(height: 16),
            _buildCustomAmountInput(),
            const SizedBox(height: 32),

            // Payment Method Selection
            const Text(
              'Payment Method',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
            const SizedBox(height: 12),
            _buildPaymentMethods(),
            const SizedBox(height: 32),

            // Proceed Button
            _buildProceedButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(double balance) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryColor, Color(0xFF00A86B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Current Balance',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.account_balance_wallet,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: 12),
              Text(
                '₭${balance.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPresetAmounts() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: presetAmounts.map((amount) {
        final isSelected = selectedAmount == amount;
        return GestureDetector(
          onTap: () => _selectAmount(amount),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryColor : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? AppColors.primaryColor
                    : Colors.grey.shade300,
                width: 2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Text(
              '₭${amount.toStringAsFixed(0)}',
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCustomAmountInput() {
    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Or enter custom amount',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: _onCustomAmountChanged,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
            decoration: InputDecoration(
              hintText: '0',
              prefixText: '₭ ',
              prefixStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primaryColor,
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Column(
      children: PaymentMethod.values.map((method) {
        final isSelected = selectedPaymentMethod == method;
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedPaymentMethod = method;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primaryColor.withOpacity(0.1)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? AppColors.primaryColor
                    : Colors.grey.shade300,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryColor.withOpacity(0.2)
                        : Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    method.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    method.displayName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.primaryColor
                          : AppColors.textColor,
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.primaryColor,
                    size: 24,
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProceedButton() {
    final isEnabled = selectedAmount != null && selectedAmount! > 0;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isEnabled ? _proceedToPayment : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          disabledBackgroundColor: Colors.grey.shade300,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: isEnabled ? 8 : 0,
          shadowColor: AppColors.primaryColor.withOpacity(0.3),
        ),
        child: Text(
          selectedAmount != null && selectedAmount! > 0
              ? 'Proceed to Pay ₭${selectedAmount!.toStringAsFixed(0)}'
              : 'Select Amount to Continue',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isEnabled ? Colors.white : Colors.grey.shade500,
          ),
        ),
      ),
    );
  }
}
