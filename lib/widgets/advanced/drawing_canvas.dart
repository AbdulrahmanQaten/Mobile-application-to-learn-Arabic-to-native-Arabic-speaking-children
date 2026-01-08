import 'package:flutter/material.dart';

/// نموذج لنقطة الرسم
class DrawingPoint {
  final Offset offset;
  final Paint paint;

  DrawingPoint({required this.offset, required this.paint});
}

/// لوحة الرسم للكتابة اليدوية
class DrawingCanvas extends StatefulWidget {
  final Function(List<DrawingPoint>) onDrawingComplete;
  final Color strokeColor;
  final double strokeWidth;

  const DrawingCanvas({
    super.key,
    required this.onDrawingComplete,
    this.strokeColor = Colors.black,
    this.strokeWidth = 5.0,
  });

  @override
  State<DrawingCanvas> createState() => DrawingCanvasState();
}

// State class is public so it can be accessed via GlobalKey
class DrawingCanvasState extends State<DrawingCanvas> {
  final List<DrawingPoint> _points = [];

  void clearDrawing() {
    setState(() {
      _points.clear();
    });
    widget.onDrawingComplete([]);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        setState(() {
          _points.add(
            DrawingPoint(
              offset: details.localPosition,
              paint: Paint()
                ..color = widget.strokeColor
                ..strokeWidth = widget.strokeWidth
                ..strokeCap = StrokeCap.round,
            ),
          );
        });
      },
      onPanUpdate: (details) {
        setState(() {
          _points.add(
            DrawingPoint(
              offset: details.localPosition,
              paint: Paint()
                ..color = widget.strokeColor
                ..strokeWidth = widget.strokeWidth
                ..strokeCap = StrokeCap.round,
            ),
          );
        });
      },
      onPanEnd: (details) {
        // إضافة null للفصل بين الخطوط
        setState(() {
          _points.add(
            DrawingPoint(
              offset: Offset.zero,
              paint: Paint(),
            ),
          );
        });
        widget.onDrawingComplete(_points);
      },
      child: CustomPaint(
        painter: _DrawingPainter(points: _points),
        size: Size.infinite,
      ),
    );
  }
}

/// رسام مخصص لعرض الخطوط
class _DrawingPainter extends CustomPainter {
  final List<DrawingPoint> points;

  _DrawingPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i].offset != Offset.zero &&
          points[i + 1].offset != Offset.zero) {
        canvas.drawLine(
          points[i].offset,
          points[i + 1].offset,
          points[i].paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
