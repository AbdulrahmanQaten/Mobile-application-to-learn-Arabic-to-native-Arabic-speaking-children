import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import '../theme/app_theme.dart';
import '../data/pronunciation_quiz_data.dart';
import '../services/database_service.dart';

class PronunciationQuizScreen extends StatefulWidget {
  final String lessonId;
  final String lessonName;

  const PronunciationQuizScreen({
    super.key,
    required this.lessonId,
    required this.lessonName,
  });

  @override
  State<PronunciationQuizScreen> createState() =>
      _PronunciationQuizScreenState();
}

class _PronunciationQuizScreenState extends State<PronunciationQuizScreen>
    with SingleTickerProviderStateMixin {
  late List<PronunciationQuizQuestion> _questions;
  int _currentQuestionIndex = 0;
  int _correctAnswers = 0;
  bool _isListening = false;
  bool _speechAvailable = false;
  String _recognizedText = '';
  bool _showResult = false;
  bool _isCorrect = false;
  final stt.SpeechToText _speech = stt.SpeechToText();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _questions = PronunciationQuizData.getRandomQuestions(5);
    _initializeSpeech();

    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initializeSpeech() async {
    if (kIsWeb) {
      setState(() {
        _speechAvailable = false;
      });
      return;
    }

    try {
      _speechAvailable = await _speech.initialize(
        onStatus: (status) => print('🎤 حالة التعرف: $status'),
        onError: (error) => print('❌ خطأ في التعرف: $error'),
      );
      setState(() {});
    } catch (e) {
      print('❌ فشل تهيئة التعرف على الصوت: $e');
      setState(() {
        _speechAvailable = false;
      });
    }
  }

  Future<void> _startListening() async {
    if (kIsWeb) {
      _showWebNotSupported();
      return;
    }

    if (!_speechAvailable) {
      _showSpeechNotAvailable();
      return;
    }

    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      _showPermissionDenied();
      return;
    }

    setState(() {
      _isListening = true;
      _showResult = false;
      _recognizedText = '';
    });

    try {
      await _speech.listen(
        onResult: (result) {
          setState(() {
            _recognizedText = result.recognizedWords;
            print('🎤 تم التعرف على: $_recognizedText');
          });
        },
        localeId: 'ar_SA',
        listenFor: Duration(seconds: 5),
        pauseFor: Duration(seconds: 3),
      );

      Future.delayed(Duration(seconds: 5), () {
        if (_isListening) {
          _stopListening();
        }
      });
    } catch (e) {
      print('❌ خطأ في بدء الاستماع: $e');
      setState(() {
        _isListening = false;
      });
    }
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    setState(() {
      _isListening = false;
    });
    _checkPronunciation();
  }

  void _checkPronunciation() {
    final targetWord = _questions[_currentQuestionIndex].animalName;
    final similarity = _calculateSimilarity(_recognizedText, targetWord);

    print('🔍 المقارنة: "$_recognizedText" vs "$targetWord" = $similarity%');

    setState(() {
      _isCorrect = similarity >= 70;
      _showResult = true;
    });

    if (_isCorrect) {
      _correctAnswers++;
      Future.delayed(Duration(seconds: 2), () {
        if (mounted) {
          _nextQuestion();
        }
      });
    }
  }

  int _calculateSimilarity(String recognized, String target) {
    recognized = recognized.trim().replaceAll(RegExp(r'[\u064B-\u065F]'), '');
    target = target.trim().replaceAll(RegExp(r'[\u064B-\u065F]'), '');

    if (recognized.isEmpty) return 0;
    if (recognized == target) return 100;
    if (recognized.contains(target) || target.contains(recognized)) return 85;

    int matches = 0;
    for (int i = 0; i < recognized.length && i < target.length; i++) {
      if (recognized[i] == target[i]) matches++;
    }

    return ((matches / target.length) * 100).round();
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _showResult = false;
        _recognizedText = '';
      });
    } else {
      _showResults();
    }
  }

  int _calculateStars() {
    final percentage = (_correctAnswers / _questions.length) * 100;
    if (percentage >= 80) return 3;
    if (percentage >= 60) return 2;
    if (percentage >= 40) return 1;
    return 0;
  }

  void _showResults() {
    final stars = _calculateStars();

    // حفظ التقدم
    DatabaseService.completeLesson(widget.lessonId, stars);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            Icon(
              stars >= 2 ? Icons.emoji_events : Icons.refresh,
              color: stars >= 2 ? AppTheme.starYellow : AppTheme.warningOrange,
              size: 40,
            ),
            SizedBox(height: 8),
            Text(
              stars >= 2 ? '🎉 أحسنت! 🎉' : 'حاول مرة أخرى',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$_correctAnswers / ${_questions.length}',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primarySkyBlue),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                  3,
                  (index) => Icon(
                        index < stars ? Icons.star : Icons.star_border,
                        color: AppTheme.starYellow,
                        size: 30,
                      )),
            ),
          ],
        ),
        actions: [
          if (stars < 2)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _currentQuestionIndex = 0;
                  _correctAnswers = 0;
                  _showResult = false;
                  _recognizedText = '';
                  _questions = PronunciationQuizData.getRandomQuestions(5);
                });
              },
              child: Text('إعادة', style: TextStyle(fontSize: 15)),
            ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('متابعة',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showWebNotSupported() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('غير متوفر على الويب',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('ميزة التعرف على الصوت متوفرة فقط على تطبيق الهاتف.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('حسناً', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  void _showSpeechNotAvailable() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('غير متوفر', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('التعرف على الصوت غير متوفر على هذا الجهاز.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('حسناً', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  void _showPermissionDenied() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('أذونات الميكروفون',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('نحتاج إلى إذن الميكروفون للتعرف على نطقك.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('حسناً', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _speech.stop();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final question = _questions[_currentQuestionIndex];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color(0xFF6A11CB),
              Color(0xFF2575FC),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // الهيدر
              _buildHeader(screenWidth),
              SizedBox(height: screenHeight * 0.02),

              // شريط التقدم
              _buildProgressBar(screenWidth),
              SizedBox(height: screenHeight * 0.03),

              // محتوى السؤال
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                    child: _buildQuestionContent(
                        question, screenHeight, screenWidth),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(double screenWidth) {
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: 10),
      child: Row(
        children: [
          // زر الإغلاق
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Expanded(
            child: Text(
              'اختبار النطق - ${widget.lessonName}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(width: 48), // للتوازن
        ],
      ),
    );
  }

  Widget _buildProgressBar(double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'السؤال ${_currentQuestionIndex + 1}',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Text(
                '${_questions.length} / ${_currentQuestionIndex + 1}',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / _questions.length,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.starYellow),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionContent(PronunciationQuizQuestion question,
      double screenHeight, double screenWidth) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 20),

        // النص التعليمي
        Text(
          'انطق اسم الحيوان في الصورة 🎤',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: 25),

        // صورة الحيوان
        Container(
          width: screenWidth * 0.55,
          height: screenWidth * 0.55,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 25,
                offset: Offset(0, 15),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Image.asset(
              'assets/${question.imagePath}',
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Icon(Icons.image, size: 100, color: Colors.grey),
                );
              },
            ),
          ),
        ),

        SizedBox(height: 30),

        // زر الميكروفون
        ScaleTransition(
          scale: _isListening ? _pulseAnimation : AlwaysStoppedAnimation(1.0),
          child: GestureDetector(
            onTap: _isListening ? null : _startListening,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: _isListening
                      ? [Colors.red, Colors.redAccent]
                      : [AppTheme.warningOrange, Colors.orange[300]!],
                ),
                boxShadow: [
                  BoxShadow(
                    color: (_isListening ? Colors.red : AppTheme.warningOrange)
                        .withOpacity(0.5),
                    blurRadius: 25,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: Icon(
                _isListening ? Icons.mic : Icons.mic_none,
                size: 50,
                color: Colors.white,
              ),
            ),
          ),
        ),

        SizedBox(height: 20),

        // مؤشر الاستماع
        if (_isListening) _buildListeningIndicator(),

        // النتيجة
        if (_showResult) _buildResult(),

        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildListeningIndicator() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            'أنا أستمع... 🎤',
            style: TextStyle(
                fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          if (_recognizedText.isNotEmpty) ...[
            SizedBox(height: 10),
            Text(
              _recognizedText,
              style: TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResult() {
    return Container(
      margin: EdgeInsets.only(top: 15),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _isCorrect
              ? [AppTheme.successGreen, Colors.green[300]!]
              : [AppTheme.warningOrange, Colors.orange[300]!],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: (_isCorrect ? AppTheme.successGreen : AppTheme.warningOrange)
                .withOpacity(0.4),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            _isCorrect ? Icons.check_circle : Icons.refresh,
            size: 50,
            color: Colors.white,
          ),
          SizedBox(height: 10),
          Text(
            _isCorrect ? 'ممتاز! 🎉' : 'حاول مرة أخرى',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          if (!_isCorrect) ...[
            SizedBox(height: 10),
            Text(
              'الإجابة الصحيحة: ${_questions[_currentQuestionIndex].animalName}',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showResult = false;
                      _recognizedText = '';
                    });
                  },
                  child: Text('حاول مجدداً',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.warningOrange,
                    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    _nextQuestion();
                  },
                  child: Text('تخطي',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.3),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
