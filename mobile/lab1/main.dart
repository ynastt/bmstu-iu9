// Вариант 24
// Ромб, диагонали которого имеют величины a и b
// и рисуются по желанию
// пользователя выбранным пользователем цветом.
import 'package:flutter/material.dart';
import 'dart:ui';

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
          title: Text('lab1 - Flutter Custom Drawer'),
        ),
        body: Center(
          child: DiamondPainter(),
        ),
      ),
    );
  }
}

class DiamondPainter extends StatefulWidget {
  @override
  _DiamondPainterState createState() => _DiamondPainterState();
}

class _DiamondPainterState extends State<DiamondPainter> {
  // TextEditingController _diagonalAController = TextEditingController();
  // TextEditingController _diagonalBController = TextEditingController();
  var _diagA = 100.0;
  var _diagB = 100.0;
  Color _selectedColor = Colors.black;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('Diagonal A'),
        Slider(
          value: _diagA,
          min: 100.0,
          max: 700.0,
          label: _diagA.toInt().toString(),
          divisions: 10,
          onChanged: (value) {
            setState(() {
              _diagA = value;
            });
          },
        ),
        SizedBox(height:10),
        Text('Diagonal B'),
        Slider(
          value: _diagB,
          min: 100.0,
          max: 700.0,
          label: _diagB.toInt().toString(),
          divisions: 10,
          onChanged: (value) {
            setState(() {
              _diagB = value;
            });
          },
        ),
        SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red,),
                onPressed: () {
                  setState(() {
                    _selectedColor = Colors.red;
                  });
                },
              child: const Text("red"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue,),
              onPressed: () {
                setState(() {
                  _selectedColor = Colors.blue;
                });
              },
              child: const Text("blue"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.lightGreenAccent,),
              onPressed: () {
                setState(() {
                  _selectedColor = Colors.lightGreenAccent;
                });
              },
              child: const Text("green"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow,),
              onPressed: () {
                setState(() {
                  _selectedColor = Colors.yellow;
                });
              },
              child: const Text("yellow"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.pink.shade200,),
              onPressed: () {
                setState(() {
                  _selectedColor = Colors.pink.shade200;
                });
              },
              child: const Text("pink"),
            ),
          ],
        ),


        SizedBox(height: 20),
        CustomPaint(
          size: Size(200, 200),
          painter: DiamondCustomPainter(
            _diagA,
            _diagB,
            _selectedColor,
          ),
        ),
      ],
    );
  }

  void _updateColor(Color color) {
    setState(() {
      _selectedColor = color;
    });
  }
}

class DiamondCustomPainter extends CustomPainter {
  final double diagonalA;
  final double diagonalB;
  final Color color;

  DiamondCustomPainter(this.diagonalA, this.diagonalB, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    var path = Path();

    Offset center = Offset(size.width / 2, size.height / 2);
    // diag A left corner point
    Offset start = Offset(center.dx - diagonalA / 2.0, center.dy);


    path.moveTo(start.dx, start.dy);

    // diag B right corner point    
    path.lineTo(center.dx, center.dy + diagonalB / 2.0);
    //   diag A right  corner point
    path.lineTo(center.dx + diagonalA / 2.0, center.dy);
    //  diag B left  corner point   
    path.lineTo(center.dx, center.dy - diagonalB / 2.0);
    // diag A left corner point     
    path.lineTo(start.dx, start.dy);
    
    // diagonals
    //  A   
    path.lineTo(center.dx + diagonalA / 2.0, center.dy);
    //  B
    path.lineTo(center.dx, center.dy - diagonalB / 2.0);
    path.lineTo(center.dx, center.dy + diagonalB / 2.0);

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
