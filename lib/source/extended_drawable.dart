part of 'svg_interactive_viewer.dart';

extension _ExtendedDrawableParent on DrawableParent {
  void applyChildStyle(String id, DrawableStyle style) {
    List<DrawableStyleable> childs = children
        .whereType<DrawableStyleable>()
        .where((element) => element.id == id)
        .toList();
    for (var child in childs) {
      children[children.indexOf(child)] = child.mergeStyle(style);
    }

    children.forEach((element) => (element is DrawableParent)
        ? element.applyChildStyle(id, style)
        : null);
  }

  String firstShapeId(Offset point) {
    for (var child in children) {
      if (child is DrawableShape &&
          (child.id?.isNotEmpty ?? false) &&
          child.path.contains(point)) {
        return child.id;
      } else if (child is DrawableParent) {
        var findId = child.firstShapeId(point);
        if (findId?.isNotEmpty ?? false) {
          return findId;
        }
      }
    }
    return null;
  }
}

extension _ExtendedDrawableGroup on DrawableGroup {
  DrawableGroup copy() {
    var childrenCopy = children.map((e) {
      if (e is DrawableGroup) {
        return e.copy();
      }
      if (e is DrawableStyleable) {
        return e.mergeStyle(DrawableStyle());
      }
      return e;
    }).toList();
    return DrawableGroup(
      id,
      childrenCopy,
      style,
      transform: transform,
    );
  }
}

extension _ExtendedDrawableRoot on DrawableRoot {
  DrawableRoot copyRoot() {
    var childrenCopy = children.map((e) {
      if (e is DrawableGroup) {
        return e.copy();
      }
      if (e is DrawableStyleable) {
        return e.mergeStyle(DrawableStyle());
      }
      return e;
    }).toList();
    return DrawableRoot(
      id,
      viewport,
      childrenCopy,
      definitions,
      style,
      transform: transform,
    );
  }
}
