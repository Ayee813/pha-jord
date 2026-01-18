import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/phapay_bank.dart';

/// PhaPay API Service
/// Handles payment link generation using PhaPay Payment Gateway
class PhapayApiService {
  static const String _baseUrl =
      'https://payment-gateway.phajay.co/v1/api/link';
  static const String _apiKey =
      r'$2a$10$9SJjEs7KYVq6tjQ970bdN.GhOB3UNdiqJR8ZuHFuB7qesiDEbjnuW';

  // Shop/Merchant details
  static const String _shopId = 'PHAJORD_APP';
  static const String _shopName = 'Pha Jord';

  static String get apiKey => _apiKey;

  /// Create a payment link for the specified amount
  /// Returns the payment link URL or throws an exception
  Future<PaymentLinkResponse> createPaymentLink({
    required double amount,
    required String description,
  }) async {
    try {
      // Generate unique order number
      final orderNo = _generateOrderNumber();

      // Prepare request body - only required fields
      final requestBody = {
        'orderNo': orderNo,
        'amount': amount.toInt(),
        'description': description,
        // Optional: uncomment if needed
        // 'tag1': _shopId,
        // 'tag2': _shopName,
      };

      // Prepare headers - Payment Link API uses Basic Auth
      // Encode the API key in base64 for Basic Authentication
      final credentials = base64Encode(utf8.encode(_apiKey));
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Basic $credentials',
      };

      print('🔑 Making payment link request...');
      print('📍 URL: $_baseUrl/payment-link');
      print('📦 Body: ${jsonEncode(requestBody)}');
      print('🔐 Authorization: Basic $credentials');

      // Make API request
      final response = await http.post(
        Uri.parse('$_baseUrl/payment-link'),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      print('📡 Response Status: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return PaymentLinkResponse(
          success: true,
          message: data['message'] ?? 'Payment link created successfully',
          redirectURL: data['redirectURL'] ?? '',
          orderNo: data['orderNo'] ?? orderNo,
        );
      } else {
        // Handle error response
        String errorMessage = 'Failed to create payment link';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? errorMessage;
        } catch (e) {
          errorMessage = 'HTTP ${response.statusCode}: ${response.body}';
        }

        return PaymentLinkResponse(
          success: false,
          message: errorMessage,
          redirectURL: '',
          orderNo: orderNo,
        );
      }
    } catch (e) {
      print('❌ Error creating payment link: $e');
      return PaymentLinkResponse(
        success: false,
        message: 'Error: ${e.toString()}',
        redirectURL: '',
        orderNo: '',
      );
    }
  }

  /// Generate QR code for in-app display (IB/Inter-Bank QR)
  Future<PaymentLinkResponse> generateQrCode({
    required double amount,
    required String description,
  }) async {
    return generateBankQr(
      amount: amount,
      description: description,
      bank: PhaPayBank.other, // Default to IB/Other
    );
  }

  /// Generate QR code/Deep Link for a specific bank
  Future<PaymentLinkResponse> generateBankQr({
    required double amount,
    required String description,
    required PhaPayBank bank,
  }) async {
    try {
      final orderNo = _generateOrderNumber();
      final requestBody = {
        'amount': amount.toInt(),
        'description': description,
      };

      final headers = {
        'Content-Type': 'application/json',
        'secretKey': _apiKey,
      };

      // Determine endpoint based on bank
      String endpoint;
      switch (bank) {
        case PhaPayBank.bcel:
          endpoint = 'generate-bcel-qr';
          break;
        case PhaPayBank.jdb:
          endpoint = 'generate-jdb-qr';
          break;
        case PhaPayBank.ldb:
          endpoint =
              'generate-ib-qr'; // Fallback to IB as no specific LDB endpoint known
          break;
        case PhaPayBank.other:
          endpoint = 'generate-ib-qr';
          break;
      }

      print('🔑 Generating QR for ${bank.name}...');
      final url = '$_baseUrl/$endpoint';
      print('📍 URL: $url');
      print('📦 Body: ${jsonEncode(requestBody)}');

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      print('📡 Response Status: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        // Extract URL or QR data based on response consistency
        String urlOrQr = '';
        if (data.containsKey('link')) {
          urlOrQr = data['link'];
        } else if (data.containsKey('appLink')) {
          urlOrQr = data['appLink'];
        } else if (data.containsKey('qrCode')) {
          urlOrQr = data['qrCode'];
        }

        return PaymentLinkResponse(
          success: true,
          message: 'Generated successfully',
          redirectURL: urlOrQr,
          orderNo: orderNo,
        );
      } else {
        String errorMessage = 'Failed to generate QR';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? errorMessage;
        } catch (e) {
          errorMessage = 'HTTP ${response.statusCode}: ${response.body}';
        }
        return PaymentLinkResponse(
          success: false,
          message: errorMessage,
          redirectURL: '',
          orderNo: orderNo,
        );
      }
    } catch (e) {
      print('❌ Error generating QR: $e');
      return PaymentLinkResponse(
        success: false,
        message: 'Error: ${e.toString()}',
        redirectURL: '',
        orderNo: '',
      );
    }
  }

  /// Generate unique order number using timestamp
  String _generateOrderNumber() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'ORDER$timestamp';
  }
}

/// Payment Link Response Model
class PaymentLinkResponse {
  final bool success;
  final String message;
  final String redirectURL;
  final String orderNo;

  PaymentLinkResponse({
    required this.success,
    required this.message,
    required this.redirectURL,
    required this.orderNo,
  });

  factory PaymentLinkResponse.fromJson(Map<String, dynamic> json) {
    return PaymentLinkResponse(
      success: true,
      message: json['message'] ?? '',
      redirectURL: json['redirectURL'] ?? '',
      orderNo: json['orderNo'] ?? '',
    );
  }
}
