import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../theme/app_theme.dart';

class LetterLessonWidget extends StatelessWidget {
  final String letter;
  final VoidCallback onPlaySound;

  const LetterLessonWidget({
    super.key,
    required this.letter,
    required this.onPlaySound,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: [
          // 1. عنوان + الحرف
          Text('تعلم حرف',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primarySkyBlue)),
          SizedBox(height: 15),
          _buildLetterDisplay(),

          SizedBox(height: 25),

          // 2. زر الاستماع
          _buildSoundButton(),

          SizedBox(height: 30),

          // 3. فيديو رسم الحرف
          _buildVideoSection(),

          SizedBox(height: 25),

          // 4. الأمثلة
          _buildExamplesSection(),
        ],
      ),
    );
  }

  Widget _buildLetterDisplay() {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
              color: AppTheme.primarySkyBlue.withOpacity(0.3),
              blurRadius: 30,
              offset: Offset(0, 10))
        ],
      ),
      child: Center(
          child: Text(letter,
              style: TextStyle(
                  fontSize: 85,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primarySkyBlue))),
    );
  }

  Widget _buildSoundButton() {
    return Column(
      children: [
        Text('اضغط للاستماع',
            style: TextStyle(
                fontSize: 16,
                color: AppTheme.textDark,
                fontWeight: FontWeight.w600)),
        SizedBox(height: 12),
        GestureDetector(
          onTap: onPlaySound,
          child: Container(
            padding: EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [AppTheme.warningOrange, Colors.orange[300]!]),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: AppTheme.warningOrange.withOpacity(0.4),
                    blurRadius: 20,
                    offset: Offset(0, 8))
              ],
            ),
            child: Icon(Icons.volume_up, size: 45, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoSection() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
              color: AppTheme.successGreen.withOpacity(0.2),
              blurRadius: 15,
              offset: Offset(0, 5))
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.play_circle, color: AppTheme.successGreen, size: 28),
              SizedBox(width: 10),
              Text('فيديو رسم الحرف',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primarySkyBlue)),
            ],
          ),
          SizedBox(height: 15),
          Text(
            'شاهد الفيديو لتتعلم كيف ترسم الحرف $letter',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          Text(
            letter,
            style: TextStyle(
                fontSize: 100,
                fontWeight: FontWeight.bold,
                color: AppTheme.successGreen.withOpacity(0.3)),
          ),
          SizedBox(height: 10),
          Text(
            'الفيديوهات متوفرة في التطبيق على الهاتف',
            style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
                fontStyle: FontStyle.italic),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildExamplesSection() {
    final examples = _getExamplesList(letter);

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: AppTheme.starYellow, width: 3),
        boxShadow: [
          BoxShadow(
              color: AppTheme.starYellow.withOpacity(0.2),
              blurRadius: 15,
              offset: Offset(0, 5))
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lightbulb, color: AppTheme.starYellow, size: 28),
              SizedBox(width: 10),
              Text('كلمات تبدأ بهذا الحرف',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primarySkyBlue)),
            ],
          ),
          SizedBox(height: 15),
          Wrap(
            spacing: 15,
            runSpacing: 15,
            alignment: WrapAlignment.center,
            children:
                examples.map((example) => _buildExampleCard(example)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildExampleCard(Map<String, String> example) {
    return Container(
      width: 100,
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.lightSkyBlue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                example['image']!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                      child: Text(example['emoji']!,
                          style: TextStyle(fontSize: 40)));
                },
              ),
            ),
          ),
          SizedBox(height: 8),
          Text(
            example['word']!,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<Map<String, String>> _getExamplesList(String letter) {
    final examplesMap = {
      'ا': [
        {
          'word': 'أسد',
          'image': 'assets/images/animals/lion.png',
          'emoji': '🦁'
        },
        {
          'word': 'أرنب',
          'image': 'assets/images/animals/rabbit.png',
          'emoji': '🐰'
        },
        {
          'word': 'أناناس',
          'image': 'assets/images/food/pineapple.png',
          'emoji': '🍍'
        },
      ],
      'ب': [
        {
          'word': 'بطة',
          'image': 'assets/images/animals/duck.png',
          'emoji': '🦆'
        },
        {
          'word': 'بيت',
          'image': 'assets/images/objects/house.png',
          'emoji': '🏠'
        },
        {
          'word': 'باب',
          'image': 'assets/images/objects/door.png',
          'emoji': '🚪'
        },
      ],
      'ت': [
        {
          'word': 'تفاحة',
          'image': 'assets/images/food/apple.png',
          'emoji': '🍎'
        },
        {'word': 'تمر', 'image': 'assets/images/food/dates.png', 'emoji': '🫐'},
        {
          'word': 'تاج',
          'image': 'assets/images/objects/crown.png',
          'emoji': '👑'
        },
      ],
      // ... يمكن إضافة باقي الحروف
    };
    return examplesMap[letter] ?? [];
  }
}
