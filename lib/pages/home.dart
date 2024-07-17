import 'package:flutter/material.dart';
import 'package:news_api/models/news_model.dart';
import 'package:news_api/models/quiz_model.dart';

class NewHomeScreen extends StatefulWidget {
  const NewHomeScreen({super.key});

  @override
  State<NewHomeScreen> createState() => _NewHomeScreenState();
}

class _NewHomeScreenState extends State<NewHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Flutter '),
          Text('News/Quiz/Weather App',style: TextStyle(color: Colors.blue,fontWeight: FontWeight.bold ),),
        ],
      ),
      elevation: 0,

      ),
      body: Quiz(),
    );
  }
}

