import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider_pkg;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'services/database_service.dart';
import 'services/handwriting_service.dart';
import 'models/child_profile.dart';
import 'models/lesson_progress.dart';
import 'models/achievement.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة Hive للتخزين المحلي
  await Hive.initFlutter();

  // تسجيل Hive Adapters
  Hive.registerAdapter(ChildProfileAdapter());
  Hive.registerAdapter(LessonProgressAdapter());
  Hive.registerAdapter(AchievementAdapter());

  // تهيئة قاعدة البيانات
  await DatabaseService.init();

  // تهيئة الإنجازات الافتراضية
  await DatabaseService.initializeDefaultAchievements();

  // تهيئة خدمة التعرف على الكتابة (في الخلفية)
  HandwritingRecognitionService.initialize().then((success) {
    print('🖊️ خدمة التعرف على الكتابة: ${success ? "جاهزة" : "غير متاحة"}');
  });

  // تحميل الثيم المحفوظ - فقط إذا اختار المستخدم شخصية غير الافتراضية
  final themeProvider = ThemeProvider();
  final profile = DatabaseService.getChildProfile();
  if (profile != null && profile.selectedCharacter != 'قطة') {
    // المستخدم اختار شخصية مختلفة
    themeProvider.updateTheme(profile.selectedCharacter);
  }
  // إذا كانت الشخصية قطة (الافتراضية)، نبقي الثيم الأزرق الافتراضي

  // تعيين الاتجاه الأفقي فقط
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // إخفاء شريط الحالة للحصول على تجربة ملء الشاشة
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(
    provider_pkg.ChangeNotifierProvider.value(
      value: themeProvider,
      child: const ProviderScope(
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'تعليم اللغة العربية',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,

      // دعم اللغة العربية من اليمين لليسار
      locale: const Locale('ar', 'SA'),
      supportedLocales: const [
        Locale('ar', 'SA'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // تفعيل RTL
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },

      // الشاشة الأولى
      home: const SplashScreen(),
    );
  }
}
