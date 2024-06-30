import 'package:flutter/material.dart';

class PaymentMethodList extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  PaymentMethodList({
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: [
        ListTile(
          leading: const Icon(Icons.money),
          title: const Text('Cash'),
          selected: selectedIndex == 0,
          onTap: () => onItemTapped(0),
        ),
        ListTile(
          leading: const Icon(Icons.credit_card),
          title: const Text('Credit Card'),
          selected: selectedIndex == 1,
          onTap: () => onItemTapped(1),
        ),
      ],
    );
  }
}
