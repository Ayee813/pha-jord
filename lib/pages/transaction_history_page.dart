import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../app_color.dart';
import '../core/phapay_service.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  final PhapayService _phapayService = PhapayService();

  @override
  Widget build(BuildContext context) {
    final transactions = _phapayService.transactions;

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
          'Transaction History',
          style: TextStyle(
            color: AppColors.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: transactions.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                return _buildTransactionCard(transactions[index]);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No transactions yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your transaction history will appear here',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(Transaction transaction) {
    final isSuccess = transaction.status == TransactionStatus.success;
    final isPending = transaction.status == TransactionStatus.pending;
    final isFailed = transaction.status == TransactionStatus.failed;

    Color statusColor = Colors.grey;
    if (isSuccess) statusColor = Colors.green;
    if (isPending) statusColor = Colors.orange;
    if (isFailed) statusColor = Colors.red;

    IconData typeIcon = Icons.add_circle;
    Color typeColor = Colors.green;
    String amountPrefix = '+';

    if (transaction.type == TransactionType.payment) {
      typeIcon = Icons.remove_circle;
      typeColor = Colors.red;
      amountPrefix = '-';
    } else if (transaction.type == TransactionType.refund) {
      typeIcon = Icons.refresh;
      typeColor = Colors.blue;
      amountPrefix = '+';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showTransactionDetails(transaction),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Type Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(typeIcon, color: typeColor, size: 24),
                ),
                const SizedBox(width: 16),

                // Transaction Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.type.displayName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat(
                          'MMM dd, yyyy • hh:mm a',
                        ).format(transaction.timestamp),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          transaction.status.displayName,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Amount
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$amountPrefix₭${transaction.amount.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: typeColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      transaction.method.displayName,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTransactionDetails(Transaction transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Transaction Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Details
            _buildDetailRow('Transaction ID', transaction.id),
            const Divider(height: 32),
            _buildDetailRow('Reference', transaction.reference),
            const Divider(height: 32),
            _buildDetailRow('Type', transaction.type.displayName),
            const Divider(height: 32),
            _buildDetailRow(
              'Amount',
              '₭${transaction.amount.toStringAsFixed(0)}',
            ),
            const Divider(height: 32),
            _buildDetailRow('Payment Method', transaction.method.displayName),
            const Divider(height: 32),
            _buildDetailRow('Status', transaction.status.displayName),
            const Divider(height: 32),
            _buildDetailRow(
              'Date & Time',
              DateFormat(
                'MMMM dd, yyyy at hh:mm a',
              ).format(transaction.timestamp),
            ),
            const SizedBox(height: 32),

            // Close Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Close',
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
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textColor,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
