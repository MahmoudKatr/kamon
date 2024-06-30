import 'package:flutter/material.dart';
import 'package:kamon/constant.dart';
import 'package:kamon/custom_icons.dart';

class MyBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const MyBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kPrimaryColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -3), // Shadow position
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(
              icon: CustomIcons.vector1,
              label: 'Home',
              index: 0,
            ),
            _buildNavItem(
              icon: CustomIcons.vector1_2,
              label: 'My order',
              index: 1,
            ),
            _buildNavItem(
              icon: CustomIcons.vector1_1,
              label: 'Favorite',
              index: 2,
            ),
            _buildNavItem(
              icon: CustomIcons.vector1_3,
              label: 'Profile',
              index: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    return InkWell(
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: currentIndex == index
                ? const Color.fromARGB(255, 28, 33, 22)
                : Colors.white,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: currentIndex == index
                  ? const Color.fromARGB(255, 17, 19, 14)
                  : Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
