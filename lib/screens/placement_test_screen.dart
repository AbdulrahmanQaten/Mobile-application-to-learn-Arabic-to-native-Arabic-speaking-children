import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../theme/app_theme.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import '../data/placement_test_data.dart';
import '../services/database_service.dart';
import 'home_screen.dart';

class PlacementTestScreen extends StatefulWidget {
  final String childName;
  final int childAge;

  const PlacementTestScreen({
    super.key,
    required this.childName,
    required this.childAge,
  });

  @override
  State<PlacementTestScreen> createState() => _PlacementTestScreenState();
}

class _PlacementTestScreenState extends State<PlacementTestScreen>
    with TickerProviderStateMixin {
  int _currentQuestionIndex = 0;
  int _correctAnswers = 0;
  final AudioPlayer _audioPlayer = AudioPlayer();
  late List<TestQuestion> _questions;
  late AnimationController _bounceController;
  late AnimationController _slideController;
  bool _isAnswered = false;

  // Speech recognition variables
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _speechAvailable = false;
  String _recognizedText = '';
  bool _showPronunciationResult = false;
  bool _isPronunciationCorrect = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _questions = PlacementTestData.getAllQuestions();

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideController.forward();

    // Initialize speech recognition
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _initializeSpeech();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _bounceController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    _speech.stop();
    super.dispose();
  }

  void _playSound() async {
    final question = _questions[_currentQuestionIndex];
    if (question.audioPath != null) {
      try {
        await _audioPlayer.play(AssetSource(question.audioPath!));
      } catch (e) {
        print('Error playing sound: $e');
      }
    }
  }

  // ========== Speech Recognition Methods ==========
  Future<void> _initializeSpeech() async {
    if (kIsWeb) {
      setState(() => _speechAvailable = false);
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
      setState(() => _speechAvailable = false);
    }
  }

  Future<void> _startListeningForPronunciation() async {
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
      _showPronunciationResult = false;
      _recognizedText = '';
    });

    try {
      await _speech.listen(
        onResult: (result) {
          setState(() {
            _recognizedText = result.recognizedWords;
          });
        },
        localeId: 'ar_SA',
        listenFor: Duration(seconds: 5),
        pauseFor: Duration(seconds: 3),
      );
      Future.delayed(Duration(seconds: 5), () {
        if (_isListening) _stopListeningForPronunciation();
      });
    } catch (e) {
      print('❌ خطأ في بدء الاستماع: $e');
      setState(() => _isListening = false);
    }
  }

  Future<void> _stopListeningForPronunciation() async {
    await _speech.stop();
    setState(() => _isListening = false);
    _checkPronunciationAnswer();
  }

  void _checkPronunciationAnswer() {
    final question = _questions[_currentQuestionIndex];
    final targetWord = question.correctAnswer;
    final similarity = _calculateSimilarity(_recognizedText, targetWord);

    print('🔍 المقارنة: "$_recognizedText" vs "$targetWord" = $similarity%');

    final isCorrect = similarity >= 70;

    setState(() {
      _isPronunciationCorrect = isCorrect;
      _showPronunciationResult = true;
      _isAnswered = true;
    });

    if (isCorrect) {
      _correctAnswers++;
      _bounceController.forward().then((_) => _bounceController.reverse());
    }

    _showFeedback(isCorrect);

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.of(context).pop();
        setState(() {
          _showPronunciationResult = false;
          _recognizedText = '';
        });
        _moveToNextQuestion();
      }
    });
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

  void _checkAnswer(String selectedAnswer) {
    if (_isAnswered) return;

    setState(() {
      _isAnswered = true;
    });

    final correctAnswer = _questions[_currentQuestionIndex].correctAnswer;
    final isCorrect = selectedAnswer == correctAnswer;

    if (isCorrect) {
      _correctAnswers++;
      _bounceController.forward().then((_) => _bounceController.reverse());
    }

    // إظهار رسالة للنجاح والخطأ
    _showFeedback(isCorrect);

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.of(context).pop();
        _moveToNextQuestion();
      }
    });
  }

  void _moveToNextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _isAnswered = false;
      });
      _slideController.reset();
      _slideController.forward();
    } else {
      _showResults();
    }
  }

  void _showFeedback(bool isCorrect) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isCorrect
                  ? [Color(0xFF4CAF50), Color(0xFF81C784)]
                  : [Color(0xFFFF9800), Color(0xFFFFB74D)],
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isCorrect ? Icons.star : Icons.lightbulb,
                color: Colors.white,
                size: 45,
              ),
              const SizedBox(height: 10),
              Text(
                isCorrect ? 'أحسنت! 🎉' : 'حاول مرة أخرى 💪',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showResults() {
    final level = PlacementTestData.determineLevelFromScore(_correctAnswers);
    final message = PlacementTestData.getEncouragementMessage(_correctAnswers);
    final levelNumber = _getLevelNumber(level);

    // حساب النجوم بناءً على النتيجة (3 مراحل = حد أقصى 3 نجوم)
    int earnedStars;
    if (_correctAnswers <= 7)
      earnedStars = 1;
    else if (_correctAnswers <= 14)
      earnedStars = 2;
    else
      earnedStars = 3;

    // حساب الذهب (كل إجابة صحيحة = 10 ذهب)
    int earnedGold = _correctAnswers * 10;

    // تحديد المراحل المفتوحة (4 مراحل)
    List<String> unlockedStages = ['📖 مرحلة التمهيد'];
    if (levelNumber >= 3) unlockedStages.add('✏️ مرحلة الكتابة');
    if (levelNumber >= 4) unlockedStages.add('🎤 مرحلة النطق');
    if (levelNumber >= 5) unlockedStages.add('🏆 مرحلة المتقن');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            Icon(Icons.celebration, color: Colors.amber, size: 40),
            const SizedBox(height: 8),
            Text('نتيجة الاختبار',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$_correctAnswers / ${_questions.length}',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2575FC))),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                  3,
                  (i) => Icon(
                        i < earnedStars ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 28,
                      )),
            ),
            const SizedBox(height: 8),
            Text(level,
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primarySkyBlue)),
            const SizedBox(height: 4),
            Text('+$earnedGold ذهب 🪙',
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.amber[700],
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(message,
                style: TextStyle(fontSize: 13, color: AppTheme.textDark),
                textAlign: TextAlign.center),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                await DatabaseService.savePlacementTestResult(
                  score: _correctAnswers,
                  level: levelNumber,
                );
                await DatabaseService.addStars(earnedStars);
                await DatabaseService.addPoints(earnedGold);
                if (!mounted) return;
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2575FC),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text('ابدأ التعلم! 🚀',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // تحويل نص المستوى إلى رقم
  int _getLevelNumber(String levelText) {
    if (levelText.contains('1')) return 1;
    if (levelText.contains('2')) return 2;
    if (levelText.contains('3')) return 3;
    if (levelText.contains('4')) return 4;
    if (levelText.contains('5')) return 5;
    return 1; // افتراضي
  }

  void _skipTest() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final question = _questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / _questions.length;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFE5E5),
              Color(0xFFFFF0F0),
              Color(0xFFE5F3FF),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(screenHeight * 0.02),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: _skipTest,
                      icon: Icon(Icons.skip_next, color: Color(0xFFFF6B6B)),
                      label: Text(
                        'تخطي',
                        style: TextStyle(
                          fontSize: screenHeight * 0.022,
                          color: Color(0xFFFF6B6B),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Image.asset(
                      'assets/images/characters/arab_child_thinking_1764934154475.png',
                      height: screenHeight * 0.08,
                      filterQuality: FilterQuality.high,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.child_care,
                        size: screenHeight * 0.06,
                        color: AppTheme.primarySkyBlue,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.04,
                        vertical: screenHeight * 0.015,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFFFF6B6B).withOpacity(0.3),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        '${_currentQuestionIndex + 1} / ${_questions.length}',
                        style: TextStyle(
                          fontSize: screenHeight * 0.025,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: screenHeight * 0.015,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Expanded(
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(1, 0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _slideController,
                    curve: Curves.easeOutCubic,
                  )),
                  child: _buildQuestionContent(
                      question, screenHeight, screenWidth),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionContent(
      TestQuestion question, double screenHeight, double screenWidth) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
        child: Column(
          children: [
            // السؤال في الأعلى للأسئلة الصوتية فقط
            if (question.type == QuestionType.audioToLetter)
              Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04,
                      vertical: screenHeight * 0.025,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      question.question,
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.025),
                ],
              ),

            // عرض السؤال حسب النوع
            if (question.type == QuestionType.audioToLetter)
              _buildAudioQuestion(question, screenHeight)
            else if (question.type == QuestionType.imageToFirstLetter ||
                question.type == QuestionType.countLetters ||
                question.type == QuestionType.completeWord)
              _buildImageQuestion(question, screenHeight)
            else if (question.type == QuestionType.wordToImage)
              _buildWordToImageQuestion(question, screenHeight, screenWidth)
            else if (question.type == QuestionType.imageToWord)
              _buildImageToWordQuestion(question, screenHeight, screenWidth)
            else if (question.type == QuestionType.pronunciation)
              _buildPronunciationQuestion(question, screenHeight, screenWidth),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioQuestion(TestQuestion question, double screenHeight) {
    return Column(
      children: [
        GestureDetector(
          onTap: _playSound,
          child: Container(
            width: screenHeight * 0.18,
            height: screenHeight * 0.18,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0xFFFF6B6B).withOpacity(0.4),
                  blurRadius: 18,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Icon(
              Icons.volume_up,
              size: screenHeight * 0.09,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(height: screenHeight * 0.03),
        _buildTextOptions(question.options, screenHeight),
      ],
    );
  }

  Widget _buildImageQuestion(TestQuestion question, double screenHeight) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // السؤال والصورة على اليسار (مساحة أكبر للصورة)
        Expanded(
          flex: 6,
          child: SizedBox(
            height: screenHeight * 0.55, // زيادة الارتفاع
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // السؤال
                Container(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    question.question,
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                // الصورة بدون خلفية
                Expanded(
                  child: Container(
                    padding: EdgeInsets.zero, // إزالة الهوامش
                    alignment: Alignment.center,
                    child: Image.asset(
                      'assets/${question.imagePath}',
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.image_not_supported,
                        size: screenHeight * 0.1,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(width: screenWidth * 0.02),

        // الاختيارات على اليمين (2×2)
        Expanded(
          flex: 4,
          child: GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: screenHeight * 0.015,
            crossAxisSpacing: screenWidth * 0.02,
            childAspectRatio: 1.3,
            children: question.options.map((option) {
              return GestureDetector(
                onTap: () => _checkAnswer(option),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF4CAF50).withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: screenWidth * 0.075,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildWordToImageQuestion(
      TestQuestion question, double screenHeight, double screenWidth) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // الكلمة على اليسار
        Expanded(
          flex: 4,
          child: Container(
            height: screenHeight * 0.35,
            padding: EdgeInsets.symmetric(horizontal: 8), // تقليل البادينغ
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF2575FC).withOpacity(0.3),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            alignment: Alignment.center, // ضمان التوسيط
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: EdgeInsets.all(12), // بادينغ داخلي للنص
                child: Text(
                  question.word ?? '',
                  style: TextStyle(
                    fontSize: screenWidth * 0.1, // حجم كبير ولكن قابل للتصغير
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.2, // تحسين ارتفاع السطر
                  ),
                  textAlign: TextAlign.center,
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
            mainAxisSpacing: screenHeight * 0.015,
            crossAxisSpacing: screenWidth * 0.02,
            childAspectRatio: 1.0,
            children: question.options.map((imagePath) {
              return _buildImageOption(imagePath, screenHeight, screenWidth);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildImageToWordQuestion(
      TestQuestion question, double screenHeight, double screenWidth) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // السؤال والصورة على اليسار (مساحة أكبر)
        Expanded(
          flex: 6,
          child: SizedBox(
            height: screenHeight * 0.55, // زيادة الارتفاع
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // السؤال
                Container(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    question.question,
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                // الصورة بدون خلفية
                Expanded(
                  child: Container(
                    padding: EdgeInsets.zero, // إزالة الهوامش
                    alignment: Alignment.center,
                    child: Image.asset(
                      'assets/${question.imagePath}',
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.image_not_supported,
                        size: screenHeight * 0.1,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(width: screenWidth * 0.02),

        // الاختيارات على اليمين (2×2)
        Expanded(
          flex: 4,
          child: GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: screenHeight * 0.015,
            crossAxisSpacing: screenWidth * 0.02,
            childAspectRatio: 1.3,
            children: question.options.map((option) {
              return GestureDetector(
                onTap: () => _checkAnswer(option),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF4CAF50).withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: screenWidth * 0.065,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPronunciationQuestion(
      TestQuestion question, double screenHeight, double screenWidth) {
    return Column(
      children: [
        // عنوان السؤال
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04,
            vertical: screenHeight * 0.02,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            question.question,
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: screenHeight * 0.025),

        // صورة الحيوان
        Container(
          height: screenHeight * 0.25,
          width: screenWidth * 0.6,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 15,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: Image.asset(
              'assets/${question.imagePath}',
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.image_not_supported,
                size: screenHeight * 0.1,
                color: Colors.grey,
              ),
            ),
          ),
        ),
        SizedBox(height: screenHeight * 0.025),

        // اسم الكلمة المطلوبة
        Text(
          question.word ?? '',
          style: TextStyle(
            fontSize: screenWidth * 0.08,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: screenHeight * 0.02),

        // زر الميكروفون
        GestureDetector(
          onTap: _isAnswered
              ? null
              : (_isListening
                  ? _stopListeningForPronunciation
                  : _startListeningForPronunciation),
          child: ScaleTransition(
            scale: _isListening ? _pulseAnimation : AlwaysStoppedAnimation(1.0),
            child: Container(
              width: screenWidth * 0.2,
              height: screenWidth * 0.2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: _isListening
                      ? [Color(0xFFFF5252), Color(0xFFFF1744)]
                      : _isAnswered
                          ? [Colors.grey, Colors.grey.shade600]
                          : [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: (_isListening
                            ? Colors.red
                            : _isAnswered
                                ? Colors.grey
                                : Colors.green)
                        .withOpacity(0.4),
                    blurRadius: 15,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: Icon(
                _isListening ? Icons.stop : Icons.mic,
                color: Colors.white,
                size: screenWidth * 0.1,
              ),
            ),
          ),
        ),
        SizedBox(height: screenHeight * 0.015),

        // النص المتعرف عليه
        if (_recognizedText.isNotEmpty)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              '🎤 $_recognizedText',
              style: TextStyle(
                fontSize: screenWidth * 0.045,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),

        if (_isListening)
          Padding(
            padding: EdgeInsets.only(top: screenHeight * 0.01),
            child: Text(
              'جارِ الاستماع...',
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                color: Colors.white70,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTextOptions(List<String> options, double screenHeight) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Wrap(
      spacing: screenWidth * 0.025,
      runSpacing: screenHeight * 0.02,
      alignment: WrapAlignment.center,
      children: options.map((option) {
        return GestureDetector(
          onTap: () => _checkAnswer(option),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.06, // أكبر
              vertical: screenHeight * 0.025, // أكبر
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF4CAF50).withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              option,
              style: TextStyle(
                fontSize: screenWidth * 0.065, // أكبر للهواتف
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildImageOption(
      String imagePath, double screenHeight, double screenWidth) {
    return GestureDetector(
      onTap: () => _checkAnswer(imagePath),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Color(0xFF4CAF50),
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Image.asset(
              'assets/$imagePath',
              fit: BoxFit.contain, // contain بدلاً من cover
              filterQuality: FilterQuality.high,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.image,
                size: screenWidth * 0.12,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
