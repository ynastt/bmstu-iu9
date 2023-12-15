// Реализовать приложение моделирования движения глаз человека влево и вправо,
// модель головы человека можно взять из лекции.
// Движение глаз реализовывается ползунком.

import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_cube/flutter_cube.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'lab3',
      theme: ThemeData.dark(),
      home: MyHomePage(title: 'lab3'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  late Scene _scene;
  Object? _face;
  Object? _eyes;
  late AnimationController _controller;
  double _ambient = 0.1;
  double _diffuse = 0.8;
  double _specular = 0.5;
  double _shininess = 0.0;

  double x1 = 0.0;
  double y1 = 0.0;

  final Object eye1 = Object(
    scale: Vector3(0.5, 0.5, 0.5),
    position: Vector3(0.2, 0.9, 0.5)..scale(3),
    lighting: true,
    fileName: 'assets/Eyeball/eyeball.obj',
  );

  final Object eye2 = Object(
    scale: Vector3(0.5, 0.5, 0.5),
    position: Vector3(-0.2, 0.9, 0.5)..scale(3),
    lighting: true,
    fileName: 'assets/Eyeball/eyeball.obj',
  );

  void _onSceneCreated(Scene scene) {
    _scene = scene;
    scene.camera.position.z = 10;
    scene.light.position.setFrom(Vector3(0, 10, 10));
    scene.light.setColor(Colors.white, _ambient, _diffuse, _specular);
//    _bunny = Object(position: Vector3(0, -1.0, 0), scale: Vector3(10.0, 10.0, 10.0), lighting: true, fileName: 'assets/skull/12140_Skull_v3_L2.obj');
    _face = Object(
        position: Vector3(0, 0, 0),
        scale: Vector3(10.0, 10.0, 10.0),
        lighting: true,
        fileName: 'assets/face/face.obj');

    _eyes = Object();
    _eyes!.add(eye1);
    _eyes!.add(eye2);

    _face!.lighting = true;
    _eyes!.lighting = true;

    scene.world.add(_face!);
    scene.world.add(_eyes!);
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: Duration(milliseconds: 30000), vsync: this)
      ..addListener(() {
        // if (_face != null) {
        //   _face!.rotation.y = _controller.value * 360;
        //   _face!.updateTransform();
        //   _scene.update();
        // }

        // if (_eyes != null) {
        //   _eyes!.rotation.y = _controller.value * 360;
        //   _eyes!.updateTransform();
        //   _scene.update();
        // }
      })
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title!),
      ),
      body: Stack(
        children: <Widget>[
          Cube(onSceneCreated: _onSceneCreated),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Flexible(flex: 2, child: Text('Eyes up/down')),
                  Flexible(
                    flex: 8,
                    child: Slider(
                      value: x1,
                      min: -45.0,
                      max: 45.0,
                      // divisions: 32,
                      onChanged: (value) {
                        setState(() {
                          x1 = value;
                          eye1.rotation.x = x1;
                          eye1.updateTransform();
                          eye2.rotation.x = x1;
                          eye2.updateTransform();
                        });
                      },
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Flexible(flex: 2, child: Text('Eyes left/right')),
                  Flexible(
                    flex: 8,
                    child: Slider(
                      value: y1,
                      min: -45.0,
                      max: 45.0,
                      // divisions: 32,
                      onChanged: (value) {
                        setState(() {
                          y1 = value;
                          eye1.rotation.y = y1;
                          eye1.updateTransform();
                          eye2.rotation.y = y1;
                          eye2.updateTransform();
                        });
                      },
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Flexible(flex: 2, child: Text('diffuse')),
                  Flexible(
                    flex: 8,
                    child: Slider(
                      value: _diffuse,
                      min: 0.0,
                      max: 1.0,
                      divisions: 100,
                      onChanged: (value) {
                        setState(() {
                          _diffuse = value;
                          _scene.light.setColor(Colors.white, _ambient, _diffuse, _specular);
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}




// // // EARTH EXAMPLE
// // void main() => runApp(MyApp());
// //
// // class MyApp extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       title: 'Planet',
// //       theme: ThemeData.dark(),
// //       home: MyHomePage(title: 'Planet'),
// //     );
// //   }
// // }
// //
// // class MyHomePage extends StatefulWidget {
// //   MyHomePage({Key? key, this.title}) : super(key: key);
// //
// //   final String? title;
// //
// //   @override
// //   _MyHomePageState createState() => _MyHomePageState();
// // }
// //
// // class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
// //   late Scene _scene;
// //   Object? _earth;
// //   late Object _stars;
// //   late AnimationController _controller;
// //
// //   void generateSphereObject(Object parent, String name, double radius, bool backfaceCulling, String texturePath) async {
// //     final Mesh mesh = await generateSphereMesh(radius: radius, texturePath: texturePath);
// //     parent.add(Object(name: name, mesh: mesh, backfaceCulling: backfaceCulling));
// //     _scene.updateTexture();
// //   }
// //
// //   void _onSceneCreated(Scene scene) {
// //     _scene = scene;
// //     _scene.camera.position.z = 16;
// //
// //     // model from https://free3d.com/3d-model/planet-earth-99065.html
// //     // _earth = Object(name: 'earth', scale: Vector3(10.0, 10.0, 10.0), backfaceCulling: true, fileName: 'assets/earth/earth.obj');
// //
// //     // create by code
// //     _earth = Object(name: 'earth', scale: Vector3(10.0, 10.0, 10.0));
// //     generateSphereObject(_earth!, 'surface', 0.485, true, 'assets/earth/4096_earth.jpg');
// //     generateSphereObject(_earth!, 'clouds', 0.5, true, 'assets/earth/4096_clouds.png');
// //     _scene.world.add(_earth!);
// //
// //     // texture from https://www.solarsystemscope.com/textures/
// //     _stars = Object(name: 'stars', scale: Vector3(2000.0, 2000.0, 2000.0));
// //     generateSphereObject(_stars, 'surface', 0.5, false, 'assets/stars/2k_stars.jpg');
// //     _scene.world.add(_stars);
// //   }
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _controller = AnimationController(duration: Duration(milliseconds: 30000), vsync: this)
// //       ..addListener(() {
// //         if (_earth != null) {
// //           _earth!.rotation.y = _controller.value * 360;
// //           _earth!.updateTransform();
// //           _scene.update();
// //         }
// //       })
// //       ..repeat();
// //   }
// //
// //   @override
// //   void dispose() {
// //     _controller.dispose();
// //     super.dispose();
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: Colors.black,
// //       body: Cube(onSceneCreated: _onSceneCreated),
// //     );
// //   }
// // }
// //
// // Future<Mesh> generateSphereMesh({num radius = 0.5, int latSegments = 32, int lonSegments = 64, required String texturePath}) async {
// //   int count = (latSegments + 1) * (lonSegments + 1);
// //   List<Vector3> vertices = List<Vector3>.filled(count, Vector3.zero());
// //   List<Offset> texcoords = List<Offset>.filled(count, Offset.zero);
// //   List<Polygon> indices = List<Polygon>.filled(latSegments * lonSegments * 2, Polygon(0, 0, 0));
// //
// //   int i = 0;
// //   for (int y = 0; y <= latSegments; ++y) {
// //     final double v = y / latSegments;
// //     final double sv = math.sin(v * math.pi);
// //     final double cv = math.cos(v * math.pi);
// //     for (int x = 0; x <= lonSegments; ++x) {
// //       final double u = x / lonSegments;
// //       vertices[i] = Vector3(radius * math.cos(u * math.pi * 2.0) * sv, radius * cv, radius * math.sin(u * math.pi * 2.0) * sv);
// //       texcoords[i] = Offset(1.0 - u, 1.0 - v);
// //       i++;
// //     }
// //   }
// //
// //   i = 0;
// //   for (int y = 0; y < latSegments; ++y) {
// //     final int base1 = (lonSegments + 1) * y;
// //     final int base2 = (lonSegments + 1) * (y + 1);
// //     for (int x = 0; x < lonSegments; ++x) {
// //       indices[i++] = Polygon(base1 + x, base1 + x + 1, base2 + x);
// //       indices[i++] = Polygon(base1 + x + 1, base2 + x + 1, base2 + x);
// //     }
// //   }
// //
// //   ui.Image texture = await loadImageFromAsset(texturePath);
// //   final Mesh mesh = Mesh(vertices: vertices, texcoords: texcoords, indices: indices, texture: texture, texturePath: texturePath);
// //   return mesh;
// // }
