import 'dart:developer' as dev;
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lotto_app/config/config.dart';
import 'package:lotto_app/models/request/CustomersRegPostReq.dart';
import 'package:lotto_app/models/response/CustomersLoginPostRes.dart';
import 'package:lotto_app/pages/login.dart';
import 'package:http/http.dart' as http;
import 'package:lotto_app/pages/home.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String url = '';
  TextEditingController nameNoCtl = TextEditingController();
  TextEditingController emailNoCtl = TextEditingController();
  TextEditingController phoneNoCtl = TextEditingController();
  TextEditingController passNoCtl = TextEditingController();
  TextEditingController confpassNoCtl = TextEditingController();

  @override
  void initState() {
    super.initState();
    Configuration.getConfig().then((config) {
      setState(() {
        url = config['apiEndpoint'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE1E4F9),
              Color(0xFFF2F2F9)
            ], // Updated gradient colors
            stops: [0.0, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  _buildBackButton(),
                  SizedBox(height: 20),
                  Text(
                    'Lotto',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    'Welcome onboard!',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(height: 40),
                  _buildTextField('Enter your fullname', nameNoCtl),
                  SizedBox(height: 20),
                  _buildTextField('Enter your Email', emailNoCtl),
                  SizedBox(height: 20),
                  _buildTextField('Enter your Password', passNoCtl,
                      obscureText: true),
                  SizedBox(height: 20),
                  _buildTextField('Confirm Password', confpassNoCtl,
                      obscureText: true),
                  SizedBox(height: 30),
                  _buildButton('Register', reg, isPrimary: true),
                  SizedBox(height: 15),
                  _buildButton('Sign In', navigateToLogin,
                      isPrimary: true), // Changed to primary
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return IconButton(
      icon: Icon(Icons.arrow_back, color: Colors.black),
      onPressed: () => Navigator.of(context).pop(),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller,
      {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed,
      {bool isPrimary = true}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(text),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Color(0xFF8064A2), // Both buttons now use this color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: EdgeInsets.symmetric(vertical: 15),
          elevation: 5,
        ),
      ),
    );
  }

  void reg() {
    if (_validateFields()) {
      var data = CustomersRegPostReq(
          fullname: nameNoCtl.text,
          phone: phoneNoCtl.text,
          email: emailNoCtl.text,
          password: passNoCtl.text,
          confirmpassword: confpassNoCtl.text,
          image:
              "http://202.28.34.197:8888/contents/4a00cead-afb3-45db-a37a-c8bebe08fe0d.png");

      http
          .post(Uri.parse('$url/customers'),
              headers: {"Content-Type": "application/json; charset=utf-8"},
              body: jsonEncode(data.toJson()))
          .then((response) {
        if (response.statusCode == 200) {
          dev.log("Registration successful");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage(cid: null)),
          );
        } else {
          _handleError(response);
        }
      }).catchError((error) {
        dev.log("Error during registration: ${error.toString()}");
        _showSnackBar('เกิดข้อผิดพลาด กรุณาลองอีกครั้งในภายหลัง');
      });
    }
  }

  bool _validateFields() {
    if (nameNoCtl.text.isEmpty ||
        emailNoCtl.text.isEmpty ||
        passNoCtl.text.isEmpty ||
        confpassNoCtl.text.isEmpty) {
      _showSnackBar('กรุณากรอกข้อมูลให้ครบทุกช่อง');
      return false;
    }

    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(emailNoCtl.text)) {
      _showSnackBar('กรุณากรอกอีเมลให้ถูกต้องตามรูปแบบ xxx@email.com');
      return false;
    }

    if (passNoCtl.text != confpassNoCtl.text) {
      _showSnackBar('รหัสผ่านและการยืนยันรหัสผ่านไม่ตรงกัน');
      return false;
    }

    return true;
  }

  void _handleError(http.Response response) {
    switch (response.statusCode) {
      case 400:
        _showSnackBar('การลงทะเบียนล้มเหลว: ข้อมูลไม่ถูกต้อง');
        break;
      case 409:
        _showSnackBar('การลงทะเบียนล้มเหลว: ข้อมูลซ้ำ');
        break;
      default:
        _showSnackBar('การลงทะเบียนล้มเหลว กรุณาลองอีกครั้ง');
        break;
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => loginPage()),
    );
  }
}
