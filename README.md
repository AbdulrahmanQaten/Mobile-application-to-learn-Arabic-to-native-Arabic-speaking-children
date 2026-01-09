يتناول هذا الفصل التفاصيل التقنية لتنفيذ تطبيق "نطق" لتعليم النطق العربي للأطفال. تم تطوير التطبيق باستخدام إطار عمل **Flutter** مع تطبيق معماريتين رئيسيتين: **Clean Architecture** و **Model-View-Presenter (MVP)** لضمان قابلية الصيانة، قابلية التوسع، وسهولة الاختبار.

## المعمارية المستخدمة

### Clean Architecture

تم اعتماد Clean Architecture لفصل المسؤوليات وتنظيم الكود في طبقات مستقلة:

#### **الطبقات الرئيسية:**

```
lib/
├── data/              # طبقة البيانات (Data Layer)
├── services/          # طبقة الخدمات (Business Logic)
├── screens/           # طبقة العرض (Presentation Layer)
├── widgets/           # مكونات واجهة المستخدم القابلة لإعادة الاستخدام
├── theme/             # تصميم وألوان التطبيق
└── providers/         # إدارة الحالة (State Management)
```

**1. طبقة البيانات (Data Layer)**

- **المسؤولية**: إدارة البيانات الثابتة والديناميكية
- **المكونات**:
  - `letter_examples_data.dart`: بيانات أمثلة الحروف
  - `pronunciation_lessons_data.dart`: بيانات دروس النطق
  - `basic_level_tests_data.dart`: بيانات اختبارات المستويات
  - `character_data.dart`: بيانات الشخصيات والثيمات

**2. طبقة الخدمات (Business Logic Layer)**

- **المسؤولية**: تنفيذ منطق الأعمال والعمليات
- **المكونات**:
  - `database_service.dart`: إدارة قاعدة البيانات المحلية (Hive)
  - خدمات التعرف على الصوت
  - خدمات تشغيل الوسائط

**3. طبقة العرض (Presentation Layer)**

- **المسؤولية**: عرض واجهة المستخدم والتفاعل
- **المكونات**:
  - الشاشات (Screens)
  - الويدجتس (Widgets)
  - إدارة الحالة (Providers)

### Model-View-Presenter (MVP)

تم تطبيق نمط MVP في الشاشات الرئيسية:

```
┌─────────────┐         ┌─────────────┐         ┌─────────────┐
│    Model    │ ◄─────► │  Presenter  │ ◄─────► │    View     │
│  (Data)     │         │  (Logic)    │         │  (Screen)   │
└─────────────┘         └─────────────┘         └─────────────┘
```

**مثال: شاشة درس النطق**

- **Model**: `PronunciationLevel`, `PronunciationWord`
- **Presenter**: منطق التحقق من النطق، إدارة التقدم
- **View**: `PronunciationLessonScreen`

## البنية التفصيلية للمشروع

### هيكل المجلدات

```
my_app/
├── lib/
│   ├── main.dart                          # نقطة البداية
│   ├── data/                              # نماذج البيانات
│   │   ├── letter_examples_data.dart      # أمثلة الحروف (342 سطر)
│   │   ├── pronunciation_lessons_data.dart # دروس النطق (203 أسطر)
│   │   ├── basic_level_tests_data.dart    # اختبارات المستويات (320 سطر)
│   │   └── character_data.dart            # بيانات الشخصيات
│   ├── services/                          # الخدمات
│   │   └── database_service.dart          # خدمة قاعدة البيانات
│   ├── screens/                           # الشاشات
│   │   ├── home_screen.dart               # الشاشة الرئيسية
│   │   ├── levels_screen.dart             # شاشة المستويات
│   │   ├── lesson_screen.dart             # شاشة الدرس
│   │   ├── pronunciation_lesson_screen.dart # شاشة درس النطق (726 سطر)
│   │   ├── basic_level_test_screen.dart   # شاشة الاختبار (350 سطر)
│   │   ├── game_screen.dart               # شاشة اللعبة
│   │   ├── store_screen.dart              # متجر الشخصيات
│   │   └── placement_test_screen.dart     # اختبار تحديد المستوى
│   ├── widgets/                           # المكونات القابلة لإعادة الاستخدام
│   │   ├── letter_video_player.dart       # مشغل فيديو الحروف
│   │   └── level_test_dialog.dart         # نافذة اختبار المستوى
│   ├── theme/                             # التصميم
│   │   └── app_theme.dart                 # ألوان وأنماط التطبيق
│   ├── providers/                         # إدارة الحالة
│   │   └── theme_provider.dart            # مزود الثيم
│   └── models/                            # النماذج
│       └── child_profile.dart             # نموذج ملف الطفل
├── assets/                                # الموارد
│   ├── images/                            # الصور
│   │   ├── animals/                       # صور الحيوانات (36 صورة)
│   │   ├── food/                          # صور الطعام (67 صورة)
│   │   ├── body_parts/                    # صور أعضاء الجسم
│   │   ├── professions/                   # صور المهن (27 صورة)
│   │   └── characters/                    # صور الشخصيات
│   ├── audio/                             # الأصوات
│   │   ├── letters/                       # أصوات الحروف (28 ملف)
│   │   ├── fruits/                        # أصوات الفواكه (14 ملف)
│   │   ├── colors/                        # أصوات الألوان (11 ملف)
│   │   ├── professions/                   # أصوات المهن (9 ملفات)
│   │   ├── body_parts/                    # أصوات أعضاء الجسم (6 ملفات)
│   │   └── encouragement/                 # أصوات تشجيعية (5 ملفات)
│   └── videos/                            # الفيديوهات
│       └── letters/                       # فيديوهات رسم الحروف (28 فيديو)
└── android/                               # إعدادات Android
    └── app/
        └── src/main/AndroidManifest.xml   # الصلاحيات والإعدادات
```

### الإحصائيات

- **إجمالي الشاشات**: 10 شاشات رئيسية
- **إجمالي الملفات**: 25+ ملف Dart
- **إجمالي الأصول**:
  - صور: 130+ صورة
  - أصوات: 67+ ملف صوتي
  - فيديوهات: 28 فيديو تعليمي

## المكونات الرئيسية

### إدارة البيانات المحلية

**استخدام Hive Database**

```dart
// database_service.dart
class DatabaseService {
  static late Box<ChildProfile> _profileBox;

  // التهيئة
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(ChildProfileAdapter());
    _profileBox = await Hive.openBox<ChildProfile>('profiles');
  }

  // حفظ التقدم
  static Future<void> completeLesson(String lessonId, int stars) async {
    final profile = getChildProfile();
    profile.completedLessons[lessonId] = stars;
    await profile.save();
  }
}
```

**المميزات:**

- ✅ قاعدة بيانات NoSQL سريعة
- ✅ تخزين محلي بدون اتصال بالإنترنت
- ✅ دعم الكائنات المعقدة
- ✅ أداء عالي

### نظام التعرف على الصوت

**استخدام مكتبة speech_to_text**

```dart
// pronunciation_lesson_screen.dart
class _PronunciationLessonScreenState extends State<PronunciationLessonScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();

  Future<void> _startListening() async {
    // طلب الصلاحيات
    final status = await Permission.microphone.request();

    if (status.isGranted) {
      // بدء الاستماع
      await _speech.listen(
        onResult: (result) {
          setState(() {
            _recognizedText = result.recognizedWords;
          });
          _checkPronunciation();
        },
        localeId: 'ar_SA', // اللغة العربية
      );
    }
  }

  void _checkPronunciation() {
    final similarity = _calculateSimilarity(
      _recognizedText,
      widget.level.words[_currentWordIndex].word
    );

    if (similarity >= 0.7) { // نسبة نجاح 70%
      _playSuccessSound();
      _moveToNextWord();
    }
  }
}
```

**التقنيات المستخدمة:**

- **speech_to_text**: التعرف على الكلام
- **permission_handler**: إدارة الصلاحيات
- **record**: تسجيل الصوت
- **string_similarity**: حساب التشابه

### نظام الوسائط المتعددة

**تشغيل الصوت والفيديو**

```dart
// استخدام audioplayers
final AudioPlayer _audioPlayer = AudioPlayer();

Future<void> _playWordAudio() async {
  await _audioPlayer.stop();
  await _audioPlayer.play(AssetSource(word.audioPath));
}

// استخدام video_player
final VideoPlayerController _controller =
    VideoPlayerController.asset('assets/videos/letters/${letter}.mp4');

await _controller.initialize();
_controller.play();
```

**المكتبات المستخدمة:**

- `audioplayers`: ^5.0.0 - تشغيل الأصوات
- `video_player`: ^2.8.0 - تشغيل الفيديوهات

### إدارة الحالة

**استخدام Provider Pattern**

```dart
// theme_provider.dart
class ThemeProvider extends ChangeNotifier {
  Color _primaryColor = AppTheme.primarySkyBlue;

  void updateTheme(String characterId) {
    final character = CharactersData.getCharacter(characterId);
    _primaryColor = character.primaryColor;
    notifyListeners(); // إشعار المستمعين
  }
}

// الاستخدام في main.dart
ChangeNotifierProvider(
  create: (_) => ThemeProvider(),
  child: MyApp(),
)
```

## الشاشات الرئيسية

### الشاشة الرئيسية (Home Screen)

**الوظائف:**

- عرض معلومات الطفل (الاسم، الصورة، النقاط)
- الوصول السريع للمراحل التعليمية
- عرض التقدم العام

**المكونات:**

```dart
- AppBar مخصص مع معلومات الملف الشخصي
- GridView للمراحل التعليمية (3 مراحل)
- نظام النقاط والنجوم
- زر المتجر
```

### شاشة المستويات (Levels Screen)

**الوظائف:**

- عرض مستويات كل مرحلة
- قفل المستويات غير المكتملة
- عرض النجوم المكتسبة

**التصميم:**

```dart
CustomScrollView(
  slivers: [
    SliverAppBar, // هيدر ديناميكي
    SliverGrid,   // شبكة المستويات
  ]
)
```

### شاشة درس النطق (Pronunciation Lesson Screen)

**الميزات الرئيسية:**

1. **عرض الكلمة**:

   - صورة/إيموجي للكلمة
   - النص العربي
   - زر تشغيل الصوت

2. **نظام التسجيل**:

   - زر تسجيل بتأثيرات بصرية
   - مؤشر التسجيل
   - عرض النص المُتعرف عليه

3. **التحقق من النطق**:

   - حساب نسبة التشابه
   - تغذية راجعة فورية (صح/خطأ)
   - أصوات تشجيعية

4. **التنقل**:
   - PageView للتنقل بين الكلمات
   - مؤشر التقدم
   - زر الاختبار النهائي

**الكود الرئيسي:**

```dart
PageView.builder(
  controller: _pageController,
  onPageChanged: (index) {
    setState(() => _currentWordIndex = index);
  },
  itemCount: widget.level.words.length,
  itemBuilder: (context, index) => _buildWordPage(word),
)
```

### شاشة الاختبار (Basic Level Test Screen)

**البنية:**

1. **عرض السؤال**:

   - تشغيل الصوت تلقائياً
   - عرض السؤال النصي
   - زر "استمع مرة أخرى"

2. **الخيارات**:

   - Grid 2×2 من الخيارات
   - إيموجي/صور للخيارات
   - تغذية راجعة لونية (أخضر/برتقالي)

3. **النتائج**:
   - حساب النقاط
   - نظام النجوم (1-3)
   - حفظ النتيجة
   - خيار إعادة المحاولة

**نموذج البيانات:**

```dart
class TestQuestion {
  final String questionText;
  final String? audioPath;
  final List<TestOption> options;
  final String correctAnswerId;
  final QuestionType type;
}

enum QuestionType {
  audioToImage,    // سماع صوت واختيار صورة
  imageToText,     // رؤية صورة واختيار نص
  textToImage,     // قراءة نص واختيار صورة
}
```

### متجر الشخصيات (Store Screen)

**الوظائف:**

- عرض الشخصيات حسب الفئات (رخيصة، متوسطة، غالية، نادرة)
- نظام الشراء بالنقاط
- تطبيق الثيم المختار

**المميزات:**

```dart
- CustomScrollView مع SliverGrid
- نظام قفل الشخصيات
- تأثيرات بصرية للشخصية المختارة
- تحديث الثيم ديناميكياً
```

## التصميم والواجهة

### نظام الألوان

```dart
// app_theme.dart
class AppTheme {
  static const Color primarySkyBlue = Color(0xFF87CEEB);
  static const Color lightSkyBlue = Color(0xFFB0E0E6);
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color warningOrange = Color(0xFFFF9800);
  static const Color starYellow = Color(0xFFFFD700);
  static const Color textDark = Color(0xFF2C3E50);
}
```

### المكونات القابلة لإعادة الاستخدام

**1. مشغل الفيديو (LetterVideoPlayer)**

```dart
Widget _buildVideoWidget() {
  return Column(
    children: [
      VideoPlayer(_controller),
      Row(
        children: [
          IconButton(icon: Icons.play_pause),
          IconButton(icon: Icons.replay),
        ],
      ),
      VideoProgressIndicator(_controller),
    ],
  );
}
```

**2. نافذة الاختبار (LevelTestDialog)**

- اختبار سريع للحروف
- أسئلة ديناميكية
- تغذية راجعة فورية

## التكامل مع Android

### الصلاحيات

```xml
<!-- AndroidManifest.xml -->
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

### إعدادات Gradle

```gradle
// build.gradle
android {
    compileSdkVersion 34
    minSdkVersion 21
    targetSdkVersion 34
}

dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk7:$kotlin_version"
}
```

## إدارة الأصول (Assets)

### تنظيم الملفات

```yaml
# pubspec.yaml
flutter:
  assets:
    - assets/images/
    - assets/images/animals/
    - assets/images/food/
    - assets/images/professions/
    - assets/images/body_parts/
    - assets/audio/
    - assets/audio/letters/
    - assets/audio/fruits/
    - assets/audio/colors/
    - assets/audio/professions/
    - assets/audio/encouragement/
    - assets/videos/
    - assets/videos/letters/
```

### تحسين الأداء

**استراتيجيات التحميل:**

- تحميل الصور بشكل كسول (Lazy Loading)
- استخدام `errorBuilder` للصور المفقودة
- ضغط الصور والفيديوهات
- استخدام الإيموجي بدلاً من الصور عند الإمكان

```dart
Image.asset(
  'assets/${imagePath}',
  fit: BoxFit.contain,
  errorBuilder: (context, error, stackTrace) {
    return Icon(Icons.image, color: Colors.grey);
  },
)
```

## معالجة الأخطاء

### معالجة أخطاء الصوت

```dart
Future<void> _playWordAudio() async {
  try {
    await _audioPlayer.stop();
    await _audioPlayer.play(AssetSource(word.audioPath));
  } catch (e) {
    print('❌ خطأ في تشغيل الصوت: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('عذراً، الصوت غير متوفر')),
      );
    }
  }
}
```

### معالجة أخطاء التعرف على الصوت

```dart
if (kIsWeb) {
  _showWebNotSupported(); // الويب لا يدعم التعرف على الصوت
  return;
}

final available = await _speech.initialize();
if (!available) {
  _showMicrophoneError();
  return;
}
```

## الأداء والتحسينات

### تحسينات الأداء

**1. استخدام const constructors**

```dart
const PronunciationWord(
  word: 'تفاح',
  audioPath: 'audio/fruits/تفاح.mp3',
  imagePath: 'images/food/تفاح.jpg',
);
```

**2. تجنب إعادة البناء غير الضرورية**

```dart
class _MyWidgetState extends State<MyWidget> {
  @override
  Widget build(BuildContext context) {
    return const MyStaticWidget(); // لا يُعاد بناؤه
  }
}
```

**3. استخدام ListView.builder للقوائم الطويلة**

```dart
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemWidget(items[index]),
)
```

### إدارة الذاكرة

```dart
@override
void dispose() {
  _audioPlayer.dispose();
  _controller?.dispose();
  _speech.stop();
  super.dispose();
}
```

## الاختبار

### اختبار الوحدات (Unit Testing)

```dart
// مثال: اختبار حساب التشابه
test('similarity calculation', () {
  final similarity = calculateSimilarity('تفاح', 'تفاح');
  expect(similarity, equals(1.0));
});
```

### اختبار الويدجتس (Widget Testing)

```dart
testWidgets('Home screen displays correctly', (tester) async {
  await tester.pumpWidget(MyApp());
  expect(find.text('نطق'), findsOneWidget);
});
```

### الاختبار على الأجهزة

- ✅ اختبار على Android (API 21+)
- ✅ اختبار على Chrome (للويب)
- ✅ اختبار الصلاحيات
- ✅ اختبار التعرف على الصوت

## الخلاصة

تم تنفيذ تطبيق "نطق" باستخدام أفضل الممارسات في تطوير تطبيقات Flutter:

✅ **معمارية نظيفة**: فصل واضح للمسؤوليات
✅ **نمط MVP**: سهولة الصيانة والاختبار
✅ **أداء عالي**: تحميل كسول وإدارة فعالة للذاكرة
✅ **تجربة مستخدم ممتازة**: واجهة جذابة وتفاعلية
✅ **قابلية التوسع**: سهولة إضافة مستويات ودروس جديدة
✅ **دعم متعدد المنصات**: Android و Web

**الإحصائيات النهائية:**

- **عدد الشاشات**: 10+
- **عدد الملفات**: 25+ ملف Dart
- **الأصول**: 200+ ملف (صور، أصوات، فيديوهات)
- **الأسطر البرمجية**: 5000+ سطر
- **المكتبات المستخدمة**: 15+ مكتبة

التطبيق جاهز للنشر ويوفر تجربة تعليمية شاملة وممتعة للأطفال لتعلم النطق العربي الصحيح.