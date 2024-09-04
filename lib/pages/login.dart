import 'package:flutter/material.dart';

import 'package:lotto_app/config/config.dart';
import 'package:lotto_app/models/request/CustomersLoginPostResquest.dart';
import 'package:lotto_app/models/response/CustomersLoginPostRes.dart';
import 'package:lotto_app/pages/reg.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as dev;

import 'package:lotto_app/pages/home.dart';

class loginPage extends StatefulWidget {
  loginPage({Key? key}) : super(key: key);

  @override
  State<loginPage> createState() => _loginPageState();
}

class _loginPageState extends State<loginPage> {
  String url = '';
  String text = "";
  TextEditingController phoneNoCtl = TextEditingController();
  TextEditingController passNoCtl = TextEditingController();

  @override
  void initState() {
    super.initState();
    Configuration.getConfig().then(
      (value) {
        dev.log(value['apiEndpoint']);
        url = value['apiEndpoint'];
      },
    );
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
                          controller: phoneNoCtl,
                          decoration: InputDecoration(
                            hintText: 'Username',
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
                          onPressed: login,
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

  void login() {
    var data = CustomersLoginPostResquest(
        phone: phoneNoCtl.text, password: passNoCtl.text);

    http
        .post(Uri.parse('$url/customers/login'),
            headers: {"Content-Type": "application/json; charset=utf-8"},
            body: customersLoginPostResquestToJson(data))
        .then((response) {
      if (response.statusCode == 200) {
        try {
          CustomersLoginPostRes customers =
              customersLoginPostResFromJson(response.body);
          if (customers.customer != null && customers.customer.email != null) {
            dev.log("Customer email: ${customers.customer.email}");
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePage(cid: customers.customer.idx),
                ));
          } else {
            dev.log("Customer or email is null");
            setState(() {
              text = "Login failed: Invalid customer data";
            });
          }
        } catch (e) {
          dev.log("Error parsing response: $e");
          setState(() {
            text = "Login failed: Error processing response";
          });
        }
      } else if (response.statusCode == 401) {
        dev.log("Authentication failed: 401 Unauthorized");
        setState(() {
          text = "Login failed: Incorrect username or password";
        });
      } else {
        dev.log("HTTP Error: ${response.statusCode}");
        setState(() {
          text = "Login failed: Server error (${response.statusCode})";
        });
      }
    }).catchError((error) {
      dev.log("Network error: $error");
      setState(() {
        text = "Login failed: Network error";
      });
    });
  }

  void Reg() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const RegisterPage(),
        ));
  }
}
