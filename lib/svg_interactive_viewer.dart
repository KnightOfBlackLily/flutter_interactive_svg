import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

extension ExtendedDrawableRoot on DrawableRoot {
  bool setShapeChildren(String id, DrawableShape shape,
      [bool insertNotExist = false]) {
    int index = children
        .indexWhere((element) => element.id == id && element is DrawableShape);
    if (index == -1) {
      if (!insertNotExist) return false;
      children.add(shape);
    } else {
      children[index] = shape;
    }
    return true;
  }

  String firstId(Offset point) {
    return children.firstWhere((element) {
      if (element.id?.isEmpty ?? true) return false;
      if (element is DrawableShape) {
        return element.path.contains(point);
      }
      return false;
    }, orElse: () => null)?.id;
  }

  DrawableRoot copy() {
    var chilrdrenCopy = children
        .map(
            (e) => (e is DrawableStyleable) ? e.mergeStyle(DrawableStyle()) : e)
        .toList();
    return DrawableRoot(
      id,
      viewport,
      chilrdrenCopy,
      definitions,
      style,
      transform: transform,
    );
  }
}

class SVGPainter extends CustomPainter {
  final DrawableRoot svg;
  SVGPainter(this.svg);

  @override
  void paint(Canvas canvas, Size size) {
    svg.scaleCanvasToViewBox(canvas, size);
    svg.clipCanvasToViewBox(canvas);
    svg.draw(canvas, Rect.fromLTWH(0, 0, size.width, size.height));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class SvgInteractiveViewer extends StatefulWidget {
  final double maxScale;
  final DrawableRoot svgRoot;
  final Map<String, DrawableStyle> shapeStyles;

  final void Function(String id) onShapeTap;

  SvgInteractiveViewer({
    Key key,
    this.maxScale = 2,
    @required this.svgRoot,
    this.shapeStyles,
    this.onShapeTap,
  }) : super(key: key);

  @override
  _SvgInteractiveViewerState createState() => _SvgInteractiveViewerState();
}

class _SvgInteractiveViewerState extends State<SvgInteractiveViewer> {
  final TransformationController controller = TransformationController();

  DrawableRoot svgRoot;

  @override
  void initState() {
    super.initState();
    prepareSvg();
  }

  void prepareSvg() {
    svgRoot = widget.svgRoot.copy();
    var children = widget.svgRoot.children;
    children.forEach((element) {
      if ((element.id?.isNotEmpty ?? false) &&
          element is DrawableShape &&
          widget.shapeStyles.containsKey(element.id)) {
        svgRoot.setShapeChildren(
          element.id,
          element.mergeStyle(widget.shapeStyles[element.id]),
        );
      }
    });
  }

  @override
  void didUpdateWidget(covariant SvgInteractiveViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    prepareSvg();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) => SizedBox(
        height: constraints.maxHeight,
        width: constraints.maxWidth,
        child: GestureDetector(
          onTapDown: (details) =>
              viewportOnTap(details.localPosition, constraints.biggest),
          child: InteractiveViewer(
            maxScale: widget.maxScale,
            scaleEnabled: true,
            panEnabled: true,
            transformationController: controller,
            child: CustomPaint(
              painter: SVGPainter(svgRoot),
            ),
          ),
        ),
      ),
    );
  }

  void viewportOnTap(Offset origin, Size viewportSize) {
    print('origin: $origin');

    var transformedOrigin = controller.toScene(origin);
    var delta = min(
      viewportSize.height / svgRoot.viewport.height,
      viewportSize.width / svgRoot.viewport.width,
    );
    var x0 = viewportSize.width / 2 - svgRoot.viewport.width * delta / 2;
    var y0 = viewportSize.height / 2 - svgRoot.viewport.height * delta / 2;
    print('x0: $x0, y0: $y0');

    var offsetPoint =
        Offset(transformedOrigin.dx - x0, transformedOrigin.dy - y0);
    print('offsetPoint: $offsetPoint');

    var scaledPoint = offsetPoint.scale(1 / delta, 1 / delta);
    print('scaledPoint: $scaledPoint');

    var id = svgRoot.firstId(scaledPoint);
    print('id: $id');
    if (id?.isNotEmpty ?? false) widget?.onShapeTap(id);
  }
}
