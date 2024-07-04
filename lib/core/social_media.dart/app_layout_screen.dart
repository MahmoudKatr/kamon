import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kamon/Features/ordars/app_layout/controllers/app_layout_cubit.dart';
import 'package:kamon/constant.dart';
import 'package:kamon/core/shared_widget/base_clip_path.dart';
import 'package:kamon/core/social_media.dart/screen/add_request_friend.dart';
import 'package:kamon/core/social_media.dart/screen/get_friend_list_screen.dart';
import 'package:kamon/core/social_media.dart/screen/get_friends_favorite_item.dart';
import 'package:kamon/core/social_media.dart/screen/get_friends_request_screen.dart';
import 'package:kamon/core/social_media.dart/social_media_clip.dart';

class SocialMediaScreen extends StatelessWidget {
  const SocialMediaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      const AddRequestFriend(),
      const FriendsListPage(),
      const FriendRequestsPage(),
      const FavoriteItemsScreen(),
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
                  child: const SocialMediaClip(),
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
                    children: [
                      _buildTabItem(
                        context: context,
                        index: 0,
                        text: 'Add',
                        isSelected: state == 0,
                      ),
                      _buildTabItem(
                        context: context,
                        index: 1,
                        text: 'List',
                        isSelected: state == 1,
                      ),
                      _buildTabItem(
                        context: context,
                        index: 2,
                        text: 'Requests',
                        isSelected: state == 2,
                      ),
                      _buildTabItem(
                        context: context,
                        index: 3,
                        text: 'Favorite',
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
