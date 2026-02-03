import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../data/advanced_lessons_data.dart';
import '../../providers/theme_provider.dart';
import '../../services/database_service.dart';
import 'advanced_lesson_screen.dart';

class AdvancedLevelScreen extends StatefulWidget {
  const AdvancedLevelScreen({super.key});

  @override
  State<AdvancedLevelScreen> createState() => _AdvancedLevelScreenState();
}

class _AdvancedLevelScreenState extends State<AdvancedLevelScreen> {
  bool _celebrationShown = false;

  @override
  void initState() {
    super.initState();
    // لا نتحقق عند التحميل الأولي - فقط عند العودة من درس
  }

  /// التحقق من إكمال جميع دروس المرحلة
  void _checkStageCompletion() {
    // لا نعرض الديالوج أكثر من مرة
    if (_celebrationShown) return;

    // التحقق من أن المستوى الحالي لم يُرفع بعد
    final profile = DatabaseService.getChildProfile();
    if (profile != null && profile.currentLevel >= 3) {
      // المرحلة مكتملة من قبل، لا نعرض الديالوج
      return;
    }

    bool allCompleted = true;

    for (var lesson in AdvancedLessonsData.allLessons) {
      final progress = DatabaseService.getLessonProgress(lesson.id);
      if (progress == null || !progress.isCompleted) {
        allCompleted = false;
        break;
      }
    }

    if (allCompleted) {
      _celebrationShown = true;
      _showStageCelebration();
    }
  }

  /// عرض احتفال إكمال المرحلة
  void _showStageCelebration() {
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
                Icon(Icons.emoji_events, color: AppTheme.starYellow, size: 60),
                SizedBox(height: 15),
                Text(
                  '🎉 مبروك! 🎉',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primarySkyBlue),
                ),
                SizedBox(height: 12),
                Text(
                  'لقد أكملت مرحلة الكتابة بنجاح!',
                  style: TextStyle(fontSize: 16, color: AppTheme.textDark),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'المرحلة التالية أصبحت متاحة الآن',
                  style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.successGreen,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                      5,
                      (i) => Padding(
                            padding: EdgeInsets.symmetric(horizontal: 3),
                            child: Icon(Icons.star,
                                color: AppTheme.starYellow, size: 30),
                          )),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    // رفع المستوى لفتح المرحلة التالية
                    final profile = DatabaseService.getChildProfile();
                    if (profile != null && profile.currentLevel < 3) {
                      profile.currentLevel = 3; // فتح المرحلة الثالثة (النطق)
                      await DatabaseService.saveChildProfile(profile);
                      print('🎊 تم رفع المستوى إلى: ${profile.currentLevel}');
                    }

                    if (mounted) {
                      Navigator.pop(context); // إغلاق الديالوج
                      Navigator.pop(context); // الرجوع للشاشة الرئيسية
                    }
                  },
                  child: Text('متابعة',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.successGreen,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  themeProvider.primaryColor,
                  themeProvider.secondaryColor,
                  themeProvider.secondaryColor.withOpacity(0.5),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildHeader(context),
                  SizedBox(height: 20),
                  Expanded(
                    child: _buildLevelsList(context, themeProvider),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
          SizedBox(width: 10),
          Text(
            'مرحلة الكتابة',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Spacer(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                Icon(Icons.edit, color: Colors.white, size: 20),
                SizedBox(width: 5),
                Text(
                  'تعلم الخط',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelsList(BuildContext context, ThemeProvider themeProvider) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: AdvancedLessonsData.allLessons.length,
      itemBuilder: (context, index) {
        final lesson = AdvancedLessonsData.allLessons[index];

        // التحقق من إمكانية فتح المستوى
        bool isUnlocked = index == 0; // المستوى الأول دائماً مفتوح

        if (index > 0) {
          // التحقق من إكمال المستوى السابق
          final previousLesson = AdvancedLessonsData.allLessons[index - 1];
          final previousProgress =
              DatabaseService.getLessonProgress(previousLesson.id);
          isUnlocked = previousProgress?.isCompleted ?? false;
        }

        // الحصول على التقدم المحفوظ
        final progress = DatabaseService.getLessonProgress(lesson.id);
        final stars = progress?.stars ?? 0;

        return _LevelCard(
          level: index + 1,
          title: lesson.name,
          letters: lesson.letters,
          stars: stars,
          isUnlocked: isUnlocked,
          themeProvider: themeProvider,
          onTap: () {
            if (isUnlocked) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AdvancedLessonScreen(lesson: lesson),
                ),
              ).then((_) {
                // تحديث الشاشة والتحقق من إكمال المرحلة بعد العودة
                if (mounted) {
                  setState(() {});
                  _checkStageCompletion();
                }
              });
            }
          },
        );
      },
    );
  }
}

class _LevelCard extends StatelessWidget {
  final int level;
  final String title;
  final List<String> letters;
  final int stars;
  final bool isUnlocked;
  final ThemeProvider themeProvider;
  final VoidCallback onTap;

  const _LevelCard({
    required this.level,
    required this.title,
    required this.letters,
    required this.stars,
    required this.isUnlocked,
    required this.themeProvider,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isUnlocked ? onTap : null,
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isUnlocked
              ? LinearGradient(
                  colors: [
                    Colors.white,
                    themeProvider.secondaryColor.withOpacity(0.3)
                  ],
                )
              : null,
          color: isUnlocked ? null : Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: themeProvider.primaryColor.withOpacity(0.3),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ]
              : [],
          border: Border.all(
            color: isUnlocked ? themeProvider.primaryColor : Colors.grey,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            // أيقونة المستوى
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isUnlocked ? themeProvider.primaryColor : Colors.grey,
              ),
              child: Center(
                child: isUnlocked
                    ? Text(
                        '$level',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )
                    : Icon(Icons.lock, color: Colors.white, size: 30),
              ),
            ),

            SizedBox(width: 16),

            // معلومات المستوى
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isUnlocked ? AppTheme.textDark : Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'الحروف: ${letters.join('، ')}',
                    style: TextStyle(
                      fontSize: 16,
                      color: isUnlocked
                          ? AppTheme.textDark.withOpacity(0.7)
                          : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),

            // سهم
            if (isUnlocked)
              Icon(
                Icons.arrow_forward_ios,
                color: themeProvider.primaryColor,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
