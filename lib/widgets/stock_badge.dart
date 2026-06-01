import 'package:flutter/material.dart';

class StockBadge extends StatelessWidget {
  final int stock;

  const StockBadge({Key? key, required this.stock}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    String label;

    if (stock < 10) {
      bgColor = Colors.red.shade100;
      textColor = Colors.red.shade800;
      label = "Stock Bajo";
    } else if (stock >= 11 && stock <= 15) {
      bgColor = Colors.orange.shade100;
      textColor = Colors.orange.shade900;
      label = "Stock Medio";
    } else {
      bgColor = Colors.green.shade100;
      textColor = Colors.green.shade800;
      label = "Stock Alto";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}