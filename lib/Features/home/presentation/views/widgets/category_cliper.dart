import 'package:flutter/material.dart';
import 'package:kamon/constant.dart';

class CategoryCliper extends StatelessWidget {
  const CategoryCliper({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      width: double.infinity,
      color: kPrimaryColor,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 17.0),
          child: Text(
            'Categorys ',
            style: kPrimaryFont(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: kSecondaryColor,
            ),
          ),
        ),
      ),
    );
  }
}
