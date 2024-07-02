import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BestSellerCard extends StatelessWidget {
  final String imageUrl;
  final String price;
  final String name;

  const BestSellerCard(
      {super.key, required this.imageUrl, required this.price, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20.0)),
            ),
            child: Text(
              name,
              style: GoogleFonts.lato(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Spacer(),
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20.0)),
            ),
            child: Text(
              '\$$price',
              style: GoogleFonts.lato(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
