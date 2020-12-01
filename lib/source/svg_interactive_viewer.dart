import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

part 'extended_drawable.dart';

class _SVGPainter extends CustomPainter {
  final DrawableRoot svg;
  _SVGPainter(this.svg);

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
    _prepareSvg();
  }

  void _prepareSvg() {
    svgRoot = widget.svgRoot.copyRoot();
    widget.shapeStyles
        .forEach((key, style) => svgRoot.applyChildStyle(key, style));
  }

  @override
  void didUpdateWidget(covariant SvgInteractiveViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    _prepareSvg();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) => SizedBox(
        height: constraints.maxHeight,
        width: constraints.maxWidth,
        child: GestureDetector(
          onTapDown: (details) =>
              _viewportOnTap(details.localPosition, constraints.biggest),
          child: InteractiveViewer(
            maxScale: widget.maxScale,
            scaleEnabled: true,
            panEnabled: true,
            transformationController: controller,
            child: CustomPaint(
              painter: _SVGPainter(svgRoot),
            ),
          ),
        ),
      ),
    );
  }

  void _viewportOnTap(Offset origin, Size viewportSize) {
    var transformedOrigin = controller.toScene(origin);
    var delta = min(
      viewportSize.height / svgRoot.viewport.height,
      viewportSize.width / svgRoot.viewport.width,
    );
    var x0 = viewportSize.width / 2 - svgRoot.viewport.width * delta / 2;
    var y0 = viewportSize.height / 2 - svgRoot.viewport.height * delta / 2;

    var offsetPoint =
        Offset(transformedOrigin.dx - x0, transformedOrigin.dy - y0);

    var scaledPoint = offsetPoint.scale(1 / delta, 1 / delta);

    var id = svgRoot.firstShapeId(scaledPoint);
    if (id?.isNotEmpty ?? false) widget?.onShapeTap(id);
  }
}
