import 'dart:math';
import 'dart:ui';
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart';
import '../widgets/advanced/drawing_canvas.dart';

/// خدمة التعرف على الكتابة اليدوية - نسخة محسنة
class HandwritingRecognitionService {
  static DigitalInkRecognizer? _recognizer;
  static bool _modelDownloaded = false;
  static final DigitalInkRecognizerModelManager _modelManager =
      DigitalInkRecognizerModelManager();

  /// تهيئة الخدمة وتحميل نموذج اللغة العربية
  static Future<bool> initialize() async {
    try {
      const String arabicModel = 'ar';

      _modelDownloaded = await _modelManager.isModelDownloaded(arabicModel);

      if (!_modelDownloaded) {
        print('📥 جاري تحميل نموذج اللغة العربية...');
        _modelDownloaded = await _modelManager.downloadModel(arabicModel);
        print('✅ تم تحميل النموذج: $_modelDownloaded');
      }

      if (_modelDownloaded) {
        _recognizer = DigitalInkRecognizer(languageCode: arabicModel);
        print('✅ تم تهيئة خدمة التعرف على الكتابة');
        return true;
      }

      return false;
    } catch (e) {
      print('❌ خطأ في تهيئة خدمة التعرف: $e');
      return false;
    }
  }

  static bool get isReady => _recognizer != null && _modelDownloaded;

  /// التعرف على الكتابة اليدوية
  static Future<HandwritingMLResult> recognize(
    List<DrawingPoint> drawnPoints,
    String targetLetter,
  ) async {
    // التحقق الأولي من جودة الرسم
    final validationResult = _validateDrawing(drawnPoints, targetLetter);
    if (!validationResult.isValid) {
      return HandwritingMLResult(
        recognized: '',
        accuracy: validationResult.score,
        isPassed: false,
        feedback: validationResult.message,
      );
    }

    // إذا كانت خدمة ML Kit جاهزة، استخدمها
    if (isReady) {
      try {
        final ink = _convertToInk(drawnPoints);

        if (ink.strokes.isEmpty) {
          return HandwritingMLResult(
            recognized: '',
            accuracy: 0.0,
            isPassed: false,
            feedback: 'لم يتم الرسم',
          );
        }

        final candidates = await _recognizer!.recognize(ink);

        if (candidates.isNotEmpty) {
          // البحث عن الحرف المطلوب
          for (int i = 0; i < candidates.length && i < 10; i++) {
            final candidate = candidates[i].text.trim();

            if (_isLetterMatch(candidate, targetLetter)) {
              final accuracy = 1.0 - (i * 0.08);
              return HandwritingMLResult(
                recognized: candidate,
                accuracy: accuracy,
                isPassed: accuracy >= 0.60,
                feedback: _getFeedback(accuracy, targetLetter),
              );
            }
          }

          // الحرف غير موجود في النتائج
          final firstCandidate = candidates.first.text.trim();
          return HandwritingMLResult(
            recognized: firstCandidate,
            accuracy: 0.25,
            isPassed: false,
            feedback:
                'هذا يشبه "$firstCandidate" وليس "$targetLetter". حاول مرة أخرى!',
          );
        }
      } catch (e) {
        print('❌ خطأ في ML Kit: $e');
      }
    }

    // استخدام التحليل المحلي المحسن
    return _advancedAnalyze(drawnPoints, targetLetter);
  }

  /// التحقق من صحة الرسم
  static _ValidationResult _validateDrawing(
      List<DrawingPoint> drawnPoints, String targetLetter) {
    final validPoints = drawnPoints
        .where((p) => p.offset != Offset.zero)
        .map((p) => p.offset)
        .toList();

    if (validPoints.isEmpty) {
      return _ValidationResult(false, 0.0, 'لم يتم الرسم');
    }

    // الحد الأدنى من النقاط
    final letterInfo = _getLetterRequirements(targetLetter);
    final minPoints = letterInfo.minPoints;

    if (validPoints.length < minPoints) {
      return _ValidationResult(
          false, 0.1, 'الرسم قصير جداً! حرف "$targetLetter" يحتاج رسم أطول');
    }

    // حساب الحدود
    final bounds = _calculateBounds(validPoints);

    // الحد الأدنى للحجم
    if (bounds.width < 40 && bounds.height < 40) {
      return _ValidationResult(false, 0.15, 'الرسم صغير جداً! ارسم بحجم أكبر');
    }

    // التحقق من التنوع في الحركة (ليس خط مستقيم فقط)
    final movementVariety = _calculateMovementVariety(validPoints);
    if (movementVariety < 0.1 && !['ا', 'ل'].contains(targetLetter)) {
      return _ValidationResult(
          false, 0.2, 'الرسم بسيط جداً! "$targetLetter" له شكل أكثر تفصيلاً');
    }

    return _ValidationResult(true, 1.0, '');
  }

  /// تحليل متقدم للكتابة
  static HandwritingMLResult _advancedAnalyze(
    List<DrawingPoint> drawnPoints,
    String targetLetter,
  ) {
    final validPoints = drawnPoints
        .where((p) => p.offset != Offset.zero)
        .map((p) => p.offset)
        .toList();

    final letterReq = _getLetterRequirements(targetLetter);
    final bounds = _calculateBounds(validPoints);

    double totalScore = 0.0;
    int checksCount = 0;

    // 1. فحص عدد النقاط (20%)
    final pointRatio = validPoints.length / letterReq.expectedPoints;
    final pointScore = _gaussianScore(pointRatio, 1.0, 0.5);
    totalScore += pointScore * 0.20;
    checksCount++;

    // 2. فحص نسبة الطول للعرض (20%)
    final aspectRatio = bounds.width / max(bounds.height, 1);
    final aspectScore = _gaussianScore(aspectRatio, letterReq.aspectRatio, 0.8);
    totalScore += aspectScore * 0.20;
    checksCount++;

    // 3. فحص الاتجاه الرئيسي (20%)
    final directionScore = _checkDirection(validPoints, letterReq);
    totalScore += directionScore * 0.20;
    checksCount++;

    // 4. فحص الانحناء (20%)
    final curvatureScore = _checkCurvature(validPoints, letterReq);
    totalScore += curvatureScore * 0.20;
    checksCount++;

    // 5. فحص عدد الخطوط المنفصلة (20%)
    final strokeCount = _countStrokes(drawnPoints);
    final strokeScore = _gaussianScore(
        strokeCount.toDouble(), letterReq.expectedStrokes.toDouble(), 1.0);
    totalScore += strokeScore * 0.20;
    checksCount++;

    // نسبة النجاح 70%
    final isPassed = totalScore >= 0.70;

    return HandwritingMLResult(
      recognized: isPassed ? targetLetter : '',
      accuracy: totalScore,
      isPassed: isPassed,
      feedback: _getDetailedFeedback(totalScore, targetLetter, pointScore,
          aspectScore, directionScore, curvatureScore),
    );
  }

  /// دالة Gaussian للتقييم
  static double _gaussianScore(
      double value, double expected, double tolerance) {
    final diff = (value - expected).abs();
    final score = exp(-(diff * diff) / (2 * tolerance * tolerance));
    return score.clamp(0.0, 1.0);
  }

  /// متطلبات كل حرف
  static _LetterRequirements _getLetterRequirements(String letter) {
    final requirements = <String, _LetterRequirements>{
      // حروف عمودية بسيطة
      'ا': _LetterRequirements(25, 60, 0.15, 1, 'vertical', 0.1),
      'ل': _LetterRequirements(35, 70, 0.25, 1, 'vertical', 0.15),

      // حروف أفقية مع نقاط
      'ب': _LetterRequirements(40, 80, 2.5, 2, 'horizontal', 0.3),
      'ت': _LetterRequirements(45, 90, 2.5, 3, 'horizontal', 0.3),
      'ث': _LetterRequirements(50, 100, 2.5, 4, 'horizontal', 0.3),
      'ن': _LetterRequirements(35, 70, 2.0, 2, 'horizontal', 0.35),
      'ي': _LetterRequirements(45, 85, 2.0, 3, 'horizontal', 0.35),

      // حروف منحنية
      'ج': _LetterRequirements(45, 90, 1.0, 2, 'curved', 0.5),
      'ح': _LetterRequirements(40, 85, 1.0, 1, 'curved', 0.5),
      'خ': _LetterRequirements(50, 95, 1.0, 2, 'curved', 0.5),
      'ع': _LetterRequirements(45, 90, 1.0, 1, 'curved', 0.55),
      'غ': _LetterRequirements(50, 100, 1.0, 2, 'curved', 0.55),

      // حروف مستديرة
      'و': _LetterRequirements(35, 70, 0.9, 1, 'circular', 0.6),
      'ه': _LetterRequirements(40, 75, 1.0, 1, 'circular', 0.65),
      'هـ': _LetterRequirements(40, 75, 1.0, 1, 'circular', 0.65),
      'م': _LetterRequirements(45, 85, 1.3, 1, 'circular', 0.5),
      'ف': _LetterRequirements(45, 85, 1.8, 2, 'circular', 0.45),
      'ق': _LetterRequirements(50, 90, 1.6, 3, 'circular', 0.45),

      // حروف مع زوايا
      'د': _LetterRequirements(30, 60, 1.3, 1, 'angled', 0.25),
      'ذ': _LetterRequirements(40, 75, 1.3, 2, 'angled', 0.25),
      'ر': _LetterRequirements(25, 55, 0.7, 1, 'curved', 0.35),
      'ز': _LetterRequirements(35, 70, 0.7, 2, 'curved', 0.35),

      // حروف معقدة
      'س': _LetterRequirements(55, 110, 3.5, 1, 'zigzag', 0.4),
      'ش': _LetterRequirements(60, 120, 3.5, 4, 'zigzag', 0.4),
      'ص': _LetterRequirements(50, 100, 2.2, 1, 'complex', 0.45),
      'ض': _LetterRequirements(55, 110, 2.2, 2, 'complex', 0.45),
      'ط': _LetterRequirements(45, 90, 1.3, 1, 'complex', 0.4),
      'ظ': _LetterRequirements(50, 100, 1.3, 2, 'complex', 0.4),
      'ك': _LetterRequirements(50, 95, 1.4, 2, 'complex', 0.35),
    };

    return requirements[letter] ??
        _LetterRequirements(40, 80, 1.5, 1, 'general', 0.35);
  }

  /// فحص الاتجاه
  static double _checkDirection(List<Offset> points, _LetterRequirements req) {
    if (points.length < 2) return 0.0;

    final start = points.first;
    final end = points.last;
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;

    switch (req.direction) {
      case 'vertical':
        // يجب أن يكون الحركة عمودية (dy > dx)
        return (dy.abs() > dx.abs() * 1.5) ? 1.0 : 0.4;

      case 'horizontal':
        // يجب أن يكون من اليمين لليسار
        return (dx < 0 && dx.abs() > dy.abs()) ? 1.0 : 0.4;

      case 'curved':
      case 'circular':
        // التحقق من وجود انحناء
        final curvature = _calculateOverallCurvature(points);
        return curvature > 0.3 ? 1.0 : 0.5;

      case 'zigzag':
        // التحقق من تغيرات الاتجاه
        final changes = _countDirectionChanges(points);
        return changes >= 3 ? 1.0 : 0.4;

      default:
        return 0.7;
    }
  }

  /// فحص الانحناء
  static double _checkCurvature(List<Offset> points, _LetterRequirements req) {
    final actualCurvature = _calculateOverallCurvature(points);
    final expectedCurvature = req.expectedCurvature;

    // استخدام دالة Gaussian للمقارنة
    return _gaussianScore(actualCurvature, expectedCurvature, 0.25);
  }

  /// حساب الانحناء الكلي
  static double _calculateOverallCurvature(List<Offset> points) {
    if (points.length < 5) return 0.0;

    double totalAngle = 0.0;
    int count = 0;

    for (int i = 2; i < points.length - 2; i += 3) {
      final p1 = points[i - 2];
      final p2 = points[i];
      final p3 = points[i + 2];

      final v1 = Offset(p2.dx - p1.dx, p2.dy - p1.dy);
      final v2 = Offset(p3.dx - p2.dx, p3.dy - p2.dy);

      final dot = v1.dx * v2.dx + v1.dy * v2.dy;
      final cross = v1.dx * v2.dy - v1.dy * v2.dx;
      final angle = atan2(cross.abs(), dot);

      totalAngle += angle;
      count++;
    }

    return count > 0 ? (totalAngle / count) / (pi / 2) : 0.0;
  }

  /// حساب تنوع الحركة
  static double _calculateMovementVariety(List<Offset> points) {
    if (points.length < 3) return 0.0;

    final directions = <int>{};

    for (int i = 1; i < points.length; i++) {
      final dx = points[i].dx - points[i - 1].dx;
      final dy = points[i].dy - points[i - 1].dy;

      // تحديد الاتجاه (8 اتجاهات)
      final angle = atan2(dy, dx);
      final direction = ((angle + pi) / (pi / 4)).round() % 8;
      directions.add(direction);
    }

    return directions.length / 8.0;
  }

  /// عد تغيرات الاتجاه
  static int _countDirectionChanges(List<Offset> points) {
    if (points.length < 3) return 0;

    int changes = 0;
    double lastDx = 0, lastDy = 0;

    for (int i = 1; i < points.length; i++) {
      final dx = points[i].dx - points[i - 1].dx;
      final dy = points[i].dy - points[i - 1].dy;

      if (i > 1) {
        // التحقق من تغير الاتجاه
        if ((dx * lastDx < 0) || (dy * lastDy < 0)) {
          changes++;
        }
      }

      lastDx = dx;
      lastDy = dy;
    }

    return changes;
  }

  /// عد الخطوط المنفصلة
  static int _countStrokes(List<DrawingPoint> points) {
    int strokes = 0;
    bool inStroke = false;

    for (final point in points) {
      if (point.offset == Offset.zero) {
        if (inStroke) {
          strokes++;
          inStroke = false;
        }
      } else {
        inStroke = true;
      }
    }

    if (inStroke) strokes++;
    return max(strokes, 1);
  }

  /// حساب الحدود
  static Rect _calculateBounds(List<Offset> points) {
    if (points.isEmpty) return Rect.zero;

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

  /// تحويل للـ Ink
  static Ink _convertToInk(List<DrawingPoint> drawnPoints) {
    final strokes = <Stroke>[];
    var currentStrokePoints = <StrokePoint>[];
    int timestamp = 0;

    for (final point in drawnPoints) {
      if (point.offset == Offset.zero) {
        if (currentStrokePoints.isNotEmpty) {
          strokes.add(Stroke()..points = currentStrokePoints);
          currentStrokePoints = [];
        }
      } else {
        currentStrokePoints.add(StrokePoint(
          x: point.offset.dx,
          y: point.offset.dy,
          t: timestamp,
        ));
        timestamp += 10;
      }
    }

    if (currentStrokePoints.isNotEmpty) {
      strokes.add(Stroke()..points = currentStrokePoints);
    }

    return Ink()..strokes = strokes;
  }

  /// التحقق من تطابق الحرف
  static bool _isLetterMatch(String recognized, String target) {
    final cleanRecognized = recognized.trim();
    final cleanTarget = target.trim();

    if (cleanRecognized == cleanTarget) return true;
    if (cleanRecognized.contains(cleanTarget)) return true;

    final similarLetters = {
      'ا': ['أ', 'إ', 'آ', 'ا'],
      'أ': ['ا', 'إ', 'آ', 'أ'],
      'إ': ['ا', 'أ', 'آ', 'إ'],
      'ه': ['هـ', 'ة', 'ه'],
      'هـ': ['ه', 'ة', 'هـ'],
      'ة': ['ه', 'هـ', 'ة'],
      'ي': ['ى', 'ي'],
      'ى': ['ي', 'ى'],
    };

    if (similarLetters.containsKey(cleanTarget)) {
      return similarLetters[cleanTarget]!.contains(cleanRecognized);
    }

    return false;
  }

  /// تغذية راجعة مفصلة
  static String _getDetailedFeedback(
      double accuracy,
      String letter,
      double pointScore,
      double aspectScore,
      double directionScore,
      double curvatureScore) {
    if (accuracy >= 0.85) return 'ممتاز! كتابة رائعة 🌟';
    if (accuracy >= 0.75) return 'أحسنت! 🎉';
    if (accuracy >= 0.70) return 'جيد! ✨';

    // تحديد المشكلة الرئيسية
    final minScore =
        [pointScore, aspectScore, directionScore, curvatureScore].reduce(min);

    if (minScore == pointScore) {
      return 'حاول رسم حرف "$letter" بشكل أكمل 📝';
    } else if (minScore == aspectScore) {
      return 'شكل الحرف غير صحيح. راجع كيف يُكتب "$letter" 🔍';
    } else if (minScore == directionScore) {
      return 'اتجاه الكتابة غير صحيح. ابدأ من المكان الصحيح ✏️';
    } else {
      return 'الانحناء غير مطابق. تدرب أكثر على "$letter" 💪';
    }
  }

  static String _getFeedback(double accuracy, String letter) {
    if (accuracy >= 0.90) return 'ممتاز جداً! 🌟';
    if (accuracy >= 0.80) return 'ممتاز! 🎉';
    if (accuracy >= 0.70) return 'جيد جداً! 👍';
    if (accuracy >= 0.60) return 'جيد! ✨';
    return 'حاول مرة أخرى 💪';
  }

  static Future<void> dispose() async {
    await _recognizer?.close();
    _recognizer = null;
  }
}

/// نتيجة التحقق
class _ValidationResult {
  final bool isValid;
  final double score;
  final String message;

  _ValidationResult(this.isValid, this.score, this.message);
}

/// متطلبات الحرف
class _LetterRequirements {
  final int minPoints;
  final int expectedPoints;
  final double aspectRatio;
  final int expectedStrokes;
  final String direction;
  final double expectedCurvature;

  _LetterRequirements(
    this.minPoints,
    this.expectedPoints,
    this.aspectRatio,
    this.expectedStrokes,
    this.direction,
    this.expectedCurvature,
  );
}

/// نتيجة التعرف
class HandwritingMLResult {
  final String recognized;
  final double accuracy;
  final bool isPassed;
  final String feedback;

  const HandwritingMLResult({
    required this.recognized,
    required this.accuracy,
    required this.isPassed,
    required this.feedback,
  });
}
