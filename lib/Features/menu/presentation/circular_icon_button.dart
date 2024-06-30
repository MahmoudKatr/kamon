import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kamon/Features/ordars/data/cart_provider.dart';

class CircularIconButton extends StatefulWidget {
  final IconData icon;
  final int itemId;
  final Color color;

  const CircularIconButton({
    Key? key,
    required this.icon,
    required this.itemId,
    this.color = const Color.fromARGB(102, 36, 10, 51),
    required Null Function() onPressed,
  }) : super(key: key);

  @override
  _CircularIconButtonState createState() => _CircularIconButtonState();
}

class _CircularIconButtonState extends State<CircularIconButton> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            color: widget.color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(widget.icon, color: widget.color),
            onPressed: () {
              setState(() {
                if (widget.icon == Icons.remove && quantity > 1) {
                  quantity--;
                } else if (widget.icon == Icons.add) {
                  quantity++;
                }
              });
              Provider.of<CartProvider>(context, listen: false)
                  .updateItemQuantity(widget.itemId, quantity);
            },
            iconSize: 24.0,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            '$quantity',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
