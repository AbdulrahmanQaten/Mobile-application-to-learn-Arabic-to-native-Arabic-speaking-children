import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/advanced/drawing_canvas.dart';

/// محلل الكتابة اليدوية - بدون إنترنت
class HandwritingAnalyzer {
  /// تحليل الرسم ومقارنته بالحرف المطلوب
  static HandwritingResult analyze(
    List<DrawingPoint> drawnPoints,
    String targetLetter,
  ) {
    // إزالة النقاط الفارغة
    final validPoints = drawnPoints
        .where((p) => p.offset != Offset.zero)
        .map((p) => p.offset)
        .toList();

    if (validPoints.isEmpty) {
      return HandwritingResult(
        letterId: targetLetter,
        accuracy: 0.0,
        drawnPoints: [],
        isPassed: false,
        feedback: 'لم يتم الرسم',
      );
    }

    // يجب أن يكون هناك على الأقل 20 نقطة
    if (validPoints.length < 20) {
      return HandwritingResult(
        letterId: targetLetter,
        accuracy: 0.0,
        drawnPoints: validPoints,
        isPassed: false,
        feedback: 'الرسم قصير جداً! حاول مرة أخرى',
      );
    }

    // حساب المقاييس الأساسية
    final bounds = _calculateBounds(validPoints);
    final pointCount = validPoints.length;
    final coverage = _calculateCoverage(validPoints, bounds);

    // خوارزمية بسيطة للتحقق
    double accuracy = 0.0;

    // 1. التحقق من عدد النقاط (40%)
    final expectedPointCount = _getExpectedPointCount(targetLetter);
    final pointScore = _calculatePointScore(pointCount, expectedPointCount);
    accuracy += pointScore * 0.4;

    // 2. التحقق من التغطية (30%)
    final coverageScore = coverage.clamp(0.0, 1.0);
    accuracy += coverageScore * 0.3;

    // 3. التحقق من الاتجاه (30%)
    final directionScore = _calculateDirectionScore(validPoints, targetLetter);
    accuracy += directionScore * 0.3;

    final isPassed = accuracy >= 0.65; // 65% للنجاح

    return HandwritingResult(
      letterId: targetLetter,
      accuracy: accuracy,
      drawnPoints: validPoints,
      isPassed: isPassed,
      feedback: _getFeedback(accuracy),
    );
  }

  /// حساب حدود الرسم
  static Rect _calculateBounds(List<Offset> points) {
    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;

    for (final point in points) {
      minX = min(minX, point.dx);
      minY = min(minY, point.dy);
      maxX = max(maxX, point.dx);
      maxY = max(maxY, point.dy);
    }

    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  /// حساب نسبة التغطية
  static double _calculateCoverage(List<Offset> points, Rect bounds) {
    final area = bounds.width * bounds.height;
    if (area == 0) return 0.0;

    // تقدير بسيط بناءً على عدد النقاط والمساحة
    final density = points.length / area;
    return (density * 1000).clamp(0.0, 1.0);
  }

  /// عدد النقاط المتوقع لكل حرف
  static int _getExpectedPointCount(String letter) {
    // تقديرات بسيطة
    final simpleLetters = ['ا', 'د', 'ذ', 'ر', 'ز', 'و'];
    final mediumLetters = ['ب', 'ت', 'ث', 'ن', 'ي', 'ل', 'ك'];
    final complexLetters = [
      'ج',
      'ح',
      'خ',
      'س',
      'ش',
      'ص',
      'ض',
      'ط',
      'ظ',
      'ع',
      'غ',
      'ف',
      'ق',
      'م',
      'ه'
    ];

    if (simpleLetters.contains(letter)) return 30;
    if (mediumLetters.contains(letter)) return 50;
    if (complexLetters.contains(letter)) return 80;
    return 50; // افتراضي
  }

  /// حساب نقاط عدد النقاط
  static double _calculatePointScore(int actual, int expected) {
    final diff = (actual - expected).abs();
    final ratio = 1.0 - (diff / expected);
    return ratio.clamp(0.0, 1.0);
  }

  /// حساب نقاط الاتجاه
  static double _calculateDirectionScore(List<Offset> points, String letter) {
    if (points.length < 2) return 0.0;

    // حساب الاتجاه العام
    final start = points.first;
    final end = points.last;
    final dx = end.dx - start.dx;

    // الحروف التي تبدأ من اليمين لليسار
    final rightToLeft = [
      'ب',
      'ت',
      'ث',
      'ن',
      'ي',
      'س',
      'ش',
      'ص',
      'ض',
      'ط',
      'ظ',
      'ف',
      'ق',
      'ك',
      'ل',
      'م',
      'ه'
    ];

    if (rightToLeft.contains(letter)) {
      // يجب أن يكون dx سالب (من اليمين لليسار)
      return dx < 0 ? 1.0 : 0.5;
    }

    return 0.8; // افتراضي للحروف الأخرى
  }

  /// الحصول على تغذية راجعة
  static String _getFeedback(double accuracy) {
    if (accuracy >= 0.9) return 'ممتاز جداً! 🌟';
    if (accuracy >= 0.8) return 'رائع! 🎉';
    if (accuracy >= 0.7) return 'جيد جداً! 👍';
    if (accuracy >= 0.6) return 'جيد! ✨';
    if (accuracy >= 0.5) return 'حاول مرة أخرى 💪';
    return 'تحتاج لمزيد من التدريب 📝';
  }
}

/// نتيجة تحليل الكتابة اليدوية
class HandwritingResult {
  final String letterId;
  final double accuracy;
  final List<Offset> drawnPoints;
  final bool isPassed;
  final String feedback;

  const HandwritingResult({
    required this.letterId,
    required this.accuracy,
    required this.drawnPoints,
    required this.isPassed,
    required this.feedback,
  });
}
