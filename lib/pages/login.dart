import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:lotto_app/config/config.dart';
import 'package:lotto_app/config/configg.dart';
import 'package:lotto_app/models/request/CustomersLoginPostResquest.dart';
import 'package:lotto_app/models/response/CustomersLoginPostRes.dart';
import 'package:lotto_app/pages/reg.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as dev;

import 'package:lotto_app/pages/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class loginPage extends StatefulWidget {
  loginPage({Key? key}) : super(key: key);

  @override
  State<loginPage> createState() => _loginPageState();
}

class _loginPageState extends State<loginPage> {
  String url = '';
  String text = "";
  TextEditingController emailNoCtl = TextEditingController();
  TextEditingController passNoCtl = TextEditingController();
  bool _isNotValidata = false;
  late SharedPreferences prefs;

  // @override
  // void initState() {
  //   super.initState();
  //   initSharedPref();
  // }

  @override
  void initState() {
    super.initState();
    initSharedPref();
    Configuration.getConfig().then(
      (value) {
        dev.log(value['apiEndpoint']);
        url = value['apiEndpoint'];
      },
    );
  }

  void initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
  }

  void loginUser() async {
    if (emailNoCtl.text.isNotEmpty && passNoCtl.text.isNotEmpty) {
      var reqBody = {
        "email": emailNoCtl.text,
        "password": passNoCtl.text,
      };

      try {
        var response = await http.post(Uri.parse(login),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(reqBody));

        var jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status']) {
          var myToken = jsonResponse['token'];
          prefs.setString('token', myToken);

          // Navigate to HomePage
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => HomePage(token: myToken)));
        } else {
          setState(() {
            text = "Login failed. Please check your credentials.";
          });
          dev.log(
              'Login failed: ${jsonResponse['message'] ?? "Unknown error"}');
        }
      } catch (e) {
        setState(() {
          text = "An error occurred. Please try again later.";
        });
        dev.log('Error during login: $e');
      }
    } else {
      setState(() {
        text = "Please enter both email and password.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE0E0E0),
      body: Stack(
        children: [
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Color(0xFFD1C4E9),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 100),
                      Text(
                        'Lotto',
                        style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Welcome onboard!',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 40),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: TextField(
                          controller: emailNoCtl,
                          decoration: InputDecoration(
                            hintText: 'Email',
                            prefixIcon: Icon(Icons.person, color: Colors.grey),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 15, horizontal: 20),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: TextField(
                          controller: passNoCtl,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: 'Password',
                            prefixIcon: Icon(Icons.lock, color: Colors.grey),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 15, horizontal: 20),
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: loginUser,
                          child: Text('Login',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF7E57C2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 15),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Don't have an account? ",
                              style: TextStyle(color: Colors.grey[600])),
                          GestureDetector(
                            onTap: Reg,
                            child: Text(
                              'Sign up',
                              style: TextStyle(
                                  color: Color(0xFF7E57C2),
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      if (text.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child:
                              Text(text, style: TextStyle(color: Colors.red)),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void Reg() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const RegisterPage(),
        ));
  }
}
