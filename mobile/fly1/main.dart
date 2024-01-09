import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
// This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'ТЕСТ'),
    );
  }
}
class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}
class _MyHomePageState extends State<MyHomePage> {
  void _getBitovkaLampRequestONaa() {
    setState(() {
      http.get(Uri.parse('http://iocontrol.ru/api/sendData/flymobile1/aa/1')).then((response) {
        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");
      }).catchError((error){
        print("Error: $error");
      });
    });
  }
  void _getBitovkaLampRequestOFFaa() {
    setState(() {
      http.get(Uri.parse('http://iocontrol.ru/api/sendData/flymobile1/aa/0')).then((response) {
        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");
      }).catchError((error){
        print("Error: $error");
      });
    });
  }

  void _getBitovkaLampRequestONbb() {
    setState(() {
      http.get(Uri.parse('http://iocontrol.ru/api/sendData/flymobile1/bb/1')).then((response) {
        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");
      }).catchError((error){
        print("Error: $error");
      });
    });
  }
  void _getBitovkaLampRequestOFFbb() {
    setState(() {
      http.get(Uri.parse('http://iocontrol.ru/api/sendData/flymobile1/bb/0')).then((response) {
        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");
      }).catchError((error){
        print("Error: $error");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'choose your fighter',
            ),
            SizedBox(height: 8),
            ElevatedButton(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),

              ),
              onPressed: _getBitovkaLampRequestONaa,
              child: Text('aa on'),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              ),
              onPressed: _getBitovkaLampRequestOFFaa,
              child: Text('aa off'),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              ),
              onPressed: _getBitovkaLampRequestONbb,
              child: Text('bb on'),
            ),
            SizedBox(height: 8),
            ElevatedButton( // <------------------ Step3
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              ),
              onPressed: _getBitovkaLampRequestOFFbb,
              child: Text('bb off'),
            )
          ],
        ),
      ),
    );
  }
}