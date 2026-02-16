import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../data/letters_data.dart';
import 'dart:math';

class GameScreen extends StatefulWidget {
  final String levelId;
  final List<String> targetLetters;

  const GameScreen({
    super.key,
    required this.levelId,
    required this.targetLetters,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late ConfettiController _confettiController;

  int _score = 0;
  int _hearts = 3;
  int _currentQuestion = 0;
  String? _selectedLetter;
  bool _showFeedback = false;
  bool _isCorrect = false;

  List<Map<String, dynamic>> _questions = [];

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
    _generateQuestions();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _generateQuestions() {
    final random = Random();
    _questions = widget.targetLetters.map((letter) {
      final letterData = LettersData.getLetter(letter);

      // إنشاء خيارات (الحرف الصحيح + 3 حروف عشوائية)
      final allLetters = LettersData.allLetters.map((l) => l.letter).toList();
      final options = <String>[letter];

      while (options.length < 4) {
        final randomLetter = allLetters[random.nextInt(allLetters.length)];
        if (!options.contains(randomLetter)) {
          options.add(randomLetter);
        }
      }

      options.shuffle();

      return {
        'letter': letter,
        'audioPath': letterData?.audioPath ?? '',
        'options': options,
      };
    }).toList();

    _questions.shuffle();
  }

  void _playQuestionAudio() async {
    final audioPath = _questions[_currentQuestion]['audioPath'];
    if (audioPath != null) {
      try {
        await _audioPlayer.play(AssetSource(audioPath));
      } catch (e) {
        print('Error playing audio: $e');
      }
    }
  }

  void _checkAnswer(String selectedLetter) {
    if (_showFeedback) return;

    setState(() {
      _selectedLetter = selectedLetter;
      _showFeedback = true;
      _isCorrect = selectedLetter == _questions[_currentQuestion]['letter'];

      if (_isCorrect) {
        _score += 20;
        _confettiController.play();
      } else {
        _hearts--;
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (_hearts <= 0) {
        _showGameOver();
      } else if (_currentQuestion < _questions.length - 1) {
        setState(() {
          _currentQuestion++;
          _selectedLetter = null;
          _showFeedback = false;
        });
      } else {
        _showSuccess();
      }
    });
  }

  void _showSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            Icon(Icons.emoji_events, color: AppTheme.starYellow, size: 40),
            const SizedBox(height: 8),
            Text('أحسنت! 🎉',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star, color: AppTheme.starYellow, size: 22),
                const SizedBox(width: 6),
                Text('النقاط: $_score',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primarySkyBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text('العودة للمستويات',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  void _showGameOver() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            Icon(Icons.refresh, color: AppTheme.warningOrange, size: 40),
            const SizedBox(height: 8),
            Text('حاول مرة أخرى! 💪',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: Text('الخروج',
                      style: TextStyle(fontSize: 15, color: Colors.grey)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      _score = 0;
                      _hearts = 3;
                      _currentQuestion = 0;
                      _selectedLetter = null;
                      _showFeedback = false;
                      _generateQuestions();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primarySkyBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('إعادة',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color(0xFF87CEEB),
              Color(0xFFB0E0E6),
              Color(0xFFE0F6FF),
            ],
          ),
        ),
        child: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  // الشريط العلوي
                  _buildTopBar(),

                  const SizedBox(height: 30),

                  // العنوان
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Text(
                      'استمع واختر الحرف الصحيح',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ),

                  const SizedBox(height: 50),

                  // زر تشغيل الصوت
                  GestureDetector(
                    onTap: _playQuestionAudio,
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primarySkyBlue,
                            AppTheme.darkSkyBlue
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primarySkyBlue.withOpacity(0.5),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.volume_up,
                        size: 90,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 60),

                  // الخيارات
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 80),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 40,
                        mainAxisSpacing: 40,
                        childAspectRatio: 1.3,
                      ),
                      itemCount: _questions[_currentQuestion]['options'].length,
                      itemBuilder: (context, index) {
                        final letter =
                            _questions[_currentQuestion]['options'][index];
                        final isSelected = _selectedLetter == letter;
                        final isCorrect =
                            letter == _questions[_currentQuestion]['letter'];

                        Color? borderColor;
                        if (_showFeedback && isSelected) {
                          borderColor = _isCorrect
                              ? AppTheme.successGreen
                              : AppTheme.errorRed;
                        }

                        return _LetterOption(
                          letter: letter,
                          isSelected: isSelected,
                          borderColor: borderColor,
                          onTap: () => _checkAnswer(letter),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Confetti
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                particleDrag: 0.05,
                emissionFrequency: 0.05,
                numberOfParticles: 50,
                gravity: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // زر الرجوع
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: AppTheme.cardShadow,
            ),
            child: IconButton(
              icon: Icon(Icons.close, color: AppTheme.errorRed, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // النقاط
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppTheme.cardShadow,
            ),
            child: Row(
              children: [
                Icon(Icons.star, color: AppTheme.starYellow, size: 28),
                const SizedBox(width: 10),
                Text(
                  _score.toString(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
              ],
            ),
          ),

          // القلوب
          Row(
            children: List.generate(3, (index) {
              return Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(
                  index < _hearts ? Icons.favorite : Icons.favorite_border,
                  color: AppTheme.errorRed,
                  size: 35,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _LetterOption extends StatelessWidget {
  final String letter;
  final bool isSelected;
  final Color? borderColor;
  final VoidCallback onTap;

  const _LetterOption({
    required this.letter,
    required this.isSelected,
    this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: AppTheme.cardShadow,
          border: Border.all(
            color: borderColor ?? AppTheme.primarySkyBlue,
            width: 4,
          ),
        ),
        child: Center(
          child: Text(
            letter,
            style: TextStyle(
              fontSize: 90,
              fontWeight: FontWeight.bold,
              color: borderColor ?? AppTheme.primarySkyBlue,
            ),
          ),
        ),
      ),
    );
  }
}
