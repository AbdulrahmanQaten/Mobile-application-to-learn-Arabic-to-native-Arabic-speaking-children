import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/advanced/drawing_canvas.dart';
import '../../services/handwriting_service.dart';
import '../../services/database_service.dart';

class HandwritingPracticeScreen extends StatefulWidget {
  final String letter;
  final String letterName;
  final VoidCallback? onComplete;
  final bool showAppBar;

  const HandwritingPracticeScreen({
    super.key,
    required this.letter,
    required this.letterName,
    this.onComplete,
    this.showAppBar = true,
  });

  @override
  State<HandwritingPracticeScreen> createState() =>
      _HandwritingPracticeScreenState();
}

class _HandwritingPracticeScreenState extends State<HandwritingPracticeScreen> {
  final GlobalKey<DrawingCanvasState> _canvasKey =
      GlobalKey<DrawingCanvasState>();
  List<DrawingPoint> _currentDrawing = [];
  HandwritingMLResult? _result;
  bool _showResult = false;
  bool _isChecking = false;

  @override
  void didUpdateWidget(HandwritingPracticeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // إذا تغير الحرف، امسح الرسم
    if (oldWidget.letter != widget.letter) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _canvasKey.currentState?.clearDrawing();
        setState(() {
          _currentDrawing = [];
          _result = null;
          _showResult = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: Text('تدرب على كتابة حرف ${widget.letter}'),
              backgroundColor: AppTheme.primarySkyBlue,
              foregroundColor: Colors.white,
            )
          : null,
      body: Row(
        children: [
          // النصف الأيسر: لوحة الرسم
          Expanded(
            flex: 1,
            child: Container(
              margin: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.primarySkyBlue, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(17),
                child: Stack(
                  children: [
                    // نموذج الحرف (شفاف)
                    Center(
                      child: Opacity(
                        opacity: 0.1,
                        child: Text(
                          widget.letter,
                          style: TextStyle(
                            fontSize: 200,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primarySkyBlue,
                          ),
                        ),
                      ),
                    ),
                    // لوحة الرسم
                    DrawingCanvas(
                      key: _canvasKey,
                      onDrawingComplete: (points) {
                        setState(() {
                          _currentDrawing = points;
                        });
                      },
                      strokeColor: AppTheme.primarySkyBlue,
                      strokeWidth: 8.0,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // النصف الأيمن: معلومات الحرف والأزرار
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // عرض الحرف
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primarySkyBlue,
                            AppTheme.lightSkyBlue
                          ],
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primarySkyBlue.withOpacity(0.3),
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            'اكتب هذا الحرف',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            widget.letter,
                            style: TextStyle(
                              fontSize: 60,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            widget.letterName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20),

                    // الأزرار
                    Row(
                      children: [
                        // زر مسح
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _canvasKey.currentState?.clearDrawing();
                              setState(() {
                                _currentDrawing = [];
                                _result = null;
                                _showResult = false;
                              });
                            },
                            icon: Icon(Icons.refresh, size: 18),
                            label: Text(
                              'مسح',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.warningOrange,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        // زر تحقق
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed:
                                _currentDrawing.isEmpty ? null : _checkDrawing,
                            icon: Icon(Icons.check_circle, size: 18),
                            label: Text(
                              'تحقق',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.successGreen,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              disabledBackgroundColor: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 15),

                    // النتيجة
                    if (_showResult && _result != null)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: _result!.isPassed
                              ? AppTheme.successGreen
                              : AppTheme.warningOrange,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Icon(
                              _result!.isPassed
                                  ? Icons.check_circle
                                  : Icons.refresh,
                              size: 40,
                              color: Colors.white,
                            ),
                            SizedBox(height: 8),
                            Text(
                              _result!.feedback,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 5),
                            Text(
                              'الدقة: ${(_result!.accuracy * 100).toStringAsFixed(0)}%',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.white),
                            ),
                            if (_result!.isPassed) ...[
                              SizedBox(height: 10),
                              ElevatedButton.icon(
                                onPressed: () {
                                  if (widget.onComplete != null) {
                                    widget.onComplete!();
                                  } else {
                                    Navigator.pop(context);
                                  }
                                },
                                icon: Icon(Icons.arrow_forward, size: 16),
                                label: Text(
                                  'التالي',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppTheme.successGreen,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _checkDrawing() async {
    if (_isChecking) return;

    setState(() {
      _isChecking = true;
    });

    final result = await HandwritingRecognitionService.recognize(
      _currentDrawing,
      widget.letter,
    );

    setState(() {
      _result = result;
      _showResult = true;
      _isChecking = false;
    });

    // حفظ التقدم إذا نجح
    if (result.isPassed) {
      DatabaseService.completeLesson('handwriting_${widget.letter}', 3);
    }
  }
}
