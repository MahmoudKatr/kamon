import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kamon/Features/auth/UI/add_account.dart';
import 'package:kamon/Features/auth/UI/login_screen.dart';
import 'package:kamon/Features/auth/UI/sign_up_screen.dart';
import 'package:kamon/constant.dart';
import 'package:kamon/core/shared_widget/base_clip_path.dart';

class VerifyPhoneScreen extends StatefulWidget {
  const VerifyPhoneScreen({super.key});

  @override
  _VerifyPhoneScreenState createState() => _VerifyPhoneScreenState();
}

class _VerifyPhoneScreenState extends State<VerifyPhoneScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isOtpSent = false;
  String _verificationId = '';

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _sendOtp() async {
    final phone = _phoneController.text;

    await _auth.verifyPhoneNumber(
      phoneNumber: '+2$phone', // Adjust the country code as needed
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        // This callback will be triggered when verification is done automatically
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to verify phone number: ${e.message}')),
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _isOtpSent = true;
          _verificationId = verificationId;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP sent to your phone number')),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() {
          _verificationId = verificationId;
        });
      },
    );
  }

  Future<void> _verifyOtp() async {
    if (_formKey.currentState!.validate()) {
      final code = _otpController.text;

      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: code,
      );

      try {
        await _auth.signInWithCredential(credential);

        final phone = _phoneController.text;

        final response = await http.post(
          Uri.parse('https://54.235.40.102.nip.io/admin/customers/verifyPhone'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'phone': phone}),
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> responseBody = jsonDecode(response.body);
          final customerData = responseBody['data']['information'][0];

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddAccountScreen(
                customerData: customerData,
              ),
            ),
          );
        } else if (response.statusCode == 500) {
          final Map<String, dynamic> responseBody = jsonDecode(response.body);
          if (responseBody['status'] == 'error' &&
              responseBody['message'] == 'Phone not related to customer') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Phone not related to customer, please sign up')),
            );
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SignUpScreen()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Verification failed')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Verification failed')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid OTP')),
        );
      }
    }
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number cannot be empty';
    } else if (value.length != 11) {
      return 'Phone number must be exactly 11 digits';
    }
    return null;
  }

  String? _validateOtp(String? value) {
    if (value == null || value.isEmpty) {
      return 'OTP cannot be empty';
    } else if (value.length != 6) {
      return 'OTP must be exactly 6 digits';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSecondaryColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            ClipPath(
              clipper: BaseClipper(),
              child: Container(
                height: 150,
                color: kPrimaryColor,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 50.0),
                    child: Text(
                      'Verify Phone',
                      style: kPrimaryFont(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: kSecondaryColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Welcome, We are happy to see you SignUp',
                          style: kPrimaryFont(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: kPrimaryColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 36.0),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Enter Phone Number',
                          style: kPrimaryFont(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: kPrimaryColor,
                          ),
                        ),
                      ),
                    ),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Phone Number',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        filled: true,
                        fillColor: const Color(0xffDAE4E0),
                      ),
                      validator: _validatePhoneNumber,
                    ),
                    const SizedBox(height: 16.0),
                    if (_isOtpSent)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16.0),
                          Text(
                            'Enter OTP',
                            style: kPrimaryFont(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: kPrimaryColor,
                            ),
                          ),
                          TextFormField(
                            controller: _otpController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'OTP',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              filled: true,
                              fillColor: const Color(0xffDAE4E0),
                            ),
                            validator: _validateOtp,
                          ),
                        ],
                      ),
                    const SizedBox(height: 25.0),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        onPressed: _isOtpSent ? _verifyOtp : _sendOtp,
                        child: Text(
                          _isOtpSent ? 'Verify OTP' : 'Send OTP',
                          style: GoogleFonts.lato(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(
                              branchLocation: '',
                            ),
                          ),
                        );
                      },
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Are you new? ',
                              style: GoogleFonts.lato(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                              text: 'Log In',
                              style: GoogleFonts.lato(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: kPrimaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}