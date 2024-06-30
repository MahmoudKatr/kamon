import 'package:flutter/material.dart';
import 'package:kamon/Features/payment/CustomCreditCardWidget.dart';
import 'package:kamon/Features/payment/payment_methods_list_view.dart';

class PaymentMethodScreen extends StatefulWidget {
  @override
  _PaymentMethodScreenState createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final GlobalKey<FormState> formKey = GlobalKey();
  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Select Payment Method'),
        ),
        body: CustomScrollView(slivers: [
          SliverToBoxAdapter(
            child: PaymentMethodList(
              selectedIndex: _selectedIndex,
              onItemTapped: _onItemTapped,
            ),
          ),
          if (_selectedIndex == 1)
            SliverToBoxAdapter(
                child: CustomCreditCard(
              formKey: formKey,
              autovalidateMode: autovalidateMode,
            )),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      formKey.currentState!.save();
                    } else {
                      autovalidateMode = AutovalidateMode.always;
                      setState(() {});
                    }
                    if (_selectedIndex == 0) {
                      // Cash selected
                      print('Cash selected');
                    } else {
                      // Card selected
                    }
                  },
                  child: const Text('Confirm Payment Method'),
                ),
              ),
            ),
          ),
        ]));
  }
}
