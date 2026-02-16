import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';
import '../../theme/app_theme.dart';
import '../../data/advanced_lessons_data.dart';
import '../../providers/theme_provider.dart';
import '../../services/database_service.dart';
import '../../models/lesson_progress.dart';
import 'handwriting_practice_screen.dart';

class AdvancedLessonScreen extends StatefulWidget {
  final AdvancedLesson lesson;

  const AdvancedLessonScreen({super.key, required this.lesson});

  @override
  State<AdvancedLessonScreen> createState() => _AdvancedLessonScreenState();
}

class _AdvancedLessonScreenState extends State<AdvancedLessonScreen> {
  int _currentLetterIndex = 0;

  @override
  Widget build(BuildContext context) {
    final currentLetter = widget.lesson.letters[_currentLetterIndex];
    final letterName = AdvancedLessonsData.getLetterName(currentLetter);
    final progress = (_currentLetterIndex + 1) / widget.lesson.letters.length;

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.lesson.name),
            backgroundColor: themeProvider.primaryColor,
            foregroundColor: Colors.white,
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(40),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                            themeProvider.primaryColor),
                        minHeight: 6,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      '${_currentLetterIndex + 1}/${widget.lesson.letters.length}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: HandwritingPracticeScreen(
            letter: currentLetter,
            letterName: letterName,
            onComplete: _goToNextLetter,
            showAppBar: false,
          ),
        );
      },
    );
  }

  void _goToNextLetter() {
    if (_currentLetterIndex < widget.lesson.letters.length - 1) {
      setState(() {
        _currentLetterIndex++;
      });
      // مسح الرسم السابق
      Future.delayed(Duration(milliseconds: 100), () {
        if (mounted) {
          // سيتم مسح الرسم تلقائياً لأن الشاشة ستُعاد بناؤها
        }
      });
    } else {
      // انتهى الدرس
      _showCompletionDialog();
    }
  }

  Future<void> _playEncouragementSound() async {
    final encouragementSounds = [
      'أحسنت.mp3',
      'ممتاز.mp3',
      'رائع.mp3',
      'جيد.mp3',
      'تصفيق.mp3',
    ];

    final random = Random();
    final selectedSound =
        encouragementSounds[random.nextInt(encouragementSounds.length)];

    try {
      final player = AudioPlayer();
      await player.play(AssetSource('audio/encouragement/$selectedSound'));
      print('🎵 تشغيل صوت تشجيع: $selectedSound');
    } catch (e) {
      print('خطأ في تشغيل صوت التشجيع: $e');
    }
  }

  void _showCompletionDialog() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    // حفظ التقدم - 3 نجوم لإكمال جميع الحروف
    final progress = LessonProgress(
      lessonId: widget.lesson.id,
      isCompleted: true,
      stars: 3,
    );
    DatabaseService.saveLessonProgress(progress);

    // تشغيل صوت التشجيع
    _playEncouragementSound();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            Icon(Icons.emoji_events, color: AppTheme.starYellow, size: 40),
            SizedBox(height: 8),
            Text('🎉 مبروك! 🎉',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.primaryColor)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('أكملت درس ${widget.lesson.name} بنجاح!',
                style: TextStyle(fontSize: 15, color: AppTheme.textDark),
                textAlign: TextAlign.center),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                  3,
                  (index) => Icon(
                        Icons.star,
                        color: AppTheme.starYellow,
                        size: 30,
                      )),
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
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.successGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text('رائع! 🌟',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
