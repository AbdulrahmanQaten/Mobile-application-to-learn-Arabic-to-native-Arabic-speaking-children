import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../data/mastery_stage_data.dart';
import '../../providers/theme_provider.dart';
import '../../services/database_service.dart';
import '../mastery_lesson_screen.dart';

class MasteryLevelScreen extends StatefulWidget {
  const MasteryLevelScreen({super.key});

  @override
  State<MasteryLevelScreen> createState() => _MasteryLevelScreenState();
}

class _MasteryLevelScreenState extends State<MasteryLevelScreen> {
  bool _celebrationShown = false;

  /// التحقق من إكمال جميع القصص
  void _checkStageCompletion() {
    if (_celebrationShown) return;

    final profile = DatabaseService.getChildProfile();
    if (profile != null && profile.currentLevel >= 6) return;

    bool allCompleted = true;
    for (var story in MasteryStageData.allStories) {
      final progress = DatabaseService.getLessonProgress(story.id);
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
                    color: AppTheme.primarySkyBlue,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'لقد أكملت مرحلة المتقن بنجاح!',
                  style: TextStyle(fontSize: 16, color: AppTheme.textDark),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'أنت بطل حقيقي! 🏆',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.successGreen,
                    fontWeight: FontWeight.bold,
                  ),
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
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    final profile = DatabaseService.getChildProfile();
                    if (profile != null) {
                      if (profile.currentLevel < 6) {
                        profile.addPoints(500); // مكافأة إتمام المرحلة
                        profile.currentLevel = 6;
                        await DatabaseService.saveChildProfile(profile);
                      }
                    }
                    if (mounted) {
                      Navigator.pop(context);
                      Navigator.pop(context);
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
                    child: _buildStoriesList(context, themeProvider),
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
            'مرحلة المتقن',
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
                Icon(Icons.auto_stories, color: Colors.white, size: 20),
                SizedBox(width: 5),
                Text(
                  'قصص تفاعلية',
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

  Widget _buildStoriesList(BuildContext context, ThemeProvider themeProvider) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: MasteryStageData.allStories.length,
      itemBuilder: (context, index) {
        final story = MasteryStageData.allStories[index];

        // التحقق من إمكانية فتح القصة
        bool isUnlocked = index == 0;
        if (index > 0) {
          final previousStory = MasteryStageData.allStories[index - 1];
          final previousProgress =
              DatabaseService.getLessonProgress(previousStory.id);
          isUnlocked = previousProgress?.isCompleted ?? false;
        }

        final progress = DatabaseService.getLessonProgress(story.id);
        final stars = progress?.stars ?? 0;

        return _StoryCard(
          level: index + 1,
          title: story.title,
          description: story.description,
          icon: story.icon,
          stars: stars,
          isUnlocked: isUnlocked,
          themeProvider: themeProvider,
          onTap: () {
            if (isUnlocked) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MasteryLessonScreen(story: story),
                ),
              ).then((_) {
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

class _StoryCard extends StatelessWidget {
  final int level;
  final String title;
  final String description;
  final String icon;
  final int stars;
  final bool isUnlocked;
  final ThemeProvider themeProvider;
  final VoidCallback onTap;

  const _StoryCard({
    required this.level,
    required this.title,
    required this.description,
    required this.icon,
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
                    themeProvider.secondaryColor.withOpacity(0.3),
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
            // أيقونة القصة
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
                        icon,
                        style: TextStyle(fontSize: 30),
                      )
                    : Icon(Icons.lock, color: Colors.white, size: 30),
              ),
            ),
            SizedBox(width: 16),
            // معلومات القصة
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'القصة $level: $title',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isUnlocked ? AppTheme.textDark : Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
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
