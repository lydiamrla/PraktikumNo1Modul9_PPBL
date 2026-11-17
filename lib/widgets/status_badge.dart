import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color warna;
    if (status == 'SIAGA') {
      warna = Colors.redAccent;
    } else if (status == 'WASPADA') {
      warna = Colors.orangeAccent;
    } else {
      warna = Colors.greenAccent;
    }

    return Container(
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: warna.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: warna, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 10, color: warna),
          const SizedBox(width: 6),
          Text(
            status,
            style: TextStyle(
              color: warna,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}