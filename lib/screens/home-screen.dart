import 'package:flutter/material.dart';
import 'package:soil_sence/screens/about.dart';
import 'package:soil_sence/screens/new_test.dart';
import 'package:soil_sence/screens/user_manual.dart';
import 'package:soil_sence/screens/widget/button.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

import 'widget/weather.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
            "Home",
            style: TextStyle(
                color: Colors.grey, fontSize: 24, fontWeight: FontWeight.w500),
          )),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            WeatherWidget(),
            const SizedBox(height: 30),
            Container(
                height: 150,
                child: Image.asset('assets/images/image1.png')),
            RichText(
                text: TextSpan(
                    text: "Soil",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green),
                    children: [
                      TextSpan(
                          text: "Sense",
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.brown))
                    ])), SizedBox(height: 25,),
            Text("Welcome to soil sense",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
            Container(margin: EdgeInsets.only(top: 40),
              child: ButtonWidget(buttonData: "READ GUIDE",
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
                buttoncolor: Colors.brown,screen: AboutScreen()),),
            Container(margin: EdgeInsets.only(top: 10),
              child: ButtonWidget(
                buttonData: "ABOUT SOIL SENSE",
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
                buttoncolor: Colors.brown,screen: UserManual()),),
            Container(margin: EdgeInsets.only(top: 10),
              child: ButtonWidget(
                buttonData: "NEW TEST",
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
                buttoncolor: Colors.brown,screen: NewTestScreen()),)
          ],),
      ),

    );
  }
}
