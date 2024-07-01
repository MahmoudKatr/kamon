import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kamon/Features/ordars/activeOrder/Pending_order_card.dart';
import 'package:kamon/Features/ordars/activeOrder/cancelled_order_card.dart';
import 'package:kamon/Features/ordars/activeOrder/complete_order_card.dart';
import 'package:kamon/Features/ordars/activeOrder/confirmed_order_card.dart';
import 'package:kamon/Features/ordars/app_layout/controllers/app_layout_cubit.dart';
import 'package:kamon/Features/ordars/order_clip.dart';
import 'package:kamon/constant.dart';
import 'package:kamon/core/shared_widget/base_clip_path.dart';

class OrderLayoutScreen extends StatelessWidget {
  const OrderLayoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      PendingOrder(),
      confirmedOrder(),
      CompleteOrderCard(),
      CancelledOrder(),
    ];

    return BlocProvider(
      create: (context) => AppLayoutCubit(),
      child: BlocBuilder<AppLayoutCubit, int>(
        builder: (context, state) {
          return Scaffold(
            body: Column(
              children: [
                ClipPath(
                  clipper: BaseClipper(),
                  child: const OrderClip(),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30.0),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        spreadRadius: 5,
                        blurRadius: 15,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  margin: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      _buildTabItem(
                        context: context,
                        index: 0,
                        text: 'Pending',
                        isSelected: state == 0,
                      ),
                      _buildTabItem(
                        context: context,
                        index: 1,
                        text: 'Confirmed',
                        isSelected: state == 1,
                      ),
                      _buildTabItem(
                        context: context,
                        index: 2,
                        text: 'Completed',
                        isSelected: state == 2,
                      ),
                      _buildTabItem(
                        context: context,
                        index: 3,
                        text: 'Cancelled',
                        isSelected: state == 3,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: screens[state],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabItem({
    required BuildContext context,
    required int index,
    required String text,
    required bool isSelected,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => context.read<AppLayoutCubit>().changeIndex(index),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? kPrimaryColor : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: kPrimaryColor.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 10,
                    ),
                  ]
                : [],
          ),
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: isSelected ? kSecondaryColor : kPrimaryColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 16, // Adjust font size if needed
              ),
              overflow: TextOverflow.ellipsis, // Ensure text does not overflow
            ),
          ),
        ),
      ),
    );
  }
}
