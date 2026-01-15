import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import '../app_color.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data for parking spots
    final List<Map<String, dynamic>> parkingSpots = [
      {
        "name": "Central Plaza - Level B1",
        "distance": "0.5 km",
        "slots": 12,
        "price": 5000,
        "isAvailable": true,
        "coordinates": const Offset(100, 150),
      },
      {
        "name": "Mekong Riverside Parking",
        "distance": "1.2 km",
        "slots": 0,
        "price": 3000,
        "isAvailable": false,
        "coordinates": const Offset(250, 300),
      },
      {
        "name": "Night Market Zone A",
        "distance": "0.8 km",
        "slots": 5,
        "price": 2000,
        "isAvailable": true,
        "coordinates": const Offset(180, 220),
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          "Available Parking",
          style: TextStyle(
            color: AppColors.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textColor),
      ),
      body: Stack(
        children: [
          // 1. Mock Map Background
          Container(
            color: Colors.grey.shade300,
            child: Center(
              child: Opacity(
                opacity: 0.2,
                child: Icon(FIcons.map, size: 200, color: Colors.grey.shade600),
              ),
            ),
          ),

          // 2. Map Pins (Mock locations)
          ...parkingSpots.map((spot) {
            return Positioned(
              left: (spot['coordinates'] as Offset).dx,
              top: (spot['coordinates'] as Offset).dy,
              child: _buildMapPin(spot),
            );
          }),

          // 3. Bottom List of Parking Spots
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 280,
              padding: const EdgeInsets.only(top: 16, bottom: 20),
              decoration: const BoxDecoration(color: Colors.transparent),
              child: PageView.builder(
                controller: PageController(viewportFraction: 0.9),
                itemCount: parkingSpots.length,
                itemBuilder: (context, index) {
                  final spot = parkingSpots[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: _buildParkingCard(spot),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapPin(Map<String, dynamic> spot) {
    bool isAvailable = spot['isAvailable'] as bool;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isAvailable ? Colors.green : Colors.red,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(FIcons.mapPin, color: Colors.white, size: 20),
        ),
      ],
    );
  }

  Widget _buildParkingCard(Map<String, dynamic> spot) {
    bool isAvailable = spot['isAvailable'] as bool;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header: Name and Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  spot['name'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isAvailable
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      isAvailable ? Icons.check_circle : Icons.cancel,
                      size: 14,
                      color: isAvailable ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isAvailable ? "${spot['slots']} slots" : "Full",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isAvailable ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Distance
          Row(
            children: [
              Icon(Icons.navigation, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                "${spot['distance']} away",
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),

          const Spacer(),
          const Divider(),
          const SizedBox(height: 8),

          // Price and Action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Rate per hour",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  Text(
                    "${spot['price']} ₭",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  // Navigation action mock
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.directions, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text("Navigate", style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
