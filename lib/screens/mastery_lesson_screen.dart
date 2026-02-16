import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:audioplayers/audioplayers.dart';
import '../theme/app_theme.dart';
import '../data/mastery_stage_data.dart';
import '../services/database_service.dart';

class MasteryLessonScreen extends StatefulWidget {
  final StoryLesson story;

  const MasteryLessonScreen({
    super.key,
    required this.story,
  });

  @override
  State<MasteryLessonScreen> createState() => _MasteryLessonScreenState();
}

class _MasteryLessonScreenState extends State<MasteryLessonScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  int _currentPage = 0;
  int _correctAnswers = 0;
  bool _isAnswered = false;
  String? _selectedAnswer;
  bool _isCorrect = false;

  // Speech recognition
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _speechAvailable = false;
  String _recognizedText = '';
  bool _showPronunciationResult = false;

  // Audio
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Animation
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _initializeSpeech();

    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pulseController.dispose();
    _audioPlayer.dispose();
    _speech.stop();
    super.dispose();
  }

  Future<void> _initializeSpeech() async {
    if (kIsWeb) {
      setState(() => _speechAvailable = false);
      return;
    }
    try {
      _speechAvailable = await _speech.initialize(
        onStatus: (status) => print('🎤 حالة: $status'),
        onError: (error) => print('❌ خطأ: $error'),
      );
      setState(() {});
    } catch (e) {
      setState(() => _speechAvailable = false);
    }
  }

  Future<void> _playAudio(String path) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(path.replaceFirst('assets/', '')));
    } catch (e) {
      print('❌ خطأ صوت: $e');
    }
  }

  void _onFillInBlankAnswer(String answer, StoryPage page) {
    if (_isAnswered) return;
    setState(() {
      _isAnswered = true;
      _selectedAnswer = answer;
      _isCorrect = answer == page.correctAnswer;
    });

    if (_isCorrect) {
      _correctAnswers++;
      if (page.audioPath != null) {
        _playAudio(page.audioPath!);
      }
    }
    // Auto-advance after delay
    Future.delayed(Duration(seconds: _isCorrect ? 2 : 1), () {
      if (mounted) {
        if (_isCorrect) {
          _goToNextPage();
        } else {
          // Allow retry on wrong answer
          setState(() {
            _isAnswered = false;
            _selectedAnswer = null;
          });
        }
      }
    });
  }

  void _onImageAnswer(String answer, StoryPage page) {
    if (_isAnswered) return;
    setState(() {
      _isAnswered = true;
      _selectedAnswer = answer;
      _isCorrect = answer == page.correctAnswer;
    });

    if (_isCorrect) {
      _correctAnswers++;
      if (page.audioPath != null) {
        _playAudio(page.audioPath!);
      }
    }
    Future.delayed(Duration(seconds: _isCorrect ? 2 : 1), () {
      if (mounted) {
        if (_isCorrect) {
          _goToNextPage();
        } else {
          setState(() {
            _isAnswered = false;
            _selectedAnswer = null;
          });
        }
      }
    });
  }

  Future<void> _startListening() async {
    if (kIsWeb) {
      _showWebDialog();
      return;
    }
    if (!_speechAvailable) {
      _showSpeechUnavailableDialog();
      return;
    }

    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      _showPermissionDialog();
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
        if (_isListening && mounted) {
          _stopListening();
        }
      });
    } catch (e) {
      setState(() => _isListening = false);
    }
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    setState(() => _isListening = false);
    _checkPronunciation();
  }

  void _checkPronunciation() {
    final page = widget.story.pages[_currentPage];
    final similarity =
        _calculateSimilarity(_recognizedText, page.correctAnswer);

    setState(() {
      _isCorrect = similarity >= 70;
      _showPronunciationResult = true;
      _isAnswered = true;
    });

    if (_isCorrect) {
      _correctAnswers++;
      if (page.audioPath != null) {
        _playAudio(page.audioPath!);
      }
      Future.delayed(Duration(seconds: 2), () {
        if (mounted) _goToNextPage();
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

  void _goToNextPage() {
    if (_currentPage < widget.story.pages.length - 1) {
      setState(() {
        _currentPage++;
        _isAnswered = false;
        _selectedAnswer = null;
        _isCorrect = false;
        _showPronunciationResult = false;
        _recognizedText = '';
      });
      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _showResultsDialog();
    }
  }

  int _calculateStars() {
    final percentage = (_correctAnswers / widget.story.pages.length) * 100;
    if (percentage >= 80) return 3;
    if (percentage >= 60) return 2;
    if (percentage >= 40) return 1;
    return 0;
  }

  void _showResultsDialog() {
    final stars = _calculateStars();
    final gold = _correctAnswers * 10;

    // Save progress
    DatabaseService.completeLesson(widget.story.id, stars);
    DatabaseService.addStars(stars);
    DatabaseService.addPoints(gold);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            Icon(Icons.emoji_events, color: Colors.amber, size: 40),
            SizedBox(height: 8),
            Text('🎉 أحسنت!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('أكملت قصة ${widget.story.title}',
                style: TextStyle(fontSize: 15, color: AppTheme.textDark),
                textAlign: TextAlign.center),
            SizedBox(height: 10),
            Text('$_correctAnswers / ${widget.story.pages.length}',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2575FC))),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                  3,
                  (i) => Icon(
                        i < stars ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 30,
                      )),
            ),
            SizedBox(height: 6),
            Text('+$gold ذهب 🪙',
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.amber[700],
                    fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2575FC),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text('العودة 🏠',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // Dialog helpers
  void _showWebDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('غير متاح'),
        content: Text('النطق غير متاح في المتصفح. جرّب على الهاتف!'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('حسناً'))
        ],
      ),
    );
  }

  void _showSpeechUnavailableDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('غير متاح'),
        content: Text('التعرف على الصوت غير متاح. تأكد من إعدادات جهازك.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('حسناً'))
        ],
      ),
    );
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('صلاحية مطلوبة'),
        content: Text('نحتاج صلاحية الميكروفون للنطق.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('حسناً'))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar
              _buildTopBar(screenWidth),
              // Progress indicator
              _buildProgressDots(),
              // Story content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: widget.story.pages.length,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemBuilder: (context, index) {
                    return _buildStoryPage(
                      widget.story.pages[index],
                      screenWidth,
                      screenHeight,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: 8,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios, color: Color(0xFF5D4037)),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  widget.story.icon + ' ' + widget.story.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5D4037),
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'صفحة ${_currentPage + 1} من ${widget.story.pages.length}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8D6E63),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 48), // Balance the back button
        ],
      ),
    );
  }

  Widget _buildProgressDots() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(widget.story.pages.length, (i) {
          return Container(
            width: i == _currentPage ? 24 : 10,
            height: 10,
            margin: EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: i < _currentPage
                  ? Color(0xFF4CAF50)
                  : i == _currentPage
                      ? Color(0xFF2575FC)
                      : Colors.grey[300],
              borderRadius: BorderRadius.circular(5),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStoryPage(
    StoryPage page,
    double screenWidth,
    double screenHeight,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.03,
        vertical: 8,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        textDirection: TextDirection.rtl,
        children: [
          // Right side - Image
          Container(
            width: screenWidth * 0.38,
            height: screenHeight * 0.55,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                page.imagePath,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[200],
                  child: Icon(Icons.image, size: 50, color: Colors.grey),
                ),
              ),
            ),
          ),
          SizedBox(width: 10),

          // Left side - Text + Interaction
          Expanded(
            child: SizedBox(
              height: screenHeight * 0.55,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Audio button (if available)
                    if (page.audioPath != null &&
                        page.type != InteractionType.pronounce)
                      Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: GestureDetector(
                          onTap: () => _playAudio(page.audioPath!),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                  color: Colors.blue.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.volume_up,
                                    color: Colors.blue, size: 18),
                                SizedBox(width: 6),
                                Text(
                                  'استمع 🔊',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    // Story text
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        _isAnswered && _isCorrect
                            ? page.text.replaceAll('___', page.correctAnswer)
                            : page.text,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF3E2723),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                    SizedBox(height: 12),

                    // Interaction area
                    if (page.type == InteractionType.fillInBlank)
                      _buildFillInBlank(page, screenWidth * 0.55),
                    if (page.type == InteractionType.chooseImage)
                      _buildChooseImage(page, screenWidth * 0.55),
                    if (page.type == InteractionType.pronounce)
                      _buildPronounce(page, screenWidth * 0.55),

                    SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFillInBlank(StoryPage page, double screenWidth) {
    return Column(
      children: [
        Text(
          'اختر الكلمة الصحيحة:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF5D4037),
          ),
        ),
        SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: page.options.map((option) {
            final isSelected = _selectedAnswer == option;
            final isCorrectOption = option == page.correctAnswer;
            Color bgColor = Colors.white;
            Color borderColor = Color(0xFF2575FC);
            Color textColor = Color(0xFF2575FC);

            if (_isAnswered && isSelected) {
              if (_isCorrect) {
                bgColor = Color(0xFF4CAF50);
                borderColor = Color(0xFF4CAF50);
                textColor = Colors.white;
              } else {
                bgColor = Color(0xFFE53935);
                borderColor = Color(0xFFE53935);
                textColor = Colors.white;
              }
            }

            return GestureDetector(
              onTap: () => _onFillInBlankAnswer(option, page),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: borderColor.withOpacity(0.2),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        if (_isAnswered && _isCorrect)
          Padding(
            padding: EdgeInsets.only(top: 12),
            child: Text(
              '✅ أحسنت! إجابة صحيحة',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4CAF50),
              ),
            ),
          ),
        if (_isAnswered && !_isCorrect)
          Padding(
            padding: EdgeInsets.only(top: 12),
            child: Text(
              '❌ حاول مرة أخرى!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE53935),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildChooseImage(StoryPage page, double screenWidth) {
    return Column(
      children: [
        Text(
          'اختر الصورة الصحيحة:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF5D4037),
          ),
        ),
        SizedBox(height: 10),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: List.generate(page.options.length, (i) {
            final option = page.options[i];
            final imagePath = page.optionImages![i];
            final isSelected = _selectedAnswer == option;
            final isCorrectOption = option == page.correctAnswer;

            Color borderColor = Colors.grey[300]!;
            if (_isAnswered && isSelected) {
              borderColor = _isCorrect ? Color(0xFF4CAF50) : Color(0xFFE53935);
            }

            return GestureDetector(
              onTap: () => _onImageAnswer(option, page),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                width: screenWidth * 0.4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: borderColor,
                    width: isSelected ? 4 : 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: Image.asset(
                        imagePath,
                        height: screenWidth * 0.35,
                        width: screenWidth * 0.4,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: screenWidth * 0.35,
                          color: Colors.grey[200],
                          child: Icon(Icons.image, color: Colors.grey),
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _isAnswered && isSelected
                            ? (_isCorrect
                                ? Color(0xFF4CAF50)
                                : Color(0xFFE53935))
                            : Colors.white,
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(16),
                        ),
                      ),
                      child: Text(
                        option,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: _isAnswered && isSelected
                              ? Colors.white
                              : Color(0xFF3E2723),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
        if (_isAnswered && _isCorrect)
          Padding(
            padding: EdgeInsets.only(top: 12),
            child: Text(
              '✅ صحيح! هذا هو ${page.correctAnswer}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4CAF50),
              ),
            ),
          ),
        if (_isAnswered && !_isCorrect)
          Padding(
            padding: EdgeInsets.only(top: 12),
            child: Text(
              '❌ حاول مرة أخرى!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE53935),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPronounce(StoryPage page, double screenWidth) {
    return Column(
      children: [
        // Target word display
        Container(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Color(0xFF2575FC).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Color(0xFF2575FC).withOpacity(0.3)),
          ),
          child: Text(
            'انطق: ${page.correctAnswer}',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2575FC),
            ),
          ),
        ),
        SizedBox(height: 16),

        // Audio hint (if available)
        if (page.audioPath != null)
          Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () => _playAudio(page.audioPath!),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.volume_up, color: Colors.orange, size: 20),
                    SizedBox(width: 6),
                    Text(
                      'استمع أولاً',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.orange[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Mic button
        GestureDetector(
          onTap: _isAnswered
              ? null
              : (_isListening ? _stopListening : _startListening),
          child: ScaleTransition(
            scale: _isListening ? _pulseAnimation : AlwaysStoppedAnimation(1.0),
            child: Container(
              width: screenWidth * 0.28,
              height: screenWidth * 0.28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: _isListening
                      ? [Color(0xFFE53935), Color(0xFFFF5252)]
                      : _isAnswered
                          ? [Colors.grey, Colors.grey[400]!]
                          : [Color(0xFF2575FC), Color(0xFF6A11CB)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: (_isListening ? Colors.red : Colors.blue)
                        .withOpacity(0.3),
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                _isListening ? Icons.stop : Icons.mic,
                color: Colors.white,
                size: screenWidth * 0.12,
              ),
            ),
          ),
        ),
        SizedBox(height: 10),

        // Status text
        Text(
          _isListening
              ? '🎤 أستمع إليك...'
              : _isAnswered
                  ? ''
                  : 'اضغط وانطق الكلمة',
          style: TextStyle(
            fontSize: 15,
            color: Color(0xFF8D6E63),
            fontWeight: FontWeight.w500,
          ),
        ),

        // Recognized text
        if (_recognizedText.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              '📝 "$_recognizedText"',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5D4037),
              ),
            ),
          ),

        // Result
        if (_showPronunciationResult)
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: Column(
              children: [
                Icon(
                  _isCorrect ? Icons.check_circle : Icons.cancel,
                  color: _isCorrect ? Color(0xFF4CAF50) : Color(0xFFE53935),
                  size: 40,
                ),
                SizedBox(height: 4),
                Text(
                  _isCorrect ? 'ممتاز! نطق صحيح 🎉' : 'حاول مرة أخرى!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _isCorrect ? Color(0xFF4CAF50) : Color(0xFFE53935),
                  ),
                ),
                if (!_isCorrect)
                  Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isAnswered = false;
                          _showPronunciationResult = false;
                          _recognizedText = '';
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xFF2575FC),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          'أعد المحاولة 🔄',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
