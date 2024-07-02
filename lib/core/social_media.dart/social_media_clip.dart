import 'package:flutter/material.dart';
import 'package:kamon/constant.dart';

class SocialMediaClip extends StatelessWidget {
  const SocialMediaClip({
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
            'Social Media',
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
