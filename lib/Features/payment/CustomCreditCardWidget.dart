import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';

class CustomCreditCard extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final AutovalidateMode autovalidateMode;
  const CustomCreditCard(
      {super.key, required this.formKey, required this.autovalidateMode});

  @override
  State<CustomCreditCard> createState() => _CustomCreditCardState();
}

class _CustomCreditCardState extends State<CustomCreditCard> {
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool showBackView = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CreditCardWidget(
          cardNumber: cardNumber,
          expiryDate: expiryDate,
          cardHolderName: cardHolderName,
          cvvCode: cvvCode,
          showBackView: showBackView,
          isChipVisible: true,
          isHolderNameVisible: true,
          onCreditCardWidgetChange: (value) {},
        ),
        CreditCardForm(
          autovalidateMode: widget.autovalidateMode,
          cardNumber: cardNumber,
          expiryDate: expiryDate,
          cardHolderName: cardHolderName,
          cvvCode: cvvCode,
          onCreditCardModelChange: (creditCardModel) {
            setState(() {
              cardHolderName = creditCardModel.cardHolderName;
              expiryDate = creditCardModel.expiryDate;
              cardNumber = creditCardModel.cardNumber;
              cvvCode = creditCardModel.cvvCode;
              showBackView = creditCardModel.isCvvFocused;
            });
          },
          formKey: widget.formKey,
        ),
      ],
    );
  }
}
