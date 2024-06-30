import 'package:flutter/material.dart';
import 'package:kamon/constant.dart';

class ActiveOrderCard extends StatelessWidget {
  const ActiveOrderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: SizedBox(
          height: 108,
          child: Row(
            children: [
              const SizedBox(
                width: 25,
              ),
              AspectRatio(
                aspectRatio: 3 / 4,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.black12,
                    image: const DecorationImage(
                      image: NetworkImage(testImage),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
              // ignore: prefer_const_constructors
              SizedBox(
                width: 13.32,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .4,
                    child: Text(
                      'order number one or may be order number two or three',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: kPrimaryFont(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: kItemFontColor,
                      ),
                    ),
                  ),
                  // ignore: prefer_const_constructors
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    '29 Nov, 01:20 pm ',
                    style: kPrimaryFont(
                      fontSize: 14,
                      fontWeight: FontWeight.w100,
                      color: kItemFontColor,
                    ),
                  ),
                  Text(
                    'Cairo branch',
                    style: kSecondaryFont(
                      fontSize: 14,
                      fontWeight: FontWeight.w200,
                      color: kPrimaryColor,
                    ),
                  )
                ],
              ),
              const SizedBox(
                width: 30,
              ),
              Column(children: [
                Text(
                  'Total',
                  style: kPrimaryFont(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: kItemFontColor,
                  ),
                ),
                Text(
                  '200 EGP',
                  style: kPrimaryFont(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryColor,
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  'Visa ',
                  style: kPrimaryFont(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryColor,
                  ),
                ),
              ])
            ],
          )),
    );
  }
}
