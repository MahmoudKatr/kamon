import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kamon/Features/menu/presentation/all_menu_screen.dart';
import 'package:kamon/Features/menu/presentation/favorite_menu.dart';
import 'package:kamon/Features/ordars/activeOrder/active_order_screen.dart';
import 'package:kamon/Features/ordars/app_layout/controllers/app_layout_cubit.dart';
import 'package:kamon/Features/ordars/order_clip.dart';
import 'package:kamon/constant.dart';
import 'package:kamon/core/shared_widget/base_clip_path.dart';

/// AppLayoutScreen
class OrderLayoutScreen extends StatelessWidget {
  /// AppLayoutScreen constructor
  const OrderLayoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      const ActiceOrderScreen(),
      FavoritesScreen(),
      MenuScreen(),
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
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  margin: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildTabItem(
                        context: context,
                        index: 0,
                        text: 'Active',
                        isSelected: state == 0,
                      ),
                      _buildTabItem(
                        context: context,
                        index: 1,
                        text: 'Complete',
                        isSelected: state == 1,
                      ),
                      _buildTabItem(
                        context: context,
                        index: 2,
                        text: 'Cancelled',
                        isSelected: state == 2,
                      ),
                    ],
                  ),
                ),
                // Main content goes here
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
    return GestureDetector(
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
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? kSecondaryColor : kPrimaryColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
