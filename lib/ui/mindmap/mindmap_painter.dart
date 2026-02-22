import 'dart:math';
import 'package:flutter/material.dart';

import '../../domain/models/mindmap_node.dart';
import '../../domain/models/mindmap_edge.dart';

class EdgePainter extends CustomPainter {
  final List<MindmapNode> nodes;
  final List<MindmapEdge> edges;
  final TextDirection textDirection;
  final Color edgeColor;
  final Color labelColor;
  final Color labelBackgroundColor;

  static const double _nodeHalfWidth = 47.0;
  static const double _nodeHalfHeight = 36.0;
  static const double _nodeEdgePadding = 6.0;

  EdgePainter({
    required this.nodes,
    required this.edges,
    required this.textDirection,
    required this.edgeColor,
    required this.labelColor,
    required this.labelBackgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final edge in edges) {
      final fromNode = nodes.where((n) => n.id == edge.fromNodeId).firstOrNull;
      final toNode = nodes.where((n) => n.id == edge.toNodeId).firstOrNull;

      if (fromNode == null || toNode == null) continue;

      final from = Offset(fromNode.positionX, fromNode.positionY);
      final to = Offset(toNode.positionX, toNode.positionY);

      final start = _pointOnNodeBoundary(from, to);
      final end = _pointOnNodeBoundary(to, from);

      final dx = end.dx - start.dx;
      final dy = end.dy - start.dy;
      final len = sqrt(dx * dx + dy * dy);
      if (len == 0) continue;

      final unitX = dx / len;
      final unitY = dy / len;

      final padding = min(_nodeEdgePadding, len / 4);
      final paddedStart = start + Offset(unitX * padding, unitY * padding);
      final paddedEnd = end - Offset(unitX * padding, unitY * padding);

      // Draw edge line
      final paint = Paint()
        ..color = edgeColor
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;

      canvas.drawLine(paddedStart, paddedEnd, paint);

      // Draw arrowhead
      _drawArrow(canvas, paddedStart, paddedEnd, paint);

      // Draw label at midpoint
      if (edge.label != null && edge.label!.isNotEmpty) {
        final midpoint = Offset((paddedStart.dx + paddedEnd.dx) / 2, (paddedStart.dy + paddedEnd.dy) / 2);
        _drawLabel(canvas, midpoint, edge.label!, from, to);
      }
    }
  }

  Offset _pointOnNodeBoundary(Offset center, Offset towards) {
    final dx = towards.dx - center.dx;
    final dy = towards.dy - center.dy;

    if (dx == 0 && dy == 0) return center;

    final absDx = dx.abs();
    final absDy = dy.abs();

    final scaleX = absDx == 0 ? double.infinity : _nodeHalfWidth / absDx;
    final scaleY = absDy == 0 ? double.infinity : _nodeHalfHeight / absDy;
    final t = min(scaleX, scaleY);

    return Offset(center.dx + dx * t, center.dy + dy * t);
  }

  void _drawArrow(Canvas canvas, Offset from, Offset to, Paint paint) {
    final arrowPaint = Paint()
      ..color = edgeColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.fill;

    final dx = to.dx - from.dx;
    final dy = to.dy - from.dy;
    final len = sqrt(dx * dx + dy * dy);
    if (len == 0) return;

    final unitX = dx / len;
    final unitY = dy / len;

    final tipX = to.dx;
    final tipY = to.dy;

    const arrowLength = 12.0;
    const arrowAngle = 0.4;

    final p1 = Offset(
      tipX - arrowLength * (unitX * cos(arrowAngle) - unitY * sin(arrowAngle)),
      tipY - arrowLength * (unitY * cos(arrowAngle) + unitX * sin(arrowAngle)),
    );
    final p2 = Offset(
      tipX - arrowLength * (unitX * cos(arrowAngle) + unitY * sin(arrowAngle)),
      tipY - arrowLength * (unitY * cos(arrowAngle) - unitX * sin(arrowAngle)),
    );

    final path = Path()
      ..moveTo(tipX, tipY)
      ..lineTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..close();

    canvas.drawPath(path, arrowPaint);
  }

  void _drawLabel(Canvas canvas, Offset position, String label, Offset from, Offset to) {
    final textSpan = TextSpan(
      text: label,
      style: TextStyle(
        color: labelColor,
        fontSize: 10,
        fontWeight: FontWeight.w500,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: textDirection,
      textAlign: TextAlign.center,
    );

    textPainter.layout(maxWidth: 120);

    // Background rect
    final bgRect = Rect.fromCenter(
      center: position,
      width: textPainter.width + 10,
      height: textPainter.height + 6,
    );

    final bgPaint = Paint()
      ..color = labelBackgroundColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = edgeColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawRRect(
      RRect.fromRectAndRadius(bgRect, const Radius.circular(4)),
      bgPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bgRect, const Radius.circular(4)),
      borderPaint,
    );

    textPainter.paint(
      canvas,
      Offset(position.dx - textPainter.width / 2, position.dy - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant EdgePainter oldDelegate) {
    return oldDelegate.nodes != nodes ||
        oldDelegate.edges != edges ||
        oldDelegate.edgeColor != edgeColor ||
        oldDelegate.labelColor != labelColor ||
        oldDelegate.labelBackgroundColor != labelBackgroundColor;
  }
}
