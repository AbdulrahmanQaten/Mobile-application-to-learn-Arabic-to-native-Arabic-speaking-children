import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../data/advanced_lessons_data.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lesson.name),
        backgroundColor: Color(0xFFFFD700),
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
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
                    minHeight: 6,
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  '${_currentLetterIndex + 1}/${widget.lesson.letters.length}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFD700),
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

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.celebration, color: Color(0xFFFFD700), size: 30),
            SizedBox(width: 10),
            Text('أحسنت!'),
          ],
        ),
        content: Text(
          'لقد أكملت درس ${widget.lesson.name} بنجاح!\n\nتعلمت كتابة ${widget.lesson.letters.length} حروف.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // إغلاق الحوار
              Navigator.pop(context); // العودة لقائمة الدروس
            },
            child: Text(
              'رائع!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFD700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
