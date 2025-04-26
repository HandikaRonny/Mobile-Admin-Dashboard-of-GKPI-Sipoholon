import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:pam_project/home.dart';
import 'package:pam_project/login.dart';
import 'package:pam_project/signup.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: HomePage(),
  ));
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Column(
                children: <Widget>[
                  FadeInUp(
                      duration: Duration(milliseconds: 1000),
                      child: Text(
                        "Selamat Datang",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 30),
                      )),
                  SizedBox(
                    height: 20,
                  ),
                  FadeInUp(
                      duration: Duration(milliseconds: 1200),
                      child: Text(
                        "Selamat datang di Aplikasi Mobile Administrasi GKPI Jemaat Khusus Pasar Sipoholon",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[700], fontSize: 15),
                      )),
                ],
              ),
              FadeInUp(
                duration: Duration(milliseconds: 1400),
                child: Container(
                  height: MediaQuery.of(context).size.height / 3,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/logo.png'),
                    ),
                  ),
                ),
              ),
              Column(
                children: <Widget>[
                  FadeInUp(
                    duration: Duration(milliseconds: 1500),
                    child: MaterialButton(
                      minWidth: double.infinity,
                      height: 60,
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginPage()));
                      },
                      color: Colors.blue,
                      shape: RoundedRectangleBorder(
                          side: BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.circular(50)),
                      child: Text(
                        "Login",
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            color: Colors.white),
                      ),
                    ),
                  ),
                  // SizedBox(
                  //   height: 20,
                  // ),
                  // FadeInUp(
                  //   duration: Duration(milliseconds: 1600),
                  //   child: Container(
                  //     padding: EdgeInsets.only(top: 3, left: 3),
                  //     decoration: BoxDecoration(
                  //         borderRadius: BorderRadius.circular(50),
                  //         border: Border(
                  //           bottom: BorderSide(color: Colors.black),
                  //           top: BorderSide(color: Colors.black),
                  //           left: BorderSide(color: Colors.black),
                  //           right: BorderSide(color: Colors.black),
                  //         )),
                  //     child: MaterialButton(
                  //       minWidth: double.infinity,
                  //       height: 60,
                  //       onPressed: () {
                  //         Navigator.push(
                  //             context,
                  //             MaterialPageRoute(
                  //                 builder: (context) => SignupPage()));
                  //       },
                  //       color: Colors.blue,
                  //       elevation: 0,
                  //       shape: RoundedRectangleBorder(
                  //           borderRadius: BorderRadius.circular(50)),
                  //       child: Text(
                  //         "Sign up",
                  //         style: TextStyle(
                  //             fontWeight: FontWeight.w600,
                  //             fontSize: 18,
                  //             color: Colors.white),
                  //       ),
                  //     ),
                  //   ),
                  // )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
