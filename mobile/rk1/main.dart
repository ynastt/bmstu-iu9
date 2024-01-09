import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('RK1 - Leap Year Checker'),
        ),
        body: Center(
          child: LeapYearPainter(),
        ),
      ),
    );
  }
}

class LeapYearPainter extends StatefulWidget {
  @override
  _LeapYearPainterState createState() => _LeapYearPainterState();
}

class _LeapYearPainterState extends State<LeapYearPainter> {
  final TextEditingController _yearController = TextEditingController();
  int _inputYear = 0; // default

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        TextFormField(
          controller: _yearController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: 'Enter a year'),
          onChanged: (value) {
            setState(() {
              _inputYear = int.tryParse(value) ?? 0; // default val if parsing failed
            });
          },
        ),
        SizedBox(height: 40),
        CustomPaint(
          size: Size(100, 100),
          painter: LeapYearCustomPainter(_inputYear),
        ),
      ],
    );
  }
}

class LeapYearCustomPainter extends CustomPainter {
  final int year;

  LeapYearCustomPainter(this.year);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();

    if (year % 4 == 0 && (year % 100 != 0 || year % 400 == 0)) {
      paint.color = Colors.green; // for leap years
      TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: year.toString(),
          style: TextStyle(color: Colors.green, fontSize: 40),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );

      textPainter.layout(minWidth: 0, maxWidth: size.width);
      textPainter.paint(canvas, Offset((size.width - textPainter.width) / 2, (size.height - textPainter.height) / 2));
    } else {
      paint.color = Colors.red; // for non-leap years
      TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: year.toString(),
          style: TextStyle(color: Colors.red, fontSize: 40),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );

      textPainter.layout(minWidth: 0, maxWidth: size.width);
      textPainter.paint(canvas, Offset((size.width - textPainter.width) / 2, (size.height - textPainter.height) / 2));
    }
  }

  @override
  bool shouldRepaint(LeapYearCustomPainter old) => false;
}
