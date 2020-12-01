import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/parser.dart';
import 'package:svg_test/source/svg_interactive_viewer.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DrawableRoot svg;

  TransformationController controller = TransformationController();

  List<String> selectedShapes = [];

  @override
  void initState() {
    super.initState();
    loadSvg();
  }

  Future<void> loadSvg() async {
    svg =
        await SvgParser().parse(await rootBundle.loadString('images/test.svg'));

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: svg == null
            ? SizedBox()
            : SvgInteractiveViewer(
                svgRoot: svg,
                maxScale: 4,
                onShapeTap: (id) {
                  selectedShapes.contains(id)
                      ? selectedShapes.remove(id)
                      : selectedShapes.add(id);
                  setState(() {});
                },
                shapeStyles: selectedShapes.asMap().map(
                      (key, value) => MapEntry(
                        value,
                        DrawableStyle(
                          stroke: DrawablePaint(
                            PaintingStyle.stroke,
                            color: Colors.red,
                            strokeWidth: 10,
                          ),
                          fill: DrawablePaint(
                            PaintingStyle.fill,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ),
              ),
      ),
    );
  }
}
// DrawableStyle(
//       fill: DrawablePaint(PaintingStyle.fill, color: newColor))
