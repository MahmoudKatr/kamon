import 'package:flutter/material.dart';
import 'package:kamon/Features/ordars/activeOrder/confirmed_order_card.dart';

class ConfirmedOrderScreen extends StatelessWidget {
  const ConfirmedOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(children: [
        ConfirmedOrderCard(),
      ]),
    );
  }
}
