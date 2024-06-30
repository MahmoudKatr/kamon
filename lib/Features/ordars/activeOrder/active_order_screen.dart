import 'package:flutter/material.dart';
import 'package:kamon/Features/ordars/activeOrder/active_order_card.dart';

class ActiceOrderScreen extends StatelessWidget {
  const ActiceOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(children: [
        ActiveOrderCard(),
      ]),
    );
  }
}
