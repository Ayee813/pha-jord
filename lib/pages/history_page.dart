import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../app_color.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Data for History
    final List<Map<String, dynamic>> historyLogs = [
      {
        "location": "Central Plaza - Level B1",
        "date": DateTime.now().subtract(const Duration(days: 1)),
        "entryTime": DateTime.now().subtract(const Duration(days: 1, hours: 4)),
        "exitTime": DateTime.now().subtract(const Duration(days: 1, hours: 2)),
        "fee": 10000,
        "method": "QR Scan",
        "status": "Completed",
      },
      {
        "location": "Night Market Zone A",
        "date": DateTime.now().subtract(const Duration(days: 3)),
        "entryTime": DateTime.now().subtract(const Duration(days: 3, hours: 5)),
        "exitTime": DateTime.now().subtract(
          const Duration(days: 3, hours: 4, minutes: 30),
        ),
        "fee": 2000,
        "method": "QR Scan",
        "status": "Completed",
      },
      {
        "location": "Mekong Riverside",
        "date": DateTime.now().subtract(const Duration(days: 5)),
        "entryTime": DateTime.now().subtract(const Duration(days: 5, hours: 2)),
        "exitTime": DateTime.now().subtract(
          const Duration(days: 5, hours: 0, minutes: 15),
        ),
        "fee": 5000,
        "method": "Auto-Pay",
        "status": "Completed",
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: historyLogs.length,
        itemBuilder: (context, index) {
          final log = historyLogs[index];
          final duration = (log['exitTime'] as DateTime).difference(
            log['entryTime'] as DateTime,
          );
          final String durationString =
              "${duration.inHours}h ${duration.inMinutes.remainder(60)}m";
          final String dateString = DateFormat(
            'dd MMM yyyy',
          ).format(log['date']);
          final String entryString = DateFormat(
            'HH:mm',
          ).format(log['entryTime']);
          final String exitString = DateFormat('HH:mm').format(log['exitTime']);

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
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
              children: [
                // Header: Location & Date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          log['location'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateString,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        log['status'],
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),

                // Details: Time, Duration, Method
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoColumn("Entry", entryString),
                    _buildInfoColumn("Exit", exitString),
                    _buildInfoColumn("Duration", durationString),
                  ],
                ),
                const SizedBox(height: 16),

                // Footer: Method & Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.qr_code_scanner,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          log['method'],
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "${NumberFormat('#,###').format(log['fee'])} ₭",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textColor,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
