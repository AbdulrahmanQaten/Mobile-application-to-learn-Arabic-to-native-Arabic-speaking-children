import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/advanced/drawing_canvas.dart';

/// محلل الكتابة اليدوية - محسن للحروف العربية
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

    // يجب أن يكون هناك على الأقل 30 نقطة
    if (validPoints.length < 30) {
      return HandwritingResult(
        letterId: targetLetter,
        accuracy: 0.0,
        drawnPoints: validPoints,
        isPassed: false,
        feedback: 'الرسم قصير جداً! تحتاج لرسم الحرف بشكل كامل',
      );
    }

    // حساب المقاييس الأساسية
    final bounds = _calculateBounds(validPoints);
    final pointCount = validPoints.length;

    // التحقق من حجم الرسم الأدنى
    if (bounds.width < 50 || bounds.height < 50) {
      return HandwritingResult(
        letterId: targetLetter,
        accuracy: 0.2,
        drawnPoints: validPoints,
        isPassed: false,
        feedback: 'الرسم صغير جداً! حاول رسم الحرف بحجم أكبر',
      );
    }

    double accuracy = 0.0;
    final letterInfo = _getLetterInfo(targetLetter);

    // 1. التحقق من عدد النقاط (20%)
    final expectedPointCount = letterInfo['expectedPoints'] as int;
    final pointScore = _calculatePointScore(pointCount, expectedPointCount);
    accuracy += pointScore * 0.20;

    // 2. التحقق من نسبة الأبعاد (15%)
    final aspectRatio = bounds.width / max(bounds.height, 1);
    final expectedRatio = letterInfo['aspectRatio'] as double;
    final ratioScore = _calculateRatioScore(aspectRatio, expectedRatio);
    accuracy += ratioScore * 0.15;

    // 3. التحقق من التغطية والكثافة (20%)
    final coverage = _calculateCoverage(validPoints, bounds);
    final expectedCoverage = letterInfo['coverage'] as double;
    final coverageScore = _calculateCoverageScore(coverage, expectedCoverage);
    accuracy += coverageScore * 0.20;

    // 4. التحقق من الاتجاه الأساسي (15%)
    final directionScore = _calculateDirectionScore(validPoints, targetLetter);
    accuracy += directionScore * 0.15;

    // 5. التحقق من الانحناءات (15%)
    final curvatureScore = _calculateCurvatureScore(validPoints, targetLetter);
    accuracy += curvatureScore * 0.15;

    // 6. التحقق من عدد الخطوط/الأجزاء (15%)
    final strokesScore = _calculateStrokesScore(drawnPoints, targetLetter);
    accuracy += strokesScore * 0.15;

    // نسبة النجاح 75% بدلاً من 65%
    final isPassed = accuracy >= 0.75;

    return HandwritingResult(
      letterId: targetLetter,
      accuracy: accuracy,
      drawnPoints: validPoints,
      isPassed: isPassed,
      feedback: _getFeedback(accuracy, targetLetter),
    );
  }

  /// معلومات كل حرف
  static Map<String, dynamic> _getLetterInfo(String letter) {
    // الحروف البسيطة (خط واحد مستقيم أو منحني بسيط)
    final simpleLetters = {
      'ا': {
        'expectedPoints': 40,
        'aspectRatio': 0.2,
        'coverage': 0.15,
        'strokes': 1
      },
      'د': {
        'expectedPoints': 50,
        'aspectRatio': 1.2,
        'coverage': 0.25,
        'strokes': 1
      },
      'ذ': {
        'expectedPoints': 60,
        'aspectRatio': 1.2,
        'coverage': 0.25,
        'strokes': 2
      },
      'ر': {
        'expectedPoints': 45,
        'aspectRatio': 0.8,
        'coverage': 0.20,
        'strokes': 1
      },
      'ز': {
        'expectedPoints': 55,
        'aspectRatio': 0.8,
        'coverage': 0.20,
        'strokes': 2
      },
      'و': {
        'expectedPoints': 50,
        'aspectRatio': 0.9,
        'coverage': 0.30,
        'strokes': 1
      },
    };

    // الحروف المتوسطة (خط مع نقاط)
    final mediumLetters = {
      'ب': {
        'expectedPoints': 70,
        'aspectRatio': 2.5,
        'coverage': 0.25,
        'strokes': 2
      },
      'ت': {
        'expectedPoints': 75,
        'aspectRatio': 2.5,
        'coverage': 0.25,
        'strokes': 3
      },
      'ث': {
        'expectedPoints': 80,
        'aspectRatio': 2.5,
        'coverage': 0.25,
        'strokes': 4
      },
      'ن': {
        'expectedPoints': 65,
        'aspectRatio': 2.0,
        'coverage': 0.30,
        'strokes': 2
      },
      'ي': {
        'expectedPoints': 75,
        'aspectRatio': 2.0,
        'coverage': 0.30,
        'strokes': 3
      },
      'ل': {
        'expectedPoints': 60,
        'aspectRatio': 0.5,
        'coverage': 0.20,
        'strokes': 1
      },
      'ك': {
        'expectedPoints': 75,
        'aspectRatio': 1.5,
        'coverage': 0.30,
        'strokes': 2
      },
    };

    // الحروف المعقدة (تحتوي على منحنيات أو أجزاء متعددة)
    final complexLetters = {
      'ج': {
        'expectedPoints': 80,
        'aspectRatio': 1.0,
        'coverage': 0.35,
        'strokes': 2
      },
      'ح': {
        'expectedPoints': 75,
        'aspectRatio': 1.0,
        'coverage': 0.35,
        'strokes': 1
      },
      'خ': {
        'expectedPoints': 85,
        'aspectRatio': 1.0,
        'coverage': 0.35,
        'strokes': 2
      },
      'س': {
        'expectedPoints': 90,
        'aspectRatio': 3.0,
        'coverage': 0.30,
        'strokes': 1
      },
      'ش': {
        'expectedPoints': 100,
        'aspectRatio': 3.0,
        'coverage': 0.30,
        'strokes': 4
      },
      'ص': {
        'expectedPoints': 85,
        'aspectRatio': 2.0,
        'coverage': 0.35,
        'strokes': 1
      },
      'ض': {
        'expectedPoints': 95,
        'aspectRatio': 2.0,
        'coverage': 0.35,
        'strokes': 2
      },
      'ط': {
        'expectedPoints': 80,
        'aspectRatio': 1.5,
        'coverage': 0.40,
        'strokes': 1
      },
      'ظ': {
        'expectedPoints': 90,
        'aspectRatio': 1.5,
        'coverage': 0.40,
        'strokes': 2
      },
      'ع': {
        'expectedPoints': 85,
        'aspectRatio': 1.2,
        'coverage': 0.40,
        'strokes': 1
      },
      'غ': {
        'expectedPoints': 95,
        'aspectRatio': 1.2,
        'coverage': 0.40,
        'strokes': 2
      },
      'ف': {
        'expectedPoints': 80,
        'aspectRatio': 2.0,
        'coverage': 0.35,
        'strokes': 2
      },
      'ق': {
        'expectedPoints': 85,
        'aspectRatio': 1.8,
        'coverage': 0.35,
        'strokes': 3
      },
      'م': {
        'expectedPoints': 75,
        'aspectRatio': 1.5,
        'coverage': 0.40,
        'strokes': 1
      },
      'ه': {
        'expectedPoints': 70,
        'aspectRatio': 1.0,
        'coverage': 0.45,
        'strokes': 1
      },
      'هـ': {
        'expectedPoints': 70,
        'aspectRatio': 1.0,
        'coverage': 0.45,
        'strokes': 1
      },
    };

    if (simpleLetters.containsKey(letter)) {
      return simpleLetters[letter]!;
    } else if (mediumLetters.containsKey(letter)) {
      return mediumLetters[letter]!;
    } else if (complexLetters.containsKey(letter)) {
      return complexLetters[letter]!;
    }

    // افتراضي
    return {
      'expectedPoints': 70,
      'aspectRatio': 1.5,
      'coverage': 0.30,
      'strokes': 1
    };
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

    // تقسيم المنطقة إلى شبكة 10x10
    final gridSize = 10;
    final cellWidth = bounds.width / gridSize;
    final cellHeight = bounds.height / gridSize;
    final coveredCells = <String>{};

    for (final point in points) {
      final cellX =
          ((point.dx - bounds.left) / cellWidth).floor().clamp(0, gridSize - 1);
      final cellY =
          ((point.dy - bounds.top) / cellHeight).floor().clamp(0, gridSize - 1);
      coveredCells.add('$cellX,$cellY');
    }

    return coveredCells.length / (gridSize * gridSize);
  }

  /// حساب نقاط عدد النقاط
  static double _calculatePointScore(int actual, int expected) {
    final diff = (actual - expected).abs();
    final ratio = 1.0 - (diff / expected);
    return ratio.clamp(0.0, 1.0);
  }

  /// حساب نقاط نسبة الأبعاد
  static double _calculateRatioScore(double actual, double expected) {
    final diff = (actual - expected).abs();
    final ratio = 1.0 - (diff / max(expected, 1));
    return ratio.clamp(0.0, 1.0);
  }

  /// حساب نقاط التغطية
  static double _calculateCoverageScore(double actual, double expected) {
    // نريد تغطية قريبة من المتوقعة
    final diff = (actual - expected).abs();
    final ratio = 1.0 - (diff / max(expected, 0.1));
    return ratio.clamp(0.0, 1.0);
  }

  /// حساب نقاط الاتجاه
  static double _calculateDirectionScore(List<Offset> points, String letter) {
    if (points.length < 2) return 0.0;

    // حساب الاتجاه العام
    final start = points.first;
    final end = points.last;
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;

    // الحروف الرأسية (تُرسم من أعلى لأسفل)
    final verticalLetters = ['ا', 'ل', 'ك', 'ط', 'ظ'];
    if (verticalLetters.contains(letter)) {
      return dy > 0 ? 1.0 : 0.4; // من أعلى لأسفل
    }

    // الحروف الأفقية (تُرسم من اليمين لليسار)
    final horizontalLetters = ['ب', 'ت', 'ث', 'ن', 'ي', 'س', 'ش', 'ص', 'ض'];
    if (horizontalLetters.contains(letter)) {
      return dx < 0 ? 1.0 : 0.5; // من اليمين لليسار
    }

    // الحروف الدائرية
    final circularLetters = ['و', 'ه', 'هـ', 'م', 'ف', 'ق'];
    if (circularLetters.contains(letter)) {
      // التحقق من وجود انحناء كبير
      final curvature = _calculateOverallCurvature(points);
      return curvature > 0.3 ? 1.0 : 0.5;
    }

    return 0.7; // افتراضي
  }

  /// حساب الانحناء الكلي
  static double _calculateOverallCurvature(List<Offset> points) {
    if (points.length < 3) return 0.0;

    double totalCurvature = 0.0;
    int count = 0;

    for (int i = 1; i < points.length - 1; i += 5) {
      final p1 = points[i - 1];
      final p2 = points[i];
      final p3 = points[min(i + 1, points.length - 1)];

      final v1 = Offset(p2.dx - p1.dx, p2.dy - p1.dy);
      final v2 = Offset(p3.dx - p2.dx, p3.dy - p2.dy);

      final dot = v1.dx * v2.dx + v1.dy * v2.dy;
      final cross = v1.dx * v2.dy - v1.dy * v2.dx;
      final angle = atan2(cross, dot).abs();

      totalCurvature += angle;
      count++;
    }

    return count > 0 ? (totalCurvature / count) / pi : 0.0;
  }

  /// حساب نقاط الانحناءات
  static double _calculateCurvatureScore(List<Offset> points, String letter) {
    final curvature = _calculateOverallCurvature(points);

    // الحروف المستقيمة
    final straightLetters = ['ا', 'ل'];
    if (straightLetters.contains(letter)) {
      return curvature < 0.2 ? 1.0 : 0.5;
    }

    // الحروف المنحنية
    final curvedLetters = ['و', 'ه', 'هـ', 'م', 'ج', 'ح', 'خ', 'ع', 'غ'];
    if (curvedLetters.contains(letter)) {
      return curvature > 0.3 ? 1.0 : 0.5;
    }

    // الحروف المتوسطة
    return curvature > 0.1 && curvature < 0.5 ? 1.0 : 0.6;
  }

  /// حساب عدد الخطوط/الأجزاء
  static double _calculateStrokesScore(
      List<DrawingPoint> drawnPoints, String letter) {
    // حساب عدد الخطوط المنفصلة (عندما تكون النقطة Offset.zero)
    int strokes = 1;
    bool wasZero = false;

    for (final point in drawnPoints) {
      if (point.offset == Offset.zero) {
        wasZero = true;
      } else if (wasZero) {
        strokes++;
        wasZero = false;
      }
    }

    final letterInfo = _getLetterInfo(letter);
    final expectedStrokes = letterInfo['strokes'] as int;

    // إذا كان عدد الخطوط مطابقاً أو قريباً
    final diff = (strokes - expectedStrokes).abs();
    if (diff == 0) return 1.0;
    if (diff == 1) return 0.7;
    return 0.4;
  }

  /// الحصول على تغذية راجعة
  static String _getFeedback(double accuracy, String letter) {
    if (accuracy >= 0.90) return 'ممتاز جداً! كتابة رائعة 🌟';
    if (accuracy >= 0.85) return 'ممتاز! أحسنت 🎉';
    if (accuracy >= 0.80) return 'جيد جداً! 👍';
    if (accuracy >= 0.75) return 'جيد! استمر ✨';
    if (accuracy >= 0.65) return 'قريب! حاول رسم حرف "$letter" بشكل أوضح 💪';
    if (accuracy >= 0.50) return 'حاول رسم الحرف بالشكل الصحيح 📝';
    return 'هذا لا يشبه حرف "$letter". حاول مرة أخرى ✏️';
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
