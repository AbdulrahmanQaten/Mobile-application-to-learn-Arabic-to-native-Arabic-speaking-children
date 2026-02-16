import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../data/levels_data.dart';
import '../data/pronunciation_lessons_data.dart';
import '../services/database_service.dart';
import 'lesson_screen.dart';
import 'pronunciation_lesson_screen.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class LevelsScreen extends StatefulWidget {
  final String stageId;
  final String stageName;

  const LevelsScreen({
    super.key,
    required this.stageId,
    required this.stageName,
  });

  @override
  State<LevelsScreen> createState() => _LevelsScreenState();
}

class _LevelsScreenState extends State<LevelsScreen> {
  void _checkStageCompletion() {
    final stage = LevelsData.getStage(widget.stageId);
    if (stage == null) return;

    // التحقق من أن المرحلة لم تُكمل من قبل
    final profile = DatabaseService.getChildProfile();
    if (profile != null) {
      // مرحلة التمهيد: إذا كان المستوى >= 3 فهي مكتملة
      if (widget.stageId == 'preparatory' && profile.currentLevel >= 3) {
        return; // المرحلة مكتملة سابقاً، لا نعرض الديالوج
      }
      // مرحلة الأساسي: إذا كان المستوى >= 4 فهي مكتملة
      if (widget.stageId == 'basic' && profile.currentLevel >= 4) {
        return;
      }
    }

    // التحقق من إكمال جميع المستويات
    bool allCompleted = true;
    for (var level in stage.levels) {
      // تحديد نوع الدرس بناءً على المرحلة
      final lessonId = widget.stageId == 'basic'
          ? 'pronunciation_${level.id}_lesson'
          : widget.stageId == 'advanced'
              ? 'advanced_${level.id}_lesson'
              : 'level_${level.id}_lesson';

      final progress = DatabaseService.getLessonProgress(lessonId);
      if (progress == null || !progress.isCompleted) {
        allCompleted = false;
        break;
      }
    }

    if (allCompleted) {
      _showStageCelebration();
    }
  }

  void _showStageCelebration() {
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
                    color: AppTheme.primarySkyBlue)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('أكملت ${widget.stageName} بنجاح!',
                style: TextStyle(fontSize: 15, color: AppTheme.textDark),
                textAlign: TextAlign.center),
            SizedBox(height: 6),
            Text('المرحلة التالية أصبحت متاحة',
                style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.successGreen,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                  5,
                  (i) =>
                      Icon(Icons.star, color: AppTheme.starYellow, size: 24)),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final profile = DatabaseService.getChildProfile();
                if (profile != null) {
                  bool isNewCompletion = false;
                  if (profile.currentLevel < 3) {
                    isNewCompletion = true;
                  }
                  if (profile.currentLevel < 3) {
                    profile.currentLevel = 3;
                  } else {
                    profile.currentLevel++;
                  }
                  if (isNewCompletion) {
                    profile.addPoints(250);
                  }
                  await DatabaseService.saveChildProfile(profile);
                }
                if (mounted) {
                  Navigator.pop(context);
                  Navigator.pop(context, true);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.successGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text('متابعة',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stage = LevelsData.getStage(widget.stageId);

    if (stage == null) {
      return Scaffold(
        appBar: AppBar(title: Text('خطأ')),
        body: Center(child: Text('المرحلة غير موجودة')),
      );
    }

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
                    child: _buildLevelsList(context, stage),
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
            widget.stageName,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelsList(BuildContext context, Stage stage) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: stage.levels.length,
      itemBuilder: (context, index) {
        final level = stage.levels[index];

        // التحقق من إمكانية فتح المستوى
        bool isUnlocked = index == 0; // المستوى الأول دائماً مفتوح

        if (index > 0) {
          // تحديد نوع الدرس بناءً على المرحلة
          final previousLevelId = widget.stageId == 'basic'
              ? 'pronunciation_${stage.levels[index - 1].id}_lesson'
              : widget.stageId == 'advanced'
                  ? 'advanced_${stage.levels[index - 1].id}_lesson'
                  : 'level_${stage.levels[index - 1].id}_lesson';

          final previousProgress =
              DatabaseService.getLessonProgress(previousLevelId);
          isUnlocked = previousProgress?.isCompleted ?? false;

          print('🔓 فحص المستوى ${level.id}: ${isUnlocked ? "مفتوح" : "مقفل"}');
        }

        return _LevelCard(
          level: level,
          isUnlocked: isUnlocked,
          onTap: () {
            if (isUnlocked) {
              // التحقق من نوع الدرس
              if (widget.stageId == 'basic') {
                // مرحلة الأساسي - دروس النطق
                final pronunciationLevel = PronunciationLessonsData.getLevel(
                    'pronunciation_${level.id}');
                if (pronunciationLevel != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PronunciationLessonScreen(
                        level: pronunciationLevel,
                        lessonId: 'pronunciation_${level.id}_lesson',
                      ),
                    ),
                  ).then((_) {
                    if (mounted) {
                      setState(() {
                        print('🔄 تحديث شاشة المستويات');
                        _checkStageCompletion();
                      });
                    }
                  });
                }
              } else if (widget.stageId == 'advanced') {
                // مرحلة المتقدم - دروس الكتابة اليدوية
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LessonScreen(
                      level: level,
                      lessonId: 'advanced_${level.id}_lesson',
                    ),
                  ),
                ).then((_) {
                  if (mounted) {
                    setState(() {
                      print('🔄 تحديث شاشة المستويات');
                      _checkStageCompletion();
                    });
                  }
                });
              } else {
                // مرحلة التمهيد - دروس الحروف
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LessonScreen(
                      level: level,
                      lessonId: 'level_${level.id}_lesson',
                    ),
                  ),
                ).then((_) {
                  if (mounted) {
                    setState(() {
                      print('🔄 تحديث شاشة المستويات');
                      _checkStageCompletion();
                    });
                  }
                });
              }
            }
          },
        );
      },
    );
  }
}

class _LevelCard extends StatelessWidget {
  final Level level;
  final bool isUnlocked;
  final VoidCallback onTap;

  const _LevelCard({
    required this.level,
    required this.isUnlocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final themeProvider = Provider.of<ThemeProvider>(context);

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
                        '${level.id}',
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
                    level.title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isUnlocked ? AppTheme.textDark : Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'الحروف: ${level.targetLetters.join('، ')}',
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
