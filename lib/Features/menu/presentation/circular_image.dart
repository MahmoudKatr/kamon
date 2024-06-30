import 'package:flutter/material.dart';

class CircularImageWithShadow extends StatelessWidget {
  final String imageUrl;
  final double size;

  const CircularImageWithShadow({
    super.key,
    required this.imageUrl,
    this.size = 160.0, // Increased default size
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 4,
            offset: Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: Colors.white,
          width: 4.0,
        ),
      ),
      child: ClipOval(
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
