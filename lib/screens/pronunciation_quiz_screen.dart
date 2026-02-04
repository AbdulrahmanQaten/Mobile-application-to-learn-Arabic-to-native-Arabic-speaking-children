import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';
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
  State<PronunciationQuizScreen> createState() => _PronunciationQuizScreenState();
}

class _PronunciationQuizScreenState extends State<PronunciationQuizScreen>
    with SingleTickerProviderStateMixin {
  late List<PronunciationQuizQuestion> _questions;
  late List<List<String>> _shuffledOptions; // قوائم الخيارات المخلوطة
  int _currentQuestionIndex = 0;
  int _correctAnswers = 0;
  bool _answered = false;
  String? _selectedAnswer;
  final AudioPlayer _audioPlayer = AudioPlayer();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _questions = PronunciationQuizData.getRandomQuestions(5);
    // خلط الخيارات لكل سؤال (إنشاء نسخة قبل الخلط)
    _shuffledOptions = _questions.map((q) {
      final options = List<String>.from(q.allOptions);
      options.shuffle();
      return options;
    }).toList();

    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // تشغيل الصوت الأول بعد تحميل الشاشة
    Future.delayed(Duration(milliseconds: 500), () {
      _playCurrentQuestionAudio();
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _playCurrentQuestionAudio() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(
        AssetSource(_questions[_currentQuestionIndex].audioPath),
      );
    } catch (e) {
      print('❌ خطأ في تشغيل صوت السؤال: $e');
    }
  }

  void _checkAnswer(String selectedImagePath) {
    if (_answered) return;

    setState(() {
      _answered = true;
      _selectedAnswer = selectedImagePath;
    });

    final isCorrect =
        selectedImagePath == _questions[_currentQuestionIndex].correctImagePath;

    if (isCorrect) {
      _correctAnswers++;
      _playEncouragementSound();
    } else {
      _playWrongSound();
    }

    // الانتقال للسؤال التالي بعد ثانيتين
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        if (_currentQuestionIndex < _questions.length - 1) {
          setState(() {
            _currentQuestionIndex++;
            _answered = false;
            _selectedAnswer = null;
          });
          _playCurrentQuestionAudio();
        } else {
          _showResults();
        }
      }
    });
  }

  Future<void> _playEncouragementSound() async {
    final sounds = ['أحسنت.mp3', 'ممتاز.mp3', 'رائع.mp3', 'جيد.mp3'];
    final random = Random();
    try {
      await _audioPlayer.play(
        AssetSource('audio/encouragement/${sounds[random.nextInt(sounds.length)]}'),
      );
    } catch (e) {
      print('❌ خطأ في صوت التشجيع: $e');
    }
  }

  Future<void> _playWrongSound() async {
    // يمكن إضافة صوت للإجابة الخاطئة
  }

  void _showResults() {
    final stars = _calculateStars();
    
    // حفظ التقدم
    DatabaseService.completeLesson(widget.lessonId, stars);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
            maxWidth: 400,
          ),
          padding: EdgeInsets.all(25),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white, Color(0xFFFFF9E6)],
            ),
            borderRadius: BorderRadius.circular(30),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  stars >= 2 ? Icons.emoji_events : Icons.refresh,
                  color: stars >= 2 ? AppTheme.starYellow : AppTheme.warningOrange,
                  size: 70,
                ),
                SizedBox(height: 15),
                Text(
                  stars >= 2 ? '🎉 أحسنت! 🎉' : 'حاول مرة أخرى',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primarySkyBlue,
                  ),
                ),
                SizedBox(height: 15),
                Text(
                  'أجبت على $_correctAnswers من ${_questions.length} أسئلة بشكل صحيح',
                  style: TextStyle(fontSize: 18, color: AppTheme.textDark),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                // النجوم
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: Icon(
                        index < stars ? Icons.star : Icons.star_border,
                        color: AppTheme.starYellow,
                        size: 45,
                      ),
                    );
                  }),
                ),
                SizedBox(height: 25),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // إغلاق الديالوج
                    Navigator.pop(context); // الرجوع للشاشة السابقة
                  },
                  child: Text(
                    'متابعة',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.successGreen,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
                if (stars < 2) ...[
                  SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        _currentQuestionIndex = 0;
                        _correctAnswers = 0;
                        _answered = false;
                        _selectedAnswer = null;
                      _questions = PronunciationQuizData.getRandomQuestions(5);
                        _shuffledOptions = _questions.map((q) {
                          final options = List<String>.from(q.allOptions);
                          options.shuffle();
                          return options;
                        }).toList();
                      });
                      _playCurrentQuestionAudio();
                    },
                    child: Text(
                      'إعادة الاختبار',
                      style: TextStyle(fontSize: 16, color: AppTheme.primarySkyBlue),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  int _calculateStars() {
    final percentage = (_correctAnswers / _questions.length) * 100;
    if (percentage >= 80) return 3;
    if (percentage >= 60) return 2;
    if (percentage >= 40) return 1;
    return 0;
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
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  child: _buildQuestionContent(question, screenHeight, screenWidth),
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
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: 10),
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
              'اختبار ${widget.lessonName}',
              style: TextStyle(
                fontSize: 20,
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

  Widget _buildQuestionContent(
      PronunciationQuizQuestion question, double screenHeight, double screenWidth) {
    return SingleChildScrollView(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // زر الصوت على اليسار
          Expanded(
            flex: 4,
            child: Container(
              height: screenHeight * 0.35,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 15,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(25),
                  onTap: _playCurrentQuestionAudio,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.volume_up,
                        size: screenHeight * 0.1,
                        color: Colors.white,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'اضغط للاستماع',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        '🔊',
                        style: TextStyle(fontSize: 24),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SizedBox(width: screenWidth * 0.03),

          // الصور على اليمين (2×2)
          Expanded(
            flex: 6,
            child: GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: screenHeight * 0.01,
              crossAxisSpacing: screenWidth * 0.015,
              childAspectRatio: 1.0,
              children: _shuffledOptions[_currentQuestionIndex].map((imagePath) {
                return _buildImageOption(imagePath, screenHeight, screenWidth);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageOption(String imagePath, double screenHeight, double screenWidth) {
    final isSelected = _selectedAnswer == imagePath;
    final isCorrect = imagePath == _questions[_currentQuestionIndex].correctImagePath;
    final showResult = _answered;

    Color borderColor = Colors.white;
    if (showResult) {
      if (isCorrect) {
        borderColor = AppTheme.successGreen;
      } else if (isSelected) {
        borderColor = Colors.red;
      }
    }

    return GestureDetector(
      onTap: () => _checkAnswer(imagePath),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.all(8), // إضافة هامش داخلي
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: borderColor,
            width: showResult && (isCorrect || isSelected) ? 4 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            // الصورة بداخل المربع
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/$imagePath',
                  fit: BoxFit.contain, // عرض الصورة كاملة بدون قص
                  errorBuilder: (context, error, stackTrace) => Center(
                    child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                  ),
                ),
              ),
            ),
            // أيقونة النتيجة
            if (showResult && (isCorrect || isSelected))
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isCorrect ? AppTheme.successGreen : Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isCorrect ? Icons.check : Icons.close,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
